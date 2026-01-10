import 'package:meta/meta.dart';

import 'geo_country_iso.dart';

/// Primary E.164 calling code for a country.
///
/// [dialCode] always includes a leading '+'.
@immutable
class GeoDialCodeEntry {
  const GeoDialCodeEntry({
    required this.countryIso,
    required this.dialCode,
  });

  final GeoCountryIso countryIso;
  final String dialCode;
}
