import 'package:meta/meta.dart';

import 'geo_country_iso.dart';

/// City entry suitable for pickers and lightweight search.
///
/// [stateId] references a [GeoState.id].
@immutable
class GeoCity {
  const GeoCity({
    required this.id,
    required this.name,
    required this.countryIso,
    required this.stateId,
    this.iata,
  });

  final String id;
  final String name;
  final GeoCountryIso countryIso;
  final String stateId;
  final String? iata;
}
