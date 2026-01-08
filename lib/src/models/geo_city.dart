import 'geo_country_iso2.dart';

/// A city/locality record intended for UI pickers.
///
/// Instances are generated as compile-time constants from the SoT dataset.
///
/// Cities reference their parent state through [stateId], which must match a
/// [GeoState.id] from the states dataset for the same country.
class GeoCity {
  const GeoCity({
    required this.id,
    required this.name,
    required this.countryIso2,
    required this.stateId,
    this.iata,
  });

  /// Stable city id (dataset-defined).
  final String id;

  /// English display name.
  final String name;

  /// Parent country ISO2.
  final GeoCountryIso2 countryIso2;

  /// Parent state id (joins to [GeoState.id]).
  final String stateId;

  /// Optional IATA airport code (e.g., "LHE").
  final String? iata;
}
