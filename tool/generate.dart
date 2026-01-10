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
/// Optional flags:
///   --emit-models   Also generates entity/model files under `lib/src/models/`.
///   --lenient       Allows missing currency/dial codes:
///                  - In lenient mode, GeoCountry.currencyCode & GeoCountry.dialCode are nullable.
///                  - In strict mode (default), missing mappings fail generation and those fields are non-nullable.
///   --with-meta     Adds `package:meta/meta.dart` import and `@immutable` annotations to generated entity models.
///                  - Only affects files produced by `--emit-models`.
///
/// Dial-code SoT:
/// - Prefers `sot/dial_codes_e164.json` if present
/// - Otherwise falls back to `sot/dial_codes.json`
///
/// New E.164 format is expected to be:
/// {
///   "dialCodeByCountryIso2": { "PK": "+92", "US": "+1" }
/// }
///
/// Legacy format (supported):
/// {
///   "dialCodesByCountryIso2": { "PK": ["+92"], "US": ["+1", "+1340"] }
/// }
Future<void> main(List<String> args) async {
  final input = _arg(args, '--input') ?? _arg(args, '-i');
  final out = _arg(args, '--out') ?? _arg(args, '-o') ?? 'lib';
  final emitModels = _hasFlag(args, '--emit-models');
  final lenient = _hasFlag(args, '--lenient');
  final withMeta = _hasFlag(args, '--with-meta');

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

    await _generate(
      sotDir: sotDir,
      outLibDir: outDir,
      emitModels: emitModels,
      lenient: lenient,
      withMeta: withMeta,
    );

    print('✅ Generated mystic_geo_store sources into: ${outDir.path}');
  } finally {
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
    String input, FileSystemEntityType type) async {
  if (type == FileSystemEntityType.directory) return Directory(input);

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
      outFile.writeAsBytesSync(List<int>.from(content as Iterable));
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
  required bool lenient,
  required bool withMeta,
}) async {
  final strict = !lenient;

  final countriesDoc = _readJsonMap(File('${sotDir.path}/countries.json'));
  final currenciesDoc = _readJsonMap(File('${sotDir.path}/currencies.json'));

  // Dial codes: prefer E.164 SoT file if present.
  final dialE164File = File('${sotDir.path}/dial_codes_e164.json');
  final dialLegacyFile = File('${sotDir.path}/dial_codes.json');

  final dialDoc = dialE164File.existsSync()
      ? _readJsonMap(dialE164File)
      : _readJsonMap(dialLegacyFile);

  final countries =
      (countriesDoc['countries'] as List).cast<Map<String, Object?>>();
  countries.sort(
    (a, b) => (a['iso2'] as String).compareTo(b['iso2'] as String),
  );

  final currencyCodeByCountry =
      (currenciesDoc['currencyCodeByCountryIso2'] as Map?)
              ?.cast<String, Object?>() ??
          <String, Object?>{};

  final dialCodeByIso2 = _extractDialCodeByIso2(dialDoc);

  // STRICT validation
  if (strict) {
    final missingCurrency = <String>[];
    final missingDial = <String>[];

    for (final c in countries) {
      final iso = (c['iso2'] as String).toUpperCase();

      final cc = (currencyCodeByCountry[iso] as String?)?.trim();
      if (cc == null || cc.isEmpty) missingCurrency.add(iso);

      final dc = dialCodeByIso2[iso];
      if (dc == null || dc.isEmpty) missingDial.add(iso);
    }

    if (missingCurrency.isNotEmpty || missingDial.isNotEmpty) {
      stderr.writeln(
        '❌ Generation failed (strict mode). Missing required mappings:',
      );
      if (missingCurrency.isNotEmpty) {
        stderr.writeln(
          '  - Missing currencyCode for ${missingCurrency.length} countries: '
          '${missingCurrency.join(', ')}',
        );
      }
      if (missingDial.isNotEmpty) {
        stderr.writeln(
          '  - Missing dialCode for ${missingDial.length} countries: '
          '${missingDial.join(', ')}',
        );
      }
      stderr.writeln();
      stderr.writeln(
        'Tip: run with --lenient to allow nulls while iterating on SoT.',
      );
      exitCode = 1;
      return;
    }
  }

  // Output dirs
  final modelsDir = Directory('${outLibDir.path}/src/models')
    ..createSync(recursive: true);
  final genDir = Directory('${outLibDir.path}/src/generated')
    ..createSync(recursive: true);
  final dataDir = Directory('${genDir.path}/data')..createSync(recursive: true);
  final citiesDir = Directory('${dataDir.path}/cities')
    ..createSync(recursive: true);
  final statesDir = Directory('${dataDir.path}/states')
    ..createSync(recursive: true);

  // Optionally emit models/entities.
  if (emitModels) {
    _writeFile(
      File('${modelsDir.path}/geo_country.dart'),
      _emitGeoCountryModel(lenient: lenient, withMeta: withMeta),
    );
    _writeFile(
      File('${modelsDir.path}/geo_state.dart'),
      _emitGeoStateModel(withMeta: withMeta),
    );
    _writeFile(
      File('${modelsDir.path}/geo_city.dart'),
      _emitGeoCityModel(withMeta: withMeta),
    );
    _writeFile(
      File('${modelsDir.path}/geo_currency.dart'),
      _emitGeoCurrencyModel(withMeta: withMeta),
    );
    _writeFile(
      File('${modelsDir.path}/geo_dial_code_entry.dart'),
      _emitGeoDialCodeEntryModel(withMeta: withMeta),
    );
  }

  // 1) Enum: GeoCountryIso (always generated)
  _writeFile(
    File('${modelsDir.path}/geo_country_iso.dart'),
    _emitCountryIsoEnum(countries),
  );

  // 2) Enum: GeoCurrencyIso (always generated)
  _writeFile(
    File('${modelsDir.path}/geo_currency_iso.dart'),
    _emitCurrencyIsoEnum(currenciesDoc),
  );

  // 3) Countries table (embeds currencyCode + dialCode)
  _writeFile(
    File('${dataDir.path}/geo_countries.g.dart'),
    _emitCountriesTable(
      countries: countries,
      currencyCodeByCountry: currencyCodeByCountry,
      dialCodeByIso2: dialCodeByIso2,
      lenient: lenient,
    ),
  );

  // 4) Dial codes canonical table
  _writeFile(
    File('${dataDir.path}/geo_dial_codes.g.dart'),
    _emitDialCodesTable(dialCodeByIso2),
  );

  // 5) Currencies + maps
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

  // 6) States buckets + lookup + index
  final statesSotDir = Directory('${sotDir.path}/states');
  final stateFiles = statesSotDir
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

  // 7) Cities per country + indexes
  final citiesSotDir = Directory('${sotDir.path}/cities');
  final cityFiles = citiesSotDir
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

/// Safe single-quoted Dart string literal escaping.
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
// Dial-code extraction
// ---------------------------------------------------------------------------

Map<String, String> _extractDialCodeByIso2(Map<String, Object?> dialDoc) {
  const newKey = 'dialCodeByCountryIso2';
  const legacyKey = 'dialCodesByCountryIso2';

  final map = <String, String>{};

  if (dialDoc[newKey] is Map) {
    final raw = (dialDoc[newKey] as Map).cast<String, Object?>();
    for (final entry in raw.entries) {
      final iso = entry.key.trim().toUpperCase();
      final v = entry.value;

      if (v is String) {
        final dc = _normalizeDialCode(v);
        if (dc != null) map[iso] = dc;
      } else if (v is Map) {
        final mm = v.cast<String, Object?>();
        final s = (mm['dial_code'] ?? mm['dialCode'] ?? mm['code']);
        if (s is String) {
          final dc = _normalizeDialCode(s);
          if (dc != null) map[iso] = dc;
        }
      }
    }
    return map;
  }

  if (dialDoc[legacyKey] is Map) {
    final raw = (dialDoc[legacyKey] as Map).cast<String, Object?>();
    for (final entry in raw.entries) {
      final iso = entry.key.trim().toUpperCase();
      final v = entry.value;

      if (v is List) {
        final list = v.cast<Object?>();
        final first = list.isEmpty ? null : list.first;
        if (first is String) {
          final dc = _normalizeDialCode(first);
          if (dc != null) map[iso] = dc;
        }
      } else if (v is String) {
        final dc = _normalizeDialCode(v);
        if (dc != null) map[iso] = dc;
      }
    }
  }

  return map;
}

String? _normalizeDialCode(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return null;
  if (t.startsWith('+')) return t;
  return '+$t';
}

// ---------------------------------------------------------------------------
// Emitters: Models (optional) — detailed docs + optional @immutable
// ---------------------------------------------------------------------------

String _metaPreamble({required bool withMeta}) {
  if (!withMeta) return '';
  return "import 'package:meta/meta.dart';\n\n";
}

String _immutableAnnotation({required bool withMeta}) {
  return withMeta ? '@immutable\n' : '';
}

String _emitGeoCountryModel({
  required bool lenient,
  required bool withMeta,
}) {
  final currencyType = lenient ? 'String?' : 'String';
  final dialType = lenient ? 'String?' : 'String';

  return '''
${_metaPreamble(withMeta: withMeta)}import 'geo_country_iso.dart';

/// Represents a country/territory entry suitable for UI pickers and lightweight
/// geo-metadata lookups.
///
/// Instances are generated as compile-time constants from the SoT.
///
/// Nullability contract:
/// - strict: [currencyCode] and [dialCode] are non-nullable and generation fails if missing
/// - lenient (`--lenient`): [currencyCode] and [dialCode] are nullable
${_immutableAnnotation(withMeta: withMeta)}class GeoCountry {
  const GeoCountry({
    required this.iso,
    required this.name,
    required this.flag,
    required this.currencyCode,
    required this.dialCode,
  });

  /// ISO 3166-1 alpha-2 country code as an enum.
  final GeoCountryIso iso;

  /// English display name (picker-friendly).
  final String name;

  /// Flag emoji (may be empty).
  final String flag;

  /// ISO 4217 currency code (e.g. "USD").
  final $currencyType currencyCode;

  /// Primary E.164 dial code (e.g. "+92").
  final $dialType dialCode;
}
''';
}

String _emitGeoStateModel({required bool withMeta}) => '''
${_metaPreamble(withMeta: withMeta)}import 'geo_country_iso.dart';

/// First-level administrative division (state/region/province).
///
/// [id] is a SoT-stable identifier referenced by cities.
${_immutableAnnotation(withMeta: withMeta)}class GeoState {
  const GeoState({
    required this.id,
    required this.name,
    required this.countryIso,
  });

  final String id;
  final String name;
  final GeoCountryIso countryIso;
}
''';

String _emitGeoCityModel({required bool withMeta}) => '''
${_metaPreamble(withMeta: withMeta)}import 'geo_country_iso.dart';

/// City entry suitable for pickers and lightweight search.
///
/// [stateId] references a [GeoState.id].
${_immutableAnnotation(withMeta: withMeta)}class GeoCity {
  const GeoCity({
    required this.id,
    required this.name,
    required this.countryIso,
    required this.stateId,
    this.iata,
  });

  final String id;
  final String name;
  final GeoCountryIso countryIso;
  final String stateId;
  final String? iata;
}
''';

String _emitGeoCurrencyModel({required bool withMeta}) => '''
${_metaPreamble(withMeta: withMeta)}/// Currency entry (ISO 4217) for pickers.
///
/// [code] is the canonical identifier (e.g. "USD").
${_immutableAnnotation(withMeta: withMeta)}class GeoCurrency {
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

String _emitGeoDialCodeEntryModel({required bool withMeta}) => '''
${_metaPreamble(withMeta: withMeta)}import 'geo_country_iso.dart';

/// Primary E.164 calling code for a country.
///
/// [dialCode] always includes a leading '+'.
${_immutableAnnotation(withMeta: withMeta)}class GeoDialCodeEntry {
  const GeoDialCodeEntry({
    required this.countryIso,
    required this.dialCode,
  });

  final GeoCountryIso countryIso;
  final String dialCode;
}
''';

// ---------------------------------------------------------------------------
// Emitters: Enums
// ---------------------------------------------------------------------------

String _emitCountryIsoEnum(List<Map<String, Object?>> countries) {
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/countries.json')
    ..writeln()
    ..writeln('/// ISO 3166-1 alpha-2 country codes.')
    ..writeln('///')
    ..writeln(
        '/// Enum cases are uppercase (e.g. `PK`, `US`) to avoid collisions with Dart keywords.')
    ..writeln('enum GeoCountryIso {');

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
    ..writeln('  /// ISO string code, e.g. "PK".')
    ..writeln('  String get code => name;')
    ..writeln()
    ..writeln('  /// Parses [code] into a [GeoCountryIso].')
    ..writeln('  ///')
    ..writeln(
        '  /// Trims and uppercases the input, then resolves via [GeoCountryIso.values.byName].')
    ..writeln('  /// Throws [ArgumentError] if the code is invalid.')
    ..writeln(
        '  factory GeoCountryIso.withCode(String code) => GeoCountryIso._fromCode(code);')
    ..writeln()
    ..writeln('  /// Internal parsing factory.')
    ..writeln('  factory GeoCountryIso._fromCode(String code) {')
    ..writeln('    final normalized = code.trim().toUpperCase();')
    ..writeln('    try {')
    ..writeln('      return GeoCountryIso.values.byName(normalized);')
    ..writeln('    } catch (_) {')
    ..writeln(
        "      throw ArgumentError.value(code, 'code', 'Invalid ISO country code');")
    ..writeln('    }')
    ..writeln('  }')
    ..writeln('}');
  return b.toString();
}

String _emitCurrencyIsoEnum(Map<String, Object?> currenciesDoc) {
  final currencies =
      (currenciesDoc['currencies'] as Map).cast<String, Object?>();
  final codes = currencies.keys.toList()..sort();

  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/currencies.json')
    ..writeln()
    ..writeln('/// ISO 4217 currency codes.')
    ..writeln('///')
    ..writeln(
        '/// Enum cases are uppercase currency codes (e.g. `USD`, `PKR`).')
    ..writeln('enum GeoCurrencyIso {');

  for (final code in codes) {
    final c = (currencies[code] as Map).cast<String, Object?>();
    final name = c['name'] as String;
    final upper = code.toUpperCase();
    b.writeln('  /// $name ($upper)');
    b.writeln('  $upper,');
    b.writeln();
  }

  b
    ..writeln('  ;')
    ..writeln()
    ..writeln('  /// ISO 4217 string code, e.g. "USD".')
    ..writeln('  String get code => name;')
    ..writeln()
    ..writeln('  /// Parses [code] into a [GeoCurrencyIso].')
    ..writeln('  ///')
    ..writeln(
        '  /// Trims and uppercases the input, then resolves via [GeoCurrencyIso.values.byName].')
    ..writeln('  /// Throws [ArgumentError] if the code is invalid.')
    ..writeln(
        '  factory GeoCurrencyIso.withCode(String code) => GeoCurrencyIso._fromCode(code);')
    ..writeln()
    ..writeln('  /// Internal parsing factory.')
    ..writeln('  factory GeoCurrencyIso._fromCode(String code) {')
    ..writeln('    final normalized = code.trim().toUpperCase();')
    ..writeln('    try {')
    ..writeln('      return GeoCurrencyIso.values.byName(normalized);')
    ..writeln('    } catch (_) {')
    ..writeln(
        "      throw ArgumentError.value(code, 'code', 'Invalid ISO 4217 currency code');")
    ..writeln('    }')
    ..writeln('  }')
    ..writeln('}');
  return b.toString();
}

// ---------------------------------------------------------------------------
// Emitters: Generated tables (updated imports + renamed fields)
// ---------------------------------------------------------------------------

String _emitCountriesTable({
  required List<Map<String, Object?>> countries,
  required Map<String, Object?> currencyCodeByCountry,
  required Map<String, String> dialCodeByIso2,
  required bool lenient,
}) {
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln(
        '// Source: sot/countries.json + currencies.json + dial codes SoT')
    ..writeln(
        '// Canonical country list with embedded currencyCode and dialCode.')
    ..writeln()
    ..writeln("import '../../models/geo_country.dart';")
    ..writeln("import '../../models/geo_country_iso.dart';")
    ..writeln()
    ..writeln('const List<GeoCountry> kGeoCountries = <GeoCountry>[');

  for (final c in countries) {
    final iso = (c['iso2'] as String).toUpperCase();
    final name = _dartStr(c['name'] as String);
    final flag = _dartStr((c['flag'] as String?) ?? '');

    final currencyCode = (currencyCodeByCountry[iso] as String?)?.trim();
    final dial = dialCodeByIso2[iso];

    if (!lenient) {
      final currencyLiteral = _dartStr(currencyCode!);
      final dialLiteral = _dartStr(dial!);

      b.writeln(
        '  GeoCountry('
        'iso: GeoCountryIso.$iso, '
        'name: $name, '
        'flag: $flag, '
        'currencyCode: $currencyLiteral, '
        'dialCode: $dialLiteral'
        '),',
      );
    } else {
      final currencyLiteral = (currencyCode == null || currencyCode.isEmpty)
          ? 'null'
          : _dartStr(currencyCode);
      final dialLiteral =
          (dial == null || dial.isEmpty) ? 'null' : _dartStr(dial);

      b.writeln(
        '  GeoCountry('
        'iso: GeoCountryIso.$iso, '
        'name: $name, '
        'flag: $flag, '
        'currencyCode: $currencyLiteral, '
        'dialCode: $dialLiteral'
        '),',
      );
    }
  }

  b
    ..writeln('];')
    ..writeln()
    ..writeln(
      'const Map<GeoCountryIso, int> kGeoCountryIndexByIso = <GeoCountryIso, int>{',
    );

  for (var i = 0; i < countries.length; i++) {
    final iso = (countries[i]['iso2'] as String).toUpperCase();
    b.writeln('  GeoCountryIso.$iso: $i,');
  }
  b.writeln('};');

  return b.toString();
}

String _emitDialCodesTable(Map<String, String> dialCodeByIso2) {
  final keys = dialCodeByIso2.keys.toList()..sort();

  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: dial codes SoT (E.164 primary dial code per ISO2)')
    ..writeln()
    ..writeln("import '../../models/geo_country_iso.dart';")
    ..writeln("import '../../models/geo_dial_code_entry.dart';")
    ..writeln()
    ..writeln(
        'const List<GeoDialCodeEntry> kGeoDialCodes = <GeoDialCodeEntry>[');

  for (final iso in keys) {
    final dial = dialCodeByIso2[iso]!;
    b.writeln(
      '  GeoDialCodeEntry(countryIso: GeoCountryIso.${iso.toUpperCase()}, dialCode: ${_dartStr(dial)}),',
    );
  }

  b
    ..writeln('];')
    ..writeln()
    ..writeln(
      'const Map<GeoCountryIso, int> kGeoDialCodeIndexByIso = <GeoCountryIso, int>{',
    );

  for (var i = 0; i < keys.length; i++) {
    b.writeln('  GeoCountryIso.${keys[i].toUpperCase()}: $i,');
  }
  b.writeln('};');

  return b.toString();
}

// ---- Remaining emitters (same logic, updated imports/types) ----

String _emitCurrenciesTable(Map<String, Object?> currenciesDoc) {
  final currencies =
      (currenciesDoc['currencies'] as Map).cast<String, Object?>();
  final codes = currencies.keys.toList()..sort();

  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/currencies.json')
    ..writeln()
    ..writeln("import '../../models/geo_currency.dart';")
    ..writeln()
    ..writeln('const List<GeoCurrency> kGeoCurrencies = <GeoCurrency>[');

  for (final code in codes) {
    final c = (currencies[code] as Map).cast<String, Object?>();
    final sym = c['symbol'] as String?;
    b.writeln(
      '  GeoCurrency('
      'code: ${_dartStr(c['code'] as String)}, '
      'name: ${_dartStr(c['name'] as String)}, '
      'symbol: ${sym == null ? 'null' : _dartStr(sym)}'
      '),',
    );
  }

  b
    ..writeln('];')
    ..writeln()
    ..writeln(
        'const Map<String, int> kGeoCurrencyIndexByCode = <String, int>{');

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
    ..writeln("import '../../models/geo_country_iso.dart';")
    ..writeln()
    ..writeln(
        'const Map<GeoCountryIso, String> kGeoCurrencyCodeByCountry = <GeoCountryIso, String>{');

  for (final iso in keys) {
    final code = map[iso] as String;
    b.writeln('  GeoCountryIso.${iso.toUpperCase()}: ${_dartStr(code)},');
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
    ..writeln("import '../../models/geo_country_iso.dart';")
    ..writeln()
    ..writeln(
        'const Map<String, List<GeoCountryIso>> kGeoCountriesByCurrencyCode = <String, List<GeoCountryIso>>{');

  for (final code in codes) {
    final isos = (map[code] as List)
        .cast<String>()
        .map((e) => 'GeoCountryIso.${e.toUpperCase()}')
        .join(', ');
    b.writeln('  ${_dartStr(code)}: <GeoCountryIso>[$isos],');
  }
  b.writeln('};');

  return b.toString();
}

String _emitStatesBucket(String bucket, List<Map<String, Object?>> states) {
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: sot/states/${bucket.toLowerCase()}.json')
    ..writeln()
    ..writeln("import '../../../models/geo_country_iso.dart';")
    ..writeln("import '../../../models/geo_state.dart';")
    ..writeln()
    ..writeln('const List<GeoState> kGeoStates_$bucket = <GeoState>[');

  for (final s in states) {
    final iso = (s['countryIso2'] as String).toUpperCase();
    b.writeln(
      '  GeoState('
      'id: ${_dartStr(s['id'] as String)}, '
      'name: ${_dartStr(s['name'] as String)}, '
      'countryIso: GeoCountryIso.$iso'
      '),',
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
    ..writeln()
    ..writeln("import '../../../models/geo_country_iso.dart';")
    ..writeln("import '../../../models/geo_state.dart';")
    ..writeln()
    ..writeln(
        'const Map<String, GeoState> kGeoStateById = <String, GeoState>{');

  for (final id in keys) {
    final s = stateById[id]!;
    final iso = (s['countryIso2'] as String).toUpperCase();
    b.writeln(
      '  ${_dartStr(id)}: GeoState('
      'id: ${_dartStr(id)}, '
      'name: ${_dartStr(s['name'] as String)}, '
      'countryIso: GeoCountryIso.$iso'
      '),',
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
    ..writeln()
    ..writeln("import '../../../models/geo_country_iso.dart';")
    ..writeln("import '../../../models/geo_state.dart';");

  for (final bucket in buckets) {
    b.writeln("import 'geo_states_${bucket.toLowerCase()}.g.dart';");
  }

  b
    ..writeln()
    ..writeln('List<GeoState> geoStatesBucketForCountry(GeoCountryIso iso) =>')
    ..writeln('    switch (iso) {');

  for (final c in countries) {
    final iso = (c['iso2'] as String).toUpperCase();
    final bucket = countryToBucket[iso] ?? 'OTHER';
    b.writeln('      GeoCountryIso.$iso => kGeoStates_$bucket,');
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
    ..writeln("import '../../../models/geo_country_iso.dart';")
    ..writeln()
    ..writeln('const List<GeoCity> kGeoCities_$iso = <GeoCity>[');

  for (final c in cities) {
    final iata = c['iata'] as String?;
    b.writeln(
      '  GeoCity('
      'id: ${_dartStr(c['id'] as String)}, '
      'name: ${_dartStr(c['name'] as String)}, '
      'countryIso: GeoCountryIso.$iso, '
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
    ..writeln()
    ..writeln(
        'const Map<String, List<int>> kGeoCityIndexByState_$iso = <String, List<int>>{');

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
    ..writeln()
    ..writeln("import '../../../models/geo_city.dart';")
    ..writeln("import '../../../models/geo_country_iso.dart';")
    ..writeln("import '../states/geo_states_lookup.g.dart';");

  for (final iso in cityIsoKeys) {
    b.writeln("import 'geo_cities_${iso.toLowerCase()}.g.dart';");
    b.writeln("import 'geo_cities_${iso.toLowerCase()}_index.g.dart';");
  }

  b
    ..writeln()
    ..writeln('List<GeoCity> geoCitiesOfCountry(GeoCountryIso iso) =>')
    ..writeln('    switch (iso) {');

  for (final iso in cityIsoKeys) {
    b.writeln('      GeoCountryIso.$iso => kGeoCities_$iso,');
  }

  b
    ..writeln('      _ => const <GeoCity>[],')
    ..writeln('    };')
    ..writeln()
    ..writeln(
        '(List<GeoCity>, List<int>)? geoCityIndicesForState(String stateId) {')
    ..writeln('  final state = kGeoStateById[stateId];')
    ..writeln('  if (state == null) return null;')
    ..writeln()
    ..writeln('  final country = state.countryIso;')
    ..writeln('  final map = switch (country) {');

  for (final iso in cityIsoKeys) {
    b.writeln('      GeoCountryIso.$iso => kGeoCityIndexByState_$iso,');
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
