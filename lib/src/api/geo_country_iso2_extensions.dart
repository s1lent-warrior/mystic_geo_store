import '../models/geo_country.dart';
import '../models/geo_country_iso2.dart';
import 'geo_data.dart';

extension GeoCountryIso2X on GeoCountryIso2 {
  /// Returns the [GeoCountry] metadata for this ISO2.
  ///
  /// Throws if the country is not present in the generated dataset.
  GeoCountry get country => GeoData.instance.countryByIso2(this)!;
}
