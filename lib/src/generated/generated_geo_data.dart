import '../api/geo_search.dart';
import '../api/geo_store.dart';
import '../models/geo_city.dart';
import '../models/geo_country.dart';
import '../models/geo_country_iso2.dart';
import '../models/geo_currency.dart';
import '../models/geo_dial_code_entry.dart';
import '../models/geo_state.dart';

import 'data/geo_countries.g.dart';
import 'data/geo_currencies.g.dart';
import 'data/geo_dial_codes.g.dart';
import 'data/geo_country_currency.g.dart';
import 'data/geo_currency_countries.g.dart';
import 'data/states/geo_states_index.g.dart';
import 'data/states/geo_states_lookup.g.dart';
import 'data/cities/geo_cities_index.g.dart';

/// Generated implementation of [GeoStore] backed by const tables.
///
/// This file is small and hand-maintained; the heavy datasets live under
/// `lib/src/generated/data/**` and are regenerated from the SoT dataset.
class GeneratedGeoStore implements GeoStore {
  const GeneratedGeoStore();

  @override
  List<GeoCountry> get countries => kGeoCountries;

  @override
  List<GeoCurrency> get currencies => kGeoCurrencies;

  @override
  List<GeoDialCodeEntry> get dialCodes => kGeoDialCodes;

  @override
  GeoCountry? countryByIso2(GeoCountryIso2 iso2) {
    final idx = kGeoCountryIndexByIso2[iso2];
    return idx == null ? null : kGeoCountries[idx];
  }

  @override
  List<GeoCountry> searchCountries(
    String query, {
    int limit = 50,
    GeoCountrySearchField fields = GeoCountrySearchField.nameAndIso2,
  }) {
    final q = geoNormalizeSearch(query);
    if (q.isEmpty) return const <GeoCountry>[];

    final qIso = q.toUpperCase();
    final out = <GeoCountry>[];
    for (final c in kGeoCountries) {
      if (out.length >= limit) break;

      final name = geoNormalizeSearch(c.name);
      final hit = switch (fields) {
        GeoCountrySearchField.nameOnly => name.contains(q),
        GeoCountrySearchField.nameAndIso2 =>
          name.contains(q) || c.iso2.code.contains(qIso),
      };
      if (hit) out.add(c);
    }
    return List<GeoCountry>.unmodifiable(out);
  }

  @override
  List<GeoState> statesOf(GeoCountryIso2 country) {
    final bucket = geoStatesBucketForCountry(country);
    final filtered = <GeoState>[];
    for (final s in bucket) {
      if (s.countryIso2 == country) filtered.add(s);
    }
    return List<GeoState>.unmodifiable(filtered);
  }

  @override
  GeoState? stateById(String stateId) => kGeoStateById[stateId];

  @override
  List<GeoState> searchStates(
    GeoCountryIso2 country,
    String query, {
    int limit = 50,
  }) {
    final q = geoNormalizeSearch(query);
    if (q.isEmpty) return const <GeoState>[];

    final out = <GeoState>[];
    for (final s in statesOf(country)) {
      if (out.length >= limit) break;
      if (geoNormalizeSearch(s.name).contains(q)) out.add(s);
    }
    return List<GeoState>.unmodifiable(out);
  }

  @override
  List<GeoCity> citiesOf(GeoCountryIso2 country) => geoCitiesOfCountry(country);

  @override
  List<GeoCity> citiesOfState(String stateId) {
    final idx = geoCityIndicesForState(stateId);
    if (idx == null) return const <GeoCity>[];

    final (cities, indices) = idx;
    final out = <GeoCity>[];
    for (final i in indices) {
      out.add(cities[i]);
    }
    return List<GeoCity>.unmodifiable(out);
  }

