import 'package:test/test.dart';

import 'package:mystic_geo_store/mystic_geo_store.dart';

final geoData = GeoStore.instance;

void main() {
  testCountryNameByIso(GeoCountryIso.PK, 'Pakistan');
  testCountryByName('pakistan', 'Pakistan');
}

void testCountryNameByIso(GeoCountryIso input, String expectation) {
  test('get country by country code', () {
    final actual = geoData.countryByIso(input);
    expect(
      actual.name,
      expectation,
      reason: 'Country name is $expectation for ISO code `$input`',
    );
  });
}

void testCountryByName(String input, String expectation) {
  test('get country by country name', () {
    final actual = geoData.countryByName(input);
    expect(
      actual.name,
      expectation,
      reason: 'Country found for name `$input`',
    );
    print('Country found for name `$input`');
  });
}
