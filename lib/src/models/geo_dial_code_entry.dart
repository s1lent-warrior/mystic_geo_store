import 'geo_country_iso2.dart';

/// Dialing prefixes for a country (E.164).
///
/// Some countries/territories may have multiple prefixes, hence [dialCodes]
/// is a list.
class GeoDialCodeEntry {
  const GeoDialCodeEntry({
    required this.countryIso2,
    required this.dialCodes,
  });

  final GeoCountryIso2 countryIso2;
  final List<String> dialCodes;
}
