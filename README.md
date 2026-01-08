<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Mystic Geo Store

A lightweight, **compile-time generated geo metadata library** for Dart and Flutter.

This package provides fast, type-safe access to **countries, states, cities, currencies, and international dial codes**, designed primarily for **dropdowns, pickers, and search UIs** — without any runtime JSON parsing or network calls.

All data is generated ahead of time from a source-of-truth dataset and shipped as `const` Dart objects.

---

## Features

- 🌍 **Countries**
  - ISO-3166-1 alpha-2 enum (`GeoCountryIso2`)
  - Country name + flag emoji
  - Fast lookup and search

- 🗺 **States / Regions**
  - Scoped per country
  - Stable state IDs
  - Efficient state-level search

- 🏙 **Cities**
  - Scoped per country or per state
  - Optional IATA airport codes
  - Lightweight, picker-friendly search (no bloated indices)

- 💱 **Currencies**
  - ISO-4217 currency codes
  - Name + symbol (safely escaped)
  - Country ↔ currency mappings

- 📞 **International Dial Codes**
  - Supports countries with multiple dial prefixes
  - Search by country name, ISO2, or dial code

- ⚡ **Performance-oriented**
  - No runtime JSON decoding
  - No async APIs
  - No external dependencies

- 🧩 **Safe & ergonomic API**
  - All returned lists are **unmodifiable**
  - Strong typing via enums and value objects
  - Exhaustive `switch` expressions internally

---

## Getting started

### Prerequisites

- Dart **3.0+**
- Flutter (optional, if used in a Flutter app)

### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  mystic_geo_store: ^1.0.0
````

Then run:

```bash
dart pub get
```

---

## Usage

### Importing the library

```dart
import 'package:geo_data/geo_data.dart';
```

### Accessing the singleton datasource

```dart
final geo = GeoData.instance;
```

---

### Countries

```dart
// All countries
final countries = geo.countries;

// Lookup by ISO2
final pakistan = geo.countryByIso2(GeoCountryIso2.PK);

// Parse ISO2 code (throws if invalid)
final iso = GeoCountryIso2.withCode('pk');

// Convenience extension
final country = GeoCountryIso2.US.country;
```

### Searching countries (picker-friendly)

```dart
final results = geo.searchCountries(
  'uni',
  limit: 20,
);
```

---

### States

```dart
// States of a country
final states = geo.statesOf(GeoCountryIso2.PK);

// Search states within a country
final filtered = geo.searchStates(
  GeoCountryIso2.PK,
  'pun',
);

// Lookup by stable state id
final state = geo.stateById('pk-pb');
```

---

### Cities

```dart
// All cities of a country (can be large)
final cities = geo.citiesOf(GeoCountryIso2.PK);

// Cities of a specific state
final stateCities = geo.citiesOfState('pk-pb');

// Picker-style city search
final matches = geo.searchCities(
  GeoCountryIso2.PK,
  'lah',
  limit: 50,
);
```

You can also scope search to a state:

```dart
final matches = geo.searchCities(
  GeoCountryIso2.PK,
  'lah',
  stateId: 'pk-pb',
);
```

---

### Currencies

```dart
// All currencies
final currencies = geo.currencies;

// Lookup by currency code
final usd = geo.currencyByCode('USD');

// Currency used by a country
final pkr = geo.currencyOf(GeoCountryIso2.PK);

// Countries using a currency
final euroCountries = geo.countriesUsingCurrency('EUR');

// Search currencies
final matches = geo.searchCurrencies('dol');
```

---

### Dial codes

```dart
// Dial codes for a country
final codes = geo.dialCodesOf(GeoCountryIso2.PK);

// Dial code entry
final entry = geo.dialCodeEntryOf(GeoCountryIso2.US);

// Search by country name, ISO2, or prefix
final matches = geo.searchDialCodes('+92');
```

---

## Design notes

* All data is **generated at build time** from a source-of-truth dataset.
* City search intentionally avoids heavy precomputed indices to keep:

  * generated code size reasonable
  * analyzer and compile times fast
* APIs are optimized for **UI pickers**, not fuzzy or ranked search engines.

---

## Code generation

This package includes a generator tool that converts raw JSON datasets into
Dart source files.

Typical usage:

```bash
dart run tool/generate.dart \
  --input geo_sot_files.zip \
  --out lib
```

The generator supports:

* zip files or extracted directories
* deterministic output (stable diffs)
* automatic string escaping for Dart safety

---

## Additional information

* 🐛 **Issues & bugs**: Please file issues with clear reproduction steps.
* 💡 **Feature requests**: Keep the scope focused on static geo metadata.
* 🤝 **Contributions**: PRs are welcome, especially for:

  * data corrections
  * additional integrity checks
  * generator improvements

This package is intentionally **simple, fast, and predictable** — designed to
be a reliable building block for forms, onboarding flows, and internationalized
apps.

---

## Source of Truth (SoT)

This package does **not** bundle the raw JSON datasets (countries, states, cities,
currencies, dial codes).

Instead:

- All data is generated **ahead of time** into Dart `const` objects.
- The runtime package contains **no JSON parsing logic**.
- The source-of-truth (SoT) datasets are maintained **separately** and consumed
  only by the code generator.

This approach keeps the package:
- small and fast
- deterministic
- free from data-licensing ambiguity

If you are interested in the SoT format or regeneration process, see the
**Code generation** section below.

---

## Code generation

`mystic_geo_store` includes a generator tool that converts raw geo datasets
(JSON) into Dart source files.

The generator is intended for **maintainers and contributors**, not for
runtime use.

```bash
dart run tool/generate.dart \
  --input geo_sot_files.zip \
  --out lib
````

Notes:

* The input may be a zip file or an extracted directory.
* Generated output is deterministic (stable diffs).
* Currency symbols and special characters are safely escaped.
* The JSON datasets themselves are **not shipped** with the package.


---

## Future plans

The following enhancements are planned for future releases:

- ✅ **Expanded unit test coverage**  
  - Data integrity checks
  - Deterministic generation validation
  - API regression tests

- 📦 **Example project**
  - Flutter demo app showcasing common picker flows
  - Country → State → City cascading selection
  - Currency and dial code pickers

- 🎨 **Flutter picker widgets**
  - Ready-to-use widgets with built-in search support:
    - Country picker
    - State picker
    - City picker
    - Currency picker
    - Dial code picker
  - Optimized for large datasets
  - Keyboard-friendly and mobile-friendly UX

- 🔍 **Search enhancements (non-breaking)**
  - Optional result ranking
  - Prefix vs substring tuning
  - Configurable result limits

---

## License

### Code

The source code of this package, including all Dart files and generated code,
is licensed under the **MIT License**.

See the [LICENSE](LICENSE) file for details.

### Data (Source of Truth)

This package does **not** distribute the raw geo datasets (countries, states,
cities, currencies, dial codes).

Any source-of-truth (SoT) datasets used to generate this package are maintained
**separately** and may be subject to their own licenses and attribution
requirements.

Users who regenerate the data are responsible for ensuring compliance with the
licenses of any datasets they use.