  @override
  List<GeoCity> searchCities(
    GeoCountryIso2 country,
    String query, {
    String? stateId,
    int limit = 50,
    bool boostPrefixMatches = true,
    GeoCitySearchField fields = GeoCitySearchField.nameAndIata,
  }) {
    final q = geoNormalizeSearch(query);
    if (q.isEmpty) return const <GeoCity>[];

    final Iterable<GeoCity> base =
        stateId == null ? citiesOf(country) : citiesOfState(stateId);

    final out = <GeoCity>[];
    final seenIds = <String>{};

    bool iataHit(GeoCity c, bool Function(String) test) {
      final iata = c.iata;
      if (iata == null || iata.isEmpty) return false;
      return test(geoNormalizeSearch(iata));
    }

    bool prefixOk(GeoCity c) {
      final n = geoNormalizeSearch(c.name);
      if (n.startsWith(q)) return true;
      return fields == GeoCitySearchField.nameAndIata &&
          iataHit(c, (s) => s.startsWith(q));
    }

    bool containsOk(GeoCity c) {
      final n = geoNormalizeSearch(c.name);
      if (n.contains(q)) return true;
      return fields == GeoCitySearchField.nameAndIata &&
          iataHit(c, (s) => s.contains(q));
    }

    if (boostPrefixMatches) {
      for (final c in base) {
        if (out.length >= limit) break;
        if (prefixOk(c)) {
          out.add(c);
          seenIds.add(c.id);
        }
      }
    }

    for (final c in base) {
      if (out.length >= limit) break;
      if (boostPrefixMatches && seenIds.contains(c.id)) continue;
      if (containsOk(c)) out.add(c);
    }

    return List<GeoCity>.unmodifiable(out);
  }

  @override
  GeoCurrency? currencyByCode(String code) {
    final normalized = code.trim().toUpperCase();
    final idx = kGeoCurrencyIndexByCode[normalized];
    return idx == null ? null : kGeoCurrencies[idx];
  }

  @override
  GeoCurrency? currencyOf(GeoCountryIso2 country) {
    final currencyCode = kGeoCurrencyCodeByCountry[country];
    return currencyCode == null ? null : currencyByCode(currencyCode);
  }

  @override
  List<GeoCountryIso2> countriesUsingCurrency(String currencyCode) {
    final code = currencyCode.trim().toUpperCase();
    final list = kGeoCountriesByCurrencyCode[code];
    return list == null
        ? const <GeoCountryIso2>[]
        : List<GeoCountryIso2>.unmodifiable(list);
  }

  @override
  List<GeoCurrency> searchCurrencies(
    String query, {
    int limit = 50,
    GeoCurrencySearchField fields = GeoCurrencySearchField.codeNameSymbol,
  }) {
    final q = geoNormalizeSearch(query);
    if (q.isEmpty) return const <GeoCurrency>[];

    final qCode = q.toUpperCase();
    final out = <GeoCurrency>[];
    for (final cur in kGeoCurrencies) {
      if (out.length >= limit) break;

      final code = cur.code.toUpperCase();
      final name = geoNormalizeSearch(cur.name);
      final sym = cur.symbol == null ? '' : geoNormalizeSearch(cur.symbol!);

      final hit = switch (fields) {
        GeoCurrencySearchField.codeOnly => code.contains(qCode),
        GeoCurrencySearchField.codeAndName =>
          code.contains(qCode) || name.contains(q),
        GeoCurrencySearchField.codeNameSymbol =>
          code.contains(qCode) || name.contains(q) || sym.contains(q),
      };

      if (hit) out.add(cur);
    }
    return List<GeoCurrency>.unmodifiable(out);
  }

  @override
  GeoDialCodeEntry? dialCodeEntryOf(GeoCountryIso2 country) {
    final idx = kGeoDialCodeIndexByIso2[country];
    return idx == null ? null : kGeoDialCodes[idx];
  }

  @override
  List<String> dialCodesOf(GeoCountryIso2 country) {
    final entry = dialCodeEntryOf(country);
    final list = entry?.dialCodes;
    return list == null ? const <String>[] : List<String>.unmodifiable(list);
  }

  @override
  List<GeoDialCodeEntry> searchDialCodes(
    String query, {
    int limit = 50,
  }) {
    final qRaw = query.trim();
    final q = geoNormalizeSearch(qRaw);
    if (q.isEmpty) return const <GeoDialCodeEntry>[];

    final out = <GeoDialCodeEntry>[];
    final qNoPlus = qRaw.replaceAll('+', '').trim();

    for (final e in kGeoDialCodes) {
      if (out.length >= limit) break;

      final c = countryByIso2(e.countryIso2);
      final countryName = c == null ? '' : geoNormalizeSearch(c.name);

      final isoHit = e.countryIso2.code.contains(qRaw.toUpperCase());
      final nameHit = countryName.contains(q);
      final dialHit = e.dialCodes.any((d) {
        final dn = d.replaceAll('+', '');
        return d.contains(qRaw) ||
            dn.startsWith(qNoPlus) ||
            dn.contains(qNoPlus);
      });

      if (isoHit || nameHit || dialHit) out.add(e);
    }

    return List<GeoDialCodeEntry>.unmodifiable(out);
  }
}
