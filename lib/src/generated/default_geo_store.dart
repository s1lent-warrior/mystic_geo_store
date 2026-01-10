import 'dart:collection';

import '../api/geo_search.dart';
import '../api/geo_store.dart';

import '../models/geo_city.dart';
import '../models/geo_country.dart';
import '../models/geo_country_iso.dart';
import '../models/geo_currency.dart';
import '../models/geo_currency_iso.dart';
import '../models/geo_dial_code_entry.dart';
import '../models/geo_state.dart';

import 'data/geo_countries.g.dart';
import 'data/geo_currencies.g.dart';
import 'data/geo_country_currency.g.dart';
import 'data/geo_currency_countries.g.dart';
import 'data/geo_dial_codes.g.dart';

import 'data/states/geo_states_index.g.dart';
import 'data/states/geo_states_lookup.g.dart';

import 'data/cities/geo_cities_index.g.dart';

/// Default [GeoStore] implementation backed by generated const tables.
///
/// This class contains no runtime parsing and is safe to use in Flutter isolates
/// and pure Dart contexts.
class DefaultGeoStore with StringSearchable implements GeoStore {
  const DefaultGeoStore();

  // ---------------------------------------------------------------------------
  // Raw datasets
  // ---------------------------------------------------------------------------

  @override
  List<GeoCountry> get countries => kGeoCountries;

  @override
  List<GeoCurrency> get currencies => kGeoCurrencies;

  @override
  List<GeoDialCodeEntry> get dialCodes => kGeoDialCodes;

  // ---------------------------------------------------------------------------
  // Country
  // ---------------------------------------------------------------------------

  @override
  GeoCountry countryByIso(GeoCountryIso iso) {
    final i = kGeoCountryIndexByIso[iso];
    if (i == null) {
      throw StateError(
        'GeoStore inconsistent: no country index for ${iso.code}.',
      );
    }
    return kGeoCountries[i];
  }

  @override
  GeoCountry? countryByNameOrNull(String name) {
    final q = name.trim();
    if (q.isEmpty) return null;

    final normalized = normalizeSearch(q);

    for (final c in kGeoCountries) {
      if (normalizeSearch(c.name) == normalized) return c;
    }
    return null;
  }

  @override
  GeoCountry countryByName(String name) {
    final country = countryByNameOrNull(name);
    if (country != null) return country;
    throw ArgumentError.value(name, 'name', 'Country not found for name $name');
  }

  @override
  List<GeoCountry> searchCountries(
    String query, {
    int? limit = 50,
    GeoCountrySearchField fields = GeoCountrySearchField.nameAndIso,
  }) {
    // `null` => no limit
    // `<= 0` => empty (caller explicitly asked for none)
    if (limit != null && limit <= 0) return const <GeoCountry>[];

    final qRaw = query.trim();
    final q = normalizeSearch(qRaw);
    if (q.isEmpty) return const <GeoCountry>[];

    final qUpper = qRaw.toUpperCase();
    final hasLimit = limit != null;

    final out = <GeoCountry>[];
    for (final c in kGeoCountries) {
      if (hasLimit && out.length >= limit) break;

      final nameHit = switch (fields) {
        GeoCountrySearchField.name ||
        GeoCountrySearchField.nameAndIso =>
          normalizeSearch(c.name).contains(q),
        _ => false,
      };

      final isoHit = switch (fields) {
        GeoCountrySearchField.iso ||
        GeoCountrySearchField.nameAndIso =>
          c.iso.code.contains(qUpper),
        _ => false,
      };

      if (nameHit || isoHit) out.add(c);
    }

    return List<GeoCountry>.unmodifiable(out);
  }

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  @override
  List<GeoState> statesOf(GeoCountryIso country) {
    final list = geoStatesBucketForCountry(country);
    // Ensure consumers cannot mutate.
    return list is UnmodifiableListView<GeoState>
        ? list
        : List<GeoState>.unmodifiable(list);
  }

