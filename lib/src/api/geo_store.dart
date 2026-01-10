import '../models/geo_city.dart';
import '../models/geo_country.dart';
import '../models/geo_country_iso.dart';
import '../models/geo_currency.dart';
import '../models/geo_currency_iso.dart';
import '../models/geo_dial_code_entry.dart';
import '../models/geo_state.dart';

import '../generated/default_geo_store.dart';
import 'geo_search.dart';

/// Single entry point for all geo + currency + dialing metadata.
///
/// ## Key characteristics
/// - Data is shipped as **compile-time constants** generated from a
///   source-of-truth dataset (SoT).
/// - No runtime JSON parsing is performed.
/// - Lookups are backed by generated indexes for fast access.
/// - Search methods are "picker-friendly": deterministic and lightweight.
///
/// ## Strict vs lenient datasets
/// The generator supports a `--lenient` mode while curating SoT.
/// In lenient builds, some mappings (currency/dial) can be missing for a country.
/// The store API is designed so that:
/// - `countryByIso(...)` always returns a country (because countries are canonical).
/// - `currencyOf(...)` / `dialCodeEntryOf(...)` may throw/return null if SoT is incomplete.
///   (See documentation of each member.)
abstract interface class GeoStore {
  const GeoStore();

  /// Singleton instance backed by generated const tables.
  ///
  /// This is the recommended entry point for most apps:
  /// `final store = GeoStore.instance;`
  static GeoStore get instance => const DefaultGeoStore();

  // ---------------------------------------------------------------------------
  // Raw datasets
  // ---------------------------------------------------------------------------

  /// Canonical list of all countries in the dataset.
  ///
  /// The returned list is unmodifiable.
  List<GeoCountry> get countries;

  /// Canonical list of all currencies in the dataset.
  ///
  /// The returned list is unmodifiable.
  List<GeoCurrency> get currencies;

  /// Canonical list of dial-code entries in the dataset (primary E.164 code per country).
  ///
  /// The returned list is unmodifiable.
  List<GeoDialCodeEntry> get dialCodes;

  // ---------------------------------------------------------------------------
  // Country
  // ---------------------------------------------------------------------------

  /// Returns the [GeoCountry] for the given [GeoCountryIso].
  ///
  /// This is a total mapping for the current dataset:
  /// - If your SoT contains a country code enum case, a country entry exists.
  ///
  /// Throws:
  /// - [StateError] if the SoT / generated indexes are inconsistent.
  GeoCountry countryByIso(GeoCountryIso iso);

  /// Returns the country whose normalized name matches [name], or `null` if none.
  ///
  /// This is an exact match after applying the same normalization used by searches
  /// (lowercasing, punctuation stripping, whitespace collapsing).
  GeoCountry? countryByNameOrNull(String name);

  /// Returns the country whose normalized name matches [name].
  /// May throw ArgumentError if no country is found with the given name.
  ///
  /// This is an exact match after applying the same normalization used by searches
  /// (lowercasing, punctuation stripping, whitespace collapsing).
  GeoCountry countryByName(String name);

  /// Searches countries using a lightweight, deterministic strategy suitable for pickers.
  ///
  /// Matching is performed against a chosen subset of fields:
  /// - country display name
  /// - ISO code
  ///
  /// Parameters:
  /// - [query] raw user input (trimmed internally).
  /// - [limit] max number of results to return (defaults to 50).
  /// - [fields] which fields to match against.
  ///
  /// Returns an unmodifiable list. Empty query returns empty list.
  List<GeoCountry> searchCountries(
    String query, {
    int limit = 50,
    GeoCountrySearchField fields = GeoCountrySearchField.nameAndIso,
  });

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// Returns all states for [country].
  ///
  /// The returned list is unmodifiable.
  ///
  /// Note: some countries may have zero states in the SoT.
  List<GeoState> statesOf(GeoCountryIso country);

  /// Returns a state by its SoT-stable [stateId], or `null` if not found.
  GeoState? stateById(String stateId);

  /// Searches states within a single [country].
  ///
  /// Search is a simple normalized substring match over state name.
  /// Returns an unmodifiable list. Empty query returns empty list.
  List<GeoState> searchStates(
    GeoCountryIso country,
    String query, {
    int limit = 50,
  });

  // ---------------------------------------------------------------------------
  // City
  // ---------------------------------------------------------------------------

  /// Returns all cities for [country].
  ///
  /// The returned list is unmodifiable.
  List<GeoCity> citiesOf(GeoCountryIso country);

  /// Returns cities that belong to the state with [stateId].
  ///
  /// Returns an unmodifiable list. If [stateId] is not found, returns an empty list.
  List<GeoCity> citiesOfState(String stateId);

  /// Basic substring search for cities (picker-friendly).
  ///
  /// No fuzzy matching or precomputed per-city search fields are used to keep
  /// generated output compact.
  ///
  /// Parameters:
  /// - [country] restricts search to a country (keeps search fast for large datasets).
  /// - [query] raw user input; empty query returns empty list.
  /// - [stateId] optional filter to a specific state.
  /// - [limit] maximum number of results.
  /// - [boostPrefixMatches] whether to rank prefix matches earlier (simple UX boost).
  /// - [fields] which fields to match against (name / IATA).
  ///
  /// Returns an unmodifiable list.
  List<GeoCity> searchCities(
    GeoCountryIso country,
    String query, {
    String? stateId,
    int limit = 50,
    bool boostPrefixMatches = true,
    GeoCitySearchField fields = GeoCitySearchField.nameAndIata,
  });

  // ---------------------------------------------------------------------------
  // Currency
  // ---------------------------------------------------------------------------

  /// Returns the currency model for a currency code enum.
  ///
  /// This is expected to be total for the dataset (all enum cases exist in currency table).
  /// Throws [StateError] if generated indexes are inconsistent.
  GeoCurrency currencyByCode(GeoCurrencyIso code);

  /// Returns the currency used by [country].
  ///
  /// In strict datasets, this always succeeds.
  ///
  /// In lenient datasets, this may throw [StateError] if the country has no currency mapping.
  GeoCurrency currencyOf(GeoCountryIso country);

  /// Returns all countries that use [currencyCode].
  ///
  /// In strict datasets, this returns at least one country for most real currencies.
  /// The returned list is unmodifiable.
  List<GeoCountryIso> countriesUsingCurrency(GeoCurrencyIso currencyCode);

  /// Searches currencies (picker-friendly).
  ///
  /// Uses normalized substring matching over selected fields (code/name/symbol).
  /// Returns an unmodifiable list. Empty query returns empty list.
  List<GeoCurrency> searchCurrencies(
    String query, {
    int limit = 50,
    GeoCurrencySearchField fields = GeoCurrencySearchField.codeNameSymbol,
  });

  // ---------------------------------------------------------------------------
  // Dial codes
  // ---------------------------------------------------------------------------

  /// Returns the dial-code entry of [country] (primary E.164 calling code).
  ///
  /// In strict datasets, this should be present for all countries.
  /// In lenient datasets, it may be missing (returns `null`).
  GeoDialCodeEntry? dialCodeEntryOf(GeoCountryIso country);

  /// Searches dial codes (picker-friendly).
  ///
  /// Matches against:
  /// - country ISO
  /// - country name
  /// - dial code (E.164, prefix-friendly)
  ///
  /// Returns an unmodifiable list. Empty query returns empty list.
  List<GeoDialCodeEntry> searchDialCodes(
    String query, {
    int limit = 50,
  });
}
