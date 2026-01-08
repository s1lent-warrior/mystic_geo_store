import 'geo_country_iso2.dart';

/// A country entry intended for UI pickers and lightweight metadata usage.
///
/// Instances are generated as compile-time constants from the SoT dataset.
class GeoCountry {
  /// Creates an immutable country model.
  const GeoCountry({
    required this.iso2,
    required this.name,
    required this.emoji,
  });

  /// ISO 3166-1 alpha-2 code (e.g., [GeoCountryIso2.PK]).
  final GeoCountryIso2 iso2;

  /// English display name.
  final String name;

  /// Flag emoji for the country.
  final String emoji;
}