  @override
  GeoState? stateById(String stateId) => kGeoStateById[stateId];

  @override
  List<GeoState> searchStates(
    GeoCountryIso country,
    String query, {
    int? limit = 50,
  }) {
    if (limit != null && limit <= 0) return const <GeoState>[];

    final q = normalizeSearch(query.trim());
    if (q.isEmpty) return const <GeoState>[];

    final hasLimit = limit != null;

    final out = <GeoState>[];
    for (final s in geoStatesBucketForCountry(country)) {
      if (hasLimit && out.length >= limit) break;
      if (normalizeSearch(s.name).contains(q)) out.add(s);
    }
    return List<GeoState>.unmodifiable(out);
  }

  // ---------------------------------------------------------------------------
  // City
  // ---------------------------------------------------------------------------

  @override
  List<GeoCity> citiesOf(GeoCountryIso country) {
    final list = geoCitiesOfCountry(country);
    return list is UnmodifiableListView<GeoCity>
        ? list
        : List<GeoCity>.unmodifiable(list);
  }

  @override
  List<GeoCity> citiesOfState(String stateId) {
    final hit = geoCityIndicesForState(stateId);
    if (hit == null) return const <GeoCity>[];

    final (cities, indices) = hit;
    if (indices.isEmpty) return const <GeoCity>[];

    final out = <GeoCity>[];
    for (final i in indices) {
      if (i < 0 || i >= cities.length) continue;
      out.add(cities[i]);
    }
    return List<GeoCity>.unmodifiable(out);
  }

  @override
  List<GeoCity> searchCities(
    GeoCountryIso country,
    String query, {
    String? stateId,
    int? limit = 50,
    bool boostPrefixMatches = true,
    GeoCitySearchField fields = GeoCitySearchField.nameAndIata,
  }) {
    if (limit != null && limit <= 0) return const <GeoCity>[];

    final qRaw = query.trim();
    final q = normalizeSearch(qRaw);
    if (q.isEmpty) return const <GeoCity>[];

    final hasLimit = limit != null;
    final qUpper = qRaw.toUpperCase();

    Iterable<GeoCity> base;
    if (stateId != null && stateId.trim().isNotEmpty) {
      base = citiesOfState(stateId.trim());
    } else {
      base = geoCitiesOfCountry(country);
    }

    bool hit(GeoCity c) {
      final nameHit = switch (fields) {
        GeoCitySearchField.name ||
        GeoCitySearchField.nameAndIata =>
          normalizeSearch(c.name).contains(q),
        _ => false,
      };

      final iataHit = switch (fields) {
        GeoCitySearchField.iata ||
        GeoCitySearchField.nameAndIata =>
          (c.iata ?? '').toUpperCase().contains(qUpper),
        _ => false,
      };

      return nameHit || iataHit;
    }

    int score(GeoCity c) {
      if (!boostPrefixMatches) return 0;
      final n = normalizeSearch(c.name);
      if (n.startsWith(q)) return 2;
      if (n.contains(q)) return 1;
      return 0;
    }

    final matches = <GeoCity>[];
    for (final c in base) {
      if (hit(c)) matches.add(c);

      // Keep memory bounded for very broad queries.
      // When limit is null, fall back to a conservative cap.
      final cap = hasLimit ? (limit * 5) : 5000;
      if (matches.length > cap) break;
    }

    if (boostPrefixMatches) {
      matches.sort((a, b) => score(b).compareTo(score(a)));
    }

    if (hasLimit && matches.length > limit) {
      return List<GeoCity>.unmodifiable(matches.take(limit).toList());
    }

    return List<GeoCity>.unmodifiable(matches);
  }

  // ---------------------------------------------------------------------------
  // Currency
  // ---------------------------------------------------------------------------

  @override
  GeoCurrency currencyByCode(GeoCurrencyIso code) {
    final i = kGeoCurrencyIndexByCode[code.code];
    if (i == null) {
      throw StateError(
        'GeoStore inconsistent: no currency index for ${code.code}.',
      );
    }
    return kGeoCurrencies[i];
  }

