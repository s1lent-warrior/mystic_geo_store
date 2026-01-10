import '../models/geo_country.dart';
import '../models/geo_country_iso.dart';
import '../models/geo_currency.dart';
import '../models/geo_currency_iso.dart';
import '../models/geo_dial_code_entry.dart';
import 'geo_store.dart';

/// Convenience helpers that connect Country to currency and dial code.
extension GeoCountryX on GeoCountry {
  /// Returns the [GeoCurrency] used by this country.
  ///
  /// In strict datasets, always succeeds.
  /// In lenient datasets, may throw [StateError] if mapping is missing.
  GeoCurrency get currency => GeoStore.instance.currencyOf(iso);

  /// Returns the primary E.164 dial code (e.g. "+92") for this country.
  ///
  /// In strict datasets, this should be present.
  /// In lenient datasets, may throw [StateError] if mapping is missing.
  GeoDialCodeEntry get dialCode => GeoStore.instance.dialCodeEntryOf(iso)!;
}

/// Convenience helpers that connect ISO enums to the store.
///
/// Keeps UI code ergonomic:
/// - `GeoCountryIso.PK.country`
/// - `GeoCountryIso.PK.currency`
/// - `GeoCountryIso.PK.dialCode`
extension GeoCountryIsoX on GeoCountryIso {
  /// Returns the canonical [GeoCountry] entry for this ISO code.
  GeoCountry get country => GeoStore.instance.countryByIso(this);

  /// Returns the [GeoCurrency] used by this country.
  ///
  /// In strict datasets, always succeeds.
  /// In lenient datasets, may throw [StateError] if mapping is missing.
  GeoCurrency get currency => GeoStore.instance.currencyOf(this);

  /// Returns the primary E.164 dial code (e.g. "+92") for this country.
  ///
  /// In strict datasets, this should be present.
  /// In lenient datasets, may throw [StateError] if mapping is missing.
  GeoDialCodeEntry get dialCode => GeoStore.instance.dialCodeEntryOf(this)!;
}

/// Convenience helpers that connect currency enums to the store.
///
/// Example usage:
/// - `GeoCurrencyIso.USD.currency`
/// - `GeoCurrencyIso.USD.countries`
extension GeoCurrencyIsoX on GeoCurrencyIso {
  /// Returns the canonical [GeoCurrency] entry for this currency.
  GeoCurrency get currency => GeoStore.instance.currencyByCode(this);

  /// Returns all countries using this currency.
  ///
  /// The returned list is unmodifiable.
  List<GeoCountryIso> get countries =>
      GeoStore.instance.countriesUsingCurrency(this);
}
