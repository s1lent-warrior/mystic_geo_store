import 'package:meta/meta.dart';

import 'geo_country_iso.dart';

/// First-level administrative division (state/region/province).
///
/// [id] is a SoT-stable identifier referenced by cities.
@immutable
class GeoState {
  const GeoState({
    required this.id,
    required this.name,
    required this.countryIso,
  });

  final String id;
  final String name;
  final GeoCountryIso countryIso;
}
