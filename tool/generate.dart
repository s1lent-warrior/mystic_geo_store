// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';

/// mystic_geo_store generator.
///
/// Supports:
/// - input as a directory containing `sot/`
/// - input as a zip file containing `sot/`
///
/// Usage:
///   dart run tool/generate.dart --input path/to/geo_sot.zip --out lib/
///   dart run tool/generate.dart --input path/to/extracted_sot_dir --out lib/
///
/// Optional:
///   --emit-models       Also generates entity/model files under `lib/src/models/`.
Future<void> main(List<String> args) async {
  final input = _arg(args, '--input') ?? _arg(args, '-i');
  final out = _arg(args, '--out') ?? _arg(args, '-o') ?? 'lib';
  final emitModels = _hasFlag(args, '--emit-models');

  if (input == null) {
    stderr.writeln('Missing --input. Example: --input geo_sot.zip');
    exitCode = 64;
    return;
  }

  final inputType = FileSystemEntity.typeSync(input);
  if (inputType == FileSystemEntityType.notFound) {
    stderr.writeln('Input not found: $input');
    exitCode = 66;
    return;
  }

  final workDir = await _resolveWorkDir(input, inputType);
  try {
    final sotDir = Directory('${workDir.path}/sot');
    if (!sotDir.existsSync()) {
      stderr.writeln('No `sot/` folder found under: ${workDir.path}');
      exitCode = 65;
      return;
    }

    final outDir = Directory(out);
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }

    await _generate(sotDir: sotDir, outLibDir: outDir, emitModels: emitModels);

    print('✅ Generated mystic_geo_store sources into: ${outDir.path}');
  } finally {
    // Best-effort cleanup of temp extraction directory.
    if (workDir.path.startsWith(Directory.systemTemp.path)) {
      try {
        workDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  }
}

String? _arg(List<String> args, String name) {
  final i = args.indexOf(name);
  if (i == -1) return null;
  if (i + 1 >= args.length) return null;
  return args[i + 1];
}

bool _hasFlag(List<String> args, String name) => args.contains(name);

Future<Directory> _resolveWorkDir(
  String input,
  FileSystemEntityType type,
) async {
  if (type == FileSystemEntityType.directory) {
    return Directory(input);
  }

  // Zip file case.
  final bytes = File(input).readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  final tmp = await Directory.systemTemp.createTemp('geo_sot_');
  for (final entry in archive) {
    if (!entry.isFile) continue;

    final outPath = '${tmp.path}/${entry.name}';
    final outFile = File(outPath);
    outFile.parent.createSync(recursive: true);

    final content = entry.content;
    if (content is List<int>) {
      outFile.writeAsBytesSync(content);
    } else {
      // archive may store content in other formats depending on version
      outFile.writeAsBytesSync((content as dynamic) as List<int>);
    }
  }
  return tmp;
}

// ---------------------------------------------------------------------------
// Generation
// ---------------------------------------------------------------------------

Future<void> _generate({
  required Directory sotDir,
  required Directory outLibDir,
  required bool emitModels,
}) async {
  final countriesDoc = _readJsonMap(File('${sotDir.path}/countries.json'));
  final dialDoc = _readJsonMap(File('${sotDir.path}/dial_codes.json'));
  final currenciesDoc = _readJsonMap(File('${sotDir.path}/currencies.json'));

  final countries = (countriesDoc['countries'] as List)
      .cast<Map<String, Object?>>();
  countries.sort(
    (a, b) => (a['iso2'] as String).compareTo(b['iso2'] as String),
  );

  // Prepare output dirs
  final modelsDir = Directory('${outLibDir.path}/src/models')
    ..createSync(recursive: true);

  final genDir = Directory('${outLibDir.path}/src/generated')
    ..createSync(recursive: true);

  final dataDir = Directory('${genDir.path}/data')..createSync(recursive: true);

  // Keep cities + states in separate folders
  final citiesDir = Directory('${dataDir.path}/cities')
    ..createSync(recursive: true);
  final statesDir = Directory('${dataDir.path}/states')
    ..createSync(recursive: true);

  // Optionally emit models/entities.
  if (emitModels) {
    _writeFile(
      File('${modelsDir.path}/geo_country.dart'),
      _emitGeoCountryModel(),
    );
    _writeFile(File('${modelsDir.path}/geo_state.dart'), _emitGeoStateModel());
    _writeFile(File('${modelsDir.path}/geo_city.dart'), _emitGeoCityModel());
    _writeFile(
      File('${modelsDir.path}/geo_currency.dart'),
      _emitGeoCurrencyModel(),
    );
    _writeFile(
      File('${modelsDir.path}/geo_dial_code_entry.dart'),
      _emitGeoDialCodeEntryModel(),
    );
  }

  // 1) Enum: GeoCountryIso2 (generated always)
  _writeFile(
    File('${modelsDir.path}/geo_country_iso2.dart'),
    _emitCountryIso2Enum(countries),
  );

  // 2) Countries table
  _writeFile(
    File('${dataDir.path}/geo_countries.g.dart'),
    _emitCountriesTable(countries),
  );

  // 3) Dial codes
  final dialMap = (dialDoc['dialCodesByCountryIso2'] as Map)
      .cast<String, Object?>();
  _writeFile(
    File('${dataDir.path}/geo_dial_codes.g.dart'),
    _emitDialCodesTable(dialMap),
  );

  // 4) Currencies + maps
  _writeFile(
    File('${dataDir.path}/geo_currencies.g.dart'),
    _emitCurrenciesTable(currenciesDoc),
  );
  _writeFile(
    File('${dataDir.path}/geo_country_currency.g.dart'),
    _emitCurrencyByCountry(currenciesDoc),
  );
  _writeFile(
    File('${dataDir.path}/geo_currency_countries.g.dart'),
    _emitCountriesByCurrency(currenciesDoc),
  );

  // 5) States buckets + lookup + index
  final statesSotDir = Directory('${sotDir.path}/states');
  final stateFiles =
      statesSotDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .where((f) => !f.path.endsWith('index.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final stateById = <String, Map<String, Object?>>{};
  final countryToBucket = <String, String>{};
  final buckets = <String, List<Map<String, Object?>>>{};

  for (final f in stateFiles) {
    final fileName = f.uri.pathSegments.last;
    final bucket = fileName.replaceAll('.json', '').toUpperCase();

    final doc = _readJsonMap(f);
    final list = (doc['states'] as List).cast<Map<String, Object?>>();

    // deterministic state order per bucket
    list.sort((a, b) {
      final ca = (a['countryIso2'] as String).toUpperCase();
      final cb = (b['countryIso2'] as String).toUpperCase();
      final na = (a['name'] as String?) ?? '';
      final nb = (b['name'] as String?) ?? '';
      final ia = (a['id'] as String?) ?? '';
      final ib = (b['id'] as String?) ?? '';
      final c1 = ca.compareTo(cb);
      if (c1 != 0) return c1;
      final c2 = na.compareTo(nb);
      if (c2 != 0) return c2;
      return ia.compareTo(ib);
    });

    buckets[bucket] = list;

    for (final s in list) {
      final id = s['id'] as String;
      stateById[id] = s;

      final iso = (s['countryIso2'] as String).toUpperCase();
      countryToBucket.putIfAbsent(iso, () => bucket);
    }
  }
  buckets.putIfAbsent('OTHER', () => <Map<String, Object?>>[]);

  final bucketKeys = buckets.keys.toList()..sort();
  for (final bucket in bucketKeys) {
    _writeFile(
      File('${statesDir.path}/geo_states_${bucket.toLowerCase()}.g.dart'),
      _emitStatesBucket(bucket, buckets[bucket]!),
    );
  }

  _writeFile(
    File('${statesDir.path}/geo_states_lookup.g.dart'),
    _emitStateById(stateById),
  );

  _writeFile(
    File('${statesDir.path}/geo_states_index.g.dart'),
    _emitStatesIndex(countries, bucketKeys, countryToBucket),
  );

  // 6) Cities per country + indexes
  final citiesSotDir = Directory('${sotDir.path}/cities');
  final cityFiles =
      citiesSotDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final cityCountries = <String, List<Map<String, Object?>>>{};
  final cityIndexByState = <String, Map<String, List<int>>>{};

  for (final f in cityFiles) {
    final iso = f.uri.pathSegments.last.replaceAll('.json', '').toUpperCase();
    final doc = _readJsonMap(f);
    final list = (doc['cities'] as List).cast<Map<String, Object?>>();

    // deterministic city order per country
    list.sort((a, b) {
      final sa = (a['stateId'] as String?) ?? '';
      final sb = (b['stateId'] as String?) ?? '';
      final na = (a['name'] as String?) ?? '';
      final nb = (b['name'] as String?) ?? '';
      final ia = (a['id'] as String?) ?? '';
      final ib = (b['id'] as String?) ?? '';
      final c1 = sa.compareTo(sb);
      if (c1 != 0) return c1;
      final c2 = na.compareTo(nb);
      if (c2 != 0) return c2;
      return ia.compareTo(ib);
    });

    cityCountries[iso] = list;

    final idx = <String, List<int>>{};
    for (var i = 0; i < list.length; i++) {
      final sid = list[i]['stateId'] as String;
      (idx[sid] ??= <int>[]).add(i);
    }
    cityIndexByState[iso] = idx;
  }

  final cityIsoKeys = cityCountries.keys.toList()..sort();
  for (final iso in cityIsoKeys) {
    _writeFile(
      File('${citiesDir.path}/geo_cities_${iso.toLowerCase()}.g.dart'),
      _emitCitiesCountry(iso, cityCountries[iso]!),
    );
    _writeFile(
      File('${citiesDir.path}/geo_cities_${iso.toLowerCase()}_index.g.dart'),
      _emitCitiesCountryIndex(iso, cityIndexByState[iso]!),
    );
  }

  _writeFile(
    File('${citiesDir.path}/geo_cities_index.g.dart'),
    _emitCitiesIndex(cityIsoKeys),
  );
}

Map<String, Object?> _readJsonMap(File f) {
  final raw = f.readAsStringSync();
  return (jsonDecode(raw) as Map).cast<String, Object?>();
}

void _writeFile(File f, String content) {
  f.parent.createSync(recursive: true);
  f.writeAsStringSync(content);
}

/// Escapes [s] for a safe single-quoted Dart string literal.
///
/// Handles:
/// - backslash
/// - single quote
/// - dollar sign (prevents interpolation)
/// - newlines / carriage returns
String _dartStr(String s) {
  var v = s;
  v = v.replaceAll('\\', r'\\');
  v = v.replaceAll("'", r"\'");
  v = v.replaceAll(r'$', r'\$');
  v = v.replaceAll('\r', r'\r');
  v = v.replaceAll('\n', r'\n');
  return "'$v'";
}

// ---------------------------------------------------------------------------
// Emitters: Models (optional)
// ---------------------------------------------------------------------------

String _emitGeoCountryModel() => '''
import 'geo_country_iso2.dart';

/// A country entry intended for UI pickers and lightweight metadata usage.
///
/// Instances are generated as compile-time constants from the SoT dataset.
///
/// - [iso2] is the ISO 3166-1 alpha-2 code (e.g. `GeoCountryIso2.PK`).
/// - [name] is the English display name.
/// - [emoji] is the flag emoji (if available).
class GeoCountry {
  const GeoCountry({
    required this.iso2,
    required this.name,
    required this.emoji,
  });

  final GeoCountryIso2 iso2;
  final String name;
  final String emoji;
}

''';

String _emitGeoStateModel() => '''
import 'geo_country_iso2.dart';

/// A first-level administrative division of a country (state/region/province).
///
/// Instances are generated as compile-time constants from the SoT dataset.
///
/// - [id] is a stable identifier used to join cities to a state.
/// - [name] is the English display name.
/// - [countryIso2] is the country this state belongs to.
class GeoState {
  const GeoState({
    required this.id,
    required this.name,
    required this.countryIso2,
  });

  final String id;
  final String name;
  final GeoCountryIso2 countryIso2;
}
''';

String _emitGeoCityModel() => '''
import 'geo_country_iso2.dart';

/// A city entry intended for pickers and basic search.
///
/// Instances are generated as compile-time constants from the SoT dataset.
///
/// - [id] is a stable city identifier.
/// - [name] is the English display name.
/// - [countryIso2] is the owning country.
/// - [stateId] joins this city to a [GeoState.id].
/// - [iata] is an optional airport code when available.
class GeoCity {
  const GeoCity({
    required this.id,
    required this.name,
    required this.countryIso2,
    required this.stateId,
    this.iata,
  });

  final String id;
  final String name;
  final GeoCountryIso2 countryIso2;
  final String stateId;
  final String? iata;
}
''';

String _emitGeoCurrencyModel() => '''
/// A currency entry intended for UI pickers and display.
///
/// Instances are generated as compile-time constants from the SoT dataset.
///
/// - [code] is the ISO 4217 currency code (e.g. "USD").
/// - [name] is the English display name.
/// - [symbol] is an optional symbol (e.g. "\$").
///   Symbols are escaped in generated code to avoid Dart interpolation issues.
class GeoCurrency {
  const GeoCurrency({
    required this.code,
    required this.name,
    this.symbol,
  });

  final String code;
  final String name;
  final String? symbol;
}
''';

String _emitGeoDialCodeEntryModel() => '''
import 'geo_country_iso2.dart';

/// Dial codes (telephone calling codes) for a country.
///
/// Some countries/territories may have multiple dial codes, so [dialCodes]
/// is a list (e.g. ["+1", "+1242"] depending on dataset rules).
class GeoDialCodeEntry {
  const GeoDialCodeEntry({
    required this.countryIso2,
    required this.dialCodes,
  });

  final GeoCountryIso2 countryIso2;
  final List<String> dialCodes;
}
''';

// ---------------------------------------------------------------------------
// Emitters: Generated tables
// ---------------------------------------------------------------------------

String _emitCountryIso2Enum(List<Map<String, Object?>> countries) {
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/countries.json')
    ..writeln()
    ..writeln('/// ISO 3166-1 alpha-2 country codes.')
    ..writeln('///')
    ..writeln(
      '/// Enum cases are uppercase (e.g. `PK`, `US`) to avoid collisions with Dart keywords.',
    )
    ..writeln('enum GeoCountryIso2 {');

  for (final c in countries) {
    final iso = (c['iso2'] as String).toUpperCase();
    final name = c['name'] as String;
    b.writeln('  /// $name ($iso)');
    b.writeln('  $iso,');
    b.writeln();
  }

  b
    ..writeln('  ;')
    ..writeln()
    ..writeln('  /// ISO2 string code, e.g. "PK".')
    ..writeln('  String get code => name;')
    ..writeln()
    ..writeln('  /// Parses [code] into a [GeoCountryIso2].')
    ..writeln('  ///')
    ..writeln(
      '  /// Trims and uppercases the input, then resolves via [GeoCountryIso2.values.byName].',
    )
    ..writeln('  /// Throws [ArgumentError] if the code is invalid.')
    ..writeln(
      '  factory GeoCountryIso2.withCode(String code) => GeoCountryIso2._fromCode(code);',
    )
    ..writeln()
    ..writeln('  /// Internal parsing factory.')
    ..writeln('  factory GeoCountryIso2._fromCode(String code) {')
    ..writeln('    final normalized = code.trim().toUpperCase();')
    ..writeln('    try {')
    ..writeln('      return GeoCountryIso2.values.byName(normalized);')
    ..writeln('    } catch (_) {')
    ..writeln(
      "      throw ArgumentError.value(code, 'code', 'Invalid ISO2 country code');",
    )
    ..writeln('    }')
    ..writeln('  }')
    ..writeln('}');
  return b.toString();
}

String _emitCountriesTable(List<Map<String, Object?>> countries) {
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/countries.json')
    ..writeln(
      '// Contains the canonical const list of countries and ISO2->index lookup.',
    )
    ..writeln()
    ..writeln("import '../../models/geo_country.dart';")
    ..writeln("import '../../models/geo_country_iso2.dart';")
    ..writeln()
    ..writeln('const List<GeoCountry> kGeoCountries = <GeoCountry>[');

  for (final c in countries) {
    final iso = (c['iso2'] as String).toUpperCase();
    final name = _dartStr(c['name'] as String);
    final flag = _dartStr((c['flag'] as String?) ?? '');
    b.writeln(
      '  GeoCountry(iso2: GeoCountryIso2.$iso, name: $name, emoji: $flag),',
    );
  }
  b
    ..writeln('];')
    ..writeln()
    ..writeln(
      'const Map<GeoCountryIso2, int> kGeoCountryIndexByIso2 = <GeoCountryIso2, int>{',
    );
  for (var i = 0; i < countries.length; i++) {
    final iso = (countries[i]['iso2'] as String).toUpperCase();
    b.writeln('  GeoCountryIso2.$iso: $i,');
  }
  b.writeln('};');
  return b.toString();
}

String _emitDialCodesTable(Map<String, Object?> dialMap) {
  final keys = dialMap.keys.toList()..sort();
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/dial_codes.json')
    ..writeln('// Canonical country dial codes + ISO2->index lookup.')
    ..writeln()
    ..writeln("import '../../models/geo_country_iso2.dart';")
    ..writeln("import '../../models/geo_dial_code_entry.dart';")
    ..writeln()
    ..writeln(
      'const List<GeoDialCodeEntry> kGeoDialCodes = <GeoDialCodeEntry>[',
    );

  for (final iso in keys) {
    final list = (dialMap[iso] as List).cast<String>();
    final codes = list.map(_dartStr).join(', ');
    b.writeln(
      '  GeoDialCodeEntry(countryIso2: GeoCountryIso2.${iso.toUpperCase()}, dialCodes: <String>[$codes]),',
    );
  }
  b
    ..writeln('];')
    ..writeln()
    ..writeln(
      'const Map<GeoCountryIso2, int> kGeoDialCodeIndexByIso2 = <GeoCountryIso2, int>{',
    );
  for (var i = 0; i < keys.length; i++) {
    b.writeln('  GeoCountryIso2.${keys[i].toUpperCase()}: $i,');
  }
  b.writeln('};');
  return b.toString();
}

String _emitCurrenciesTable(Map<String, Object?> currenciesDoc) {
  final currencies = (currenciesDoc['currencies'] as Map)
      .cast<String, Object?>();
  final codes = currencies.keys.toList()..sort();

  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/currencies.json')
    ..writeln('// Canonical currencies list + code->index lookup.')
    ..writeln()
    ..writeln("import '../../models/geo_currency.dart';")
    ..writeln()
    ..writeln('const List<GeoCurrency> kGeoCurrencies = <GeoCurrency>[');

  for (final code in codes) {
    final c = (currencies[code] as Map).cast<String, Object?>();
    final sym = c['symbol'] as String?;
    b.writeln(
      '  GeoCurrency(code: ${_dartStr(c['code'] as String)}, name: ${_dartStr(c['name'] as String)}, symbol: ${sym == null ? 'null' : _dartStr(sym)}),',
    );
  }

  b
    ..writeln('];')
    ..writeln()
    ..writeln(
      'const Map<String, int> kGeoCurrencyIndexByCode = <String, int>{',
    );
  for (var i = 0; i < codes.length; i++) {
    b.writeln('  ${_dartStr(codes[i])}: $i,');
  }
  b.writeln('};');
  return b.toString();
}

String _emitCurrencyByCountry(Map<String, Object?> currenciesDoc) {
  final map = (currenciesDoc['currencyCodeByCountryIso2'] as Map)
      .cast<String, Object?>();
  final keys = map.keys.toList()..sort();

  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/currencies.json (currencyCodeByCountryIso2)')
    ..writeln()
    ..writeln("import '../../models/geo_country_iso2.dart';")
    ..writeln()
    ..writeln(
      'const Map<GeoCountryIso2, String> kGeoCurrencyCodeByCountry = <GeoCountryIso2, String>{',
    );

  for (final iso in keys) {
    final code = map[iso] as String;
    b.writeln('  GeoCountryIso2.${iso.toUpperCase()}: ${_dartStr(code)},');
  }
  b.writeln('};');
  return b.toString();
}

String _emitCountriesByCurrency(Map<String, Object?> currenciesDoc) {
  final map = (currenciesDoc['countryIso2sByCurrencyCode'] as Map)
      .cast<String, Object?>();
  final codes = map.keys.toList()..sort();

  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/currencies.json (countryIso2sByCurrencyCode)')
    ..writeln()
    ..writeln("import '../../models/geo_country_iso2.dart';")
    ..writeln()
    ..writeln(
      'const Map<String, List<GeoCountryIso2>> kGeoCountriesByCurrencyCode = <String, List<GeoCountryIso2>>{',
    );

  for (final code in codes) {
    final isos = (map[code] as List)
        .cast<String>()
        .map((e) => 'GeoCountryIso2.${e.toUpperCase()}')
        .join(', ');
    b.writeln('  ${_dartStr(code)}: <GeoCountryIso2>[$isos],');
  }
  b.writeln('};');
  return b.toString();
}

String _emitStatesBucket(String bucket, List<Map<String, Object?>> states) {
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/states/${bucket.toLowerCase()}.json')
    ..writeln()
    ..writeln("import '../../../models/geo_country_iso2.dart';")
    ..writeln("import '../../../models/geo_state.dart';")
    ..writeln()
    ..writeln('const List<GeoState> kGeoStates_$bucket = <GeoState>[');

  for (final s in states) {
    final iso = (s['countryIso2'] as String).toUpperCase();
    b.writeln(
      '  GeoState(id: ${_dartStr(s['id'] as String)}, name: ${_dartStr(s['name'] as String)}, countryIso2: GeoCountryIso2.$iso),',
    );
  }
  b.writeln('];');
  return b.toString();
}

String _emitStateById(Map<String, Map<String, Object?>> stateById) {
  final keys = stateById.keys.toList()..sort();
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/states/*.json')
    ..writeln('// Fast stateId -> GeoState lookup.')
    ..writeln()
    ..writeln("import '../../../models/geo_country_iso2.dart';")
    ..writeln("import '../../../models/geo_state.dart';")
    ..writeln()
    ..writeln(
      'const Map<String, GeoState> kGeoStateById = <String, GeoState>{',
    );
  for (final id in keys) {
    final s = stateById[id]!;
    final iso = (s['countryIso2'] as String).toUpperCase();
    b.writeln(
      '  ${_dartStr(id)}: GeoState(id: ${_dartStr(id)}, name: ${_dartStr(s['name'] as String)}, countryIso2: GeoCountryIso2.$iso),',
    );
  }
  b.writeln('};');
  return b.toString();
}

String _emitStatesIndex(
  List<Map<String, Object?>> countries,
  List<String> buckets,
  Map<String, String> countryToBucket,
) {
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/states/*.json')
    ..writeln(
      '// Routes a country ISO2 to the corresponding generated state bucket.',
    )
    ..writeln()
    ..writeln("import '../../../models/geo_country_iso2.dart';")
    ..writeln("import '../../../models/geo_state.dart';");

  for (final bucket in buckets) {
    b.writeln("import 'geo_states_${bucket.toLowerCase()}.g.dart';");
  }

  b
    ..writeln()
    ..writeln(
      'List<GeoState> geoStatesBucketForCountry(GeoCountryIso2 iso2) =>',
    )
    ..writeln('    switch (iso2) {');

  for (final c in countries) {
    final iso = (c['iso2'] as String).toUpperCase();
    final bucket = countryToBucket[iso] ?? 'OTHER';
    b.writeln('      GeoCountryIso2.$iso => kGeoStates_$bucket,');
  }

  b.writeln('    };');
  return b.toString();
}

String _emitCitiesCountry(String iso, List<Map<String, Object?>> cities) {
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/cities/${iso.toLowerCase()}.json')
    ..writeln()
    ..writeln("import '../../../models/geo_city.dart';")
    ..writeln("import '../../../models/geo_country_iso2.dart';")
    ..writeln()
    ..writeln('const List<GeoCity> kGeoCities_$iso = <GeoCity>[');

  for (final c in cities) {
    final iata = c['iata'] as String?;
    b.writeln(
      '  GeoCity('
      'id: ${_dartStr(c['id'] as String)}, '
      'name: ${_dartStr(c['name'] as String)}, '
      'countryIso2: GeoCountryIso2.$iso, '
      'stateId: ${_dartStr(c['stateId'] as String)}, '
      'iata: ${iata == null ? 'null' : _dartStr(iata)}'
      '),',
    );
  }
  b.writeln('];');
  return b.toString();
}

String _emitCitiesCountryIndex(String iso, Map<String, List<int>> idx) {
  final keys = idx.keys.toList()..sort();
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/cities/${iso.toLowerCase()}.json')
    ..writeln('// StateId -> city indices for fast citiesOfState lookups.')
    ..writeln()
    ..writeln(
      'const Map<String, List<int>> kGeoCityIndexByState_$iso = <String, List<int>>{',
    );
  for (final sid in keys) {
    final indices = idx[sid]!.join(', ');
    b.writeln('  ${_dartStr(sid)}: <int>[$indices],');
  }
  b.writeln('};');
  return b.toString();
}

String _emitCitiesIndex(List<String> cityIsoKeys) {
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/cities/*.json')
    ..writeln('// Routes ISO2 to per-country city tables and state-index maps.')
    ..writeln()
    ..writeln("import '../../../models/geo_city.dart';")
    ..writeln("import '../../../models/geo_country_iso2.dart';")
    ..writeln("import '../states/geo_states_lookup.g.dart';");

  for (final iso in cityIsoKeys) {
    b.writeln("import 'geo_cities_${iso.toLowerCase()}.g.dart';");
    b.writeln("import 'geo_cities_${iso.toLowerCase()}_index.g.dart';");
  }

  b
    ..writeln()
    ..writeln('List<GeoCity> geoCitiesOfCountry(GeoCountryIso2 iso2) =>')
    ..writeln('    switch (iso2) {');
  for (final iso in cityIsoKeys) {
    b.writeln('      GeoCountryIso2.$iso => kGeoCities_$iso,');
  }
  // wildcard protects you if a country exists without a cities file
  b
    ..writeln('      _ => const <GeoCity>[],')
    ..writeln('    };')
    ..writeln()
    ..writeln(
      '(List<GeoCity>, List<int>)? geoCityIndicesForState(String stateId) {',
    )
    ..writeln('  final state = kGeoStateById[stateId];')
    ..writeln('  if (state == null) return null;')
    ..writeln()
    ..writeln('  final country = state.countryIso2;')
    ..writeln('  final map = switch (country) {');
  for (final iso in cityIsoKeys) {
    b.writeln('      GeoCountryIso2.$iso => kGeoCityIndexByState_$iso,');
  }
  b
    ..writeln('      _ => null,')
    ..writeln('  };')
    ..writeln('  if (map == null) return null;')
    ..writeln()
    ..writeln('  final indices = map[stateId];')
    ..writeln('  if (indices == null) return null;')
    ..writeln()
    ..writeln('  final cities = geoCitiesOfCountry(country);')
    ..writeln('  return (cities, indices);')
    ..writeln('}');
  return b.toString();
}
