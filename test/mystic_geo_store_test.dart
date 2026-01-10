import 'package:test/test.dart';

import 'package:mystic_geo_store/mystic_geo_store.dart';

final geoData = GeoStore.instance;

void main() {
  testCountryNameByIso(GeoCountryIso.PK, 'Pakistan');
  testCountryByName('pakistan', 'Pakistan');
  testCitySearch(GeoCountryIso.US);
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

void testCitySearch(GeoCountryIso input, [int? limit]) {
  test('get cities for country', () {
    final actual = geoData.searchCities(input, 'm', limit: limit);
    expect(
      actual.length,
      isNot(0),
      reason: '${actual.length} cities found for `$input`',
    );
    print('${actual.length} cities found for `$input`');
  });
}
