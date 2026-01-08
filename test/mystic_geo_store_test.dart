import 'package:flutter_test/flutter_test.dart';

import 'package:mystic_geo_store/mystic_geo_store.dart';

void main() {
  test('get country by country code', () {
    final geoData = GeoData.instance;
    final expected = geoData.countryByIso2(.PK);
    expect(
      expected?.name,
      'Pakistan',
      reason: 'Country name is `Pakistan` for ISO 2 code `PK`',
    );
  });
}
