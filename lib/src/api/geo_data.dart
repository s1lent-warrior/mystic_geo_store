import '../models/geo_city.dart';
import '../models/geo_country.dart';
import '../models/geo_country_iso2.dart';
import '../models/geo_currency.dart';
import '../models/geo_dial_code_entry.dart';
import '../models/geo_state.dart';

import 'geo_search.dart';
import '../generated/generated_geo_data.dart';

/// Single entry point for all geo + currency + dialing metadata.
///
/// Data is shipped as compile-time constants generated from a source-of-truth
/// dataset (SoT). No runtime JSON parsing is performed.
abstract interface class GeoData {
  const GeoData();

  /// Singleton instance backed by generated const tables.
  static GeoData get instance => const GeneratedGeoData();

  // Raw datasets
  List<GeoCountry> get countries;
  List<GeoCurrency> get currencies;
  List<GeoDialCodeEntry> get dialCodes;

  // Country
  GeoCountry? countryByIso2(GeoCountryIso2 iso2);

  List<GeoCountry> searchCountries(
    String query, {
    int limit = 50,
    GeoCountrySearchField fields = GeoCountrySearchField.nameAndIso2,
  });

  // State
  List<GeoState> statesOf(GeoCountryIso2 country);
  GeoState? stateById(String stateId);

  List<GeoState> searchStates(
    GeoCountryIso2 country,
    String query, {
    int limit = 50,
  });

  // City
  List<GeoCity> citiesOf(GeoCountryIso2 country);
  List<GeoCity> citiesOfState(String stateId);

  /// Basic substring search for cities (picker-friendly).
  ///
  /// No fuzzy matching or precomputed per-city search fields are used to keep
  /// generated output compact.
  List<GeoCity> searchCities(
    GeoCountryIso2 country,
    String query, {
    String? stateId,
    int limit = 50,
    bool boostPrefixMatches = true,
    GeoCitySearchField fields = GeoCitySearchField.nameAndIata,
  });

  // Currency
  GeoCurrency? currencyByCode(String code);
  GeoCurrency? currencyOf(GeoCountryIso2 country);
  List<GeoCountryIso2> countriesUsingCurrency(String currencyCode);

  List<GeoCurrency> searchCurrencies(
    String query, {
    int limit = 50,
    GeoCurrencySearchField fields = GeoCurrencySearchField.codeNameSymbol,
  });

  // Dial codes
  GeoDialCodeEntry? dialCodeEntryOf(GeoCountryIso2 country);
  List<String> dialCodesOf(GeoCountryIso2 country);

  List<GeoDialCodeEntry> searchDialCodes(
    String query, {
    int limit = 50,
  });
}