  @override
  GeoCurrency currencyOf(GeoCountryIso country) {
    final codeStr = kGeoCurrencyCodeByCountry[country];
    if (codeStr == null || codeStr.trim().isEmpty) {
      throw StateError(
        'No currency mapping for country ${country.code}. '
        'If you are using a lenient dataset, handle this case.',
      );
    }
    return currencyByCode(GeoCurrencyIso.withCode(codeStr));
  }

  @override
  List<GeoCountryIso> countriesUsingCurrency(GeoCurrencyIso currencyCode) {
    final list = kGeoCountriesByCurrencyCode[currencyCode.code] ?? const [];
    return list is UnmodifiableListView<GeoCountryIso>
        ? list
        : List<GeoCountryIso>.unmodifiable(list);
  }

  @override
  List<GeoCurrency> searchCurrencies(
    String query, {
    int? limit = 50,
    GeoCurrencySearchField fields = GeoCurrencySearchField.codeNameSymbol,
  }) {
    if (limit != null && limit <= 0) return const <GeoCurrency>[];

    final qRaw = query.trim();
    final q = normalizeSearch(qRaw);
    if (q.isEmpty) return const <GeoCurrency>[];

    final hasLimit = limit != null;
    final qUpper = qRaw.toUpperCase();

    final out = <GeoCurrency>[];
    for (final c in kGeoCurrencies) {
      if (hasLimit && out.length >= limit) break;

      final codeHit = switch (fields) {
        GeoCurrencySearchField.code ||
        GeoCurrencySearchField.codeNameSymbol =>
          c.code.toUpperCase().contains(qUpper),
        _ => false,
      };

      final nameHit = switch (fields) {
        GeoCurrencySearchField.name ||
        GeoCurrencySearchField.codeNameSymbol =>
          normalizeSearch(c.name).contains(q),
        _ => false,
      };

      final symbolHit = switch (fields) {
        GeoCurrencySearchField.symbol ||
        GeoCurrencySearchField.codeNameSymbol =>
          (c.symbol ?? '').contains(qRaw),
        _ => false,
      };

      if (codeHit || nameHit || symbolHit) out.add(c);
    }

    return List<GeoCurrency>.unmodifiable(out);
  }

  // ---------------------------------------------------------------------------
  // Dial codes
  // ---------------------------------------------------------------------------

  @override
  GeoDialCodeEntry? dialCodeEntryOf(GeoCountryIso country) {
    final i = kGeoDialCodeIndexByIso[country];
    if (i == null) return null;
    return kGeoDialCodes[i];
  }

  @override
  List<GeoDialCodeEntry> searchDialCodes(
    String query, {
    int? limit = 50,
  }) {
    if (limit != null && limit <= 0) return const <GeoDialCodeEntry>[];

    final qRaw = query.trim();
    final q = normalizeSearch(qRaw);
    if (q.isEmpty) return const <GeoDialCodeEntry>[];

    final hasLimit = limit != null;
    final qUpper = qRaw.toUpperCase();
    final qDigits =
        qRaw.replaceAll('+', '').replaceAll(RegExp(r'\D'), '').trim();

    final out = <GeoDialCodeEntry>[];
    for (final e in kGeoDialCodes) {
      if (hasLimit && out.length >= limit) break;

      final country = countryByIso(e.countryIso);
      final countryName = normalizeSearch(country.name);

      final isoHit = e.countryIso.code.contains(qUpper);
      final nameHit = countryName.contains(q);

      final dial = e.dialCode; // e.g. "+92"
      final dialDigits = dial.replaceAll('+', '').replaceAll(RegExp(r'\D'), '');
      final dialHit = dial.contains(qRaw) ||
          (qDigits.isNotEmpty && dialDigits.startsWith(qDigits));

      if (isoHit || nameHit || dialHit) out.add(e);
    }

    return List<GeoDialCodeEntry>.unmodifiable(out);
  }
}
