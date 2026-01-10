import 'package:meta/meta.dart';

import 'geo_country_iso.dart';

/// Represents a country/territory entry suitable for UI pickers and lightweight
/// geo-metadata lookups.
///
/// Instances are generated as compile-time constants from the SoT.
///
/// Nullability contract:
/// - strict: [currencyCode] and [dialCode] are non-nullable and generation fails if missing
/// - lenient (`--lenient`): [currencyCode] and [dialCode] are nullable
@immutable
class GeoCountry {
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
  final String currencyCode;

  /// Primary E.164 dial code (e.g. "+92").
  final String dialCode;
}
