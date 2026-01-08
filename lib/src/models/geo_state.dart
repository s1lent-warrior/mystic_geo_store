import 'geo_country_iso2.dart';

/// A first-level administrative division (e.g., state/province/region).
///
/// Instances are generated as compile-time constants from the SoT dataset.
///
/// The [id] is a stable identifier used by [GeoCity.stateId] to join a city
/// to its parent state.
class GeoState {
  const GeoState({
    required this.id,
    required this.name,
    required this.countryIso2,
  });

  /// Stable state id (dataset-defined).
  final String id;

  /// English display name.
  final String name;

  /// Parent country ISO2.
  final GeoCountryIso2 countryIso2;
}
