# Changelog

## [1.1.2] – Add Indexing to States Search

- add indexing to states search
- fix a bug in searching

- marked `limit` as optional argument for all search functions in `GeoStore`.

## [1.1.1] – Optional Limit for Searching

- marked `limit` as optional argument for all search functions in `GeoStore`.

## [1.1.0] – Strict vs Lenient Generation, E.164 Dial Codes, Currency Enum
### Added
- **`--lenient` generator flag**
  - Enables generation even when currency or dial-code mappings are missing.
  - Missing mappings become `null` instead of failing generation.
- **Strict mode (default)**
  - Generator fails if *any* country is missing:
    - currency code
    - dial code
  - Ensures published packages always have complete data.
- **E.164 dial-code support**
  - New preferred SoT file: `sot/dial_codes_e164.json`
  - Canonical format:
    ```json
    { "dialCodeByCountryIso2": { "PK": "+92", "US": "+1" } }
    ```
- **Backward compatibility for legacy dial-code SoT**
  - Still supports:
    ```json
    { "dialCodesByCountryIso2": { "PK": ["+92"], "US": ["+1", "+1340"] } }
    ```
- **Primary dial code model**
  - `GeoDialCodeEntry` now stores a single `dialCode` (E.164).
- **`GeoCurrencyIso` enum**
  - ISO 4217 currency codes as enum cases (uppercase).
  - Each enum case has documentation.
  - Factory constructor `GeoCurrencyIso.withCode(String)` that throws on invalid input.
- **Extensions**
  - `GeoCountryIsoX` for accessing:
    - `country`
    - `currency`
    - `dialCode`
  - `GeoCurrencyIsoX` for accessing:
    - `currency`
    - `countriesUsingCurrency`
- **Detailed documentation generation**
  - Entity models (`GeoCountry`, `GeoState`, `GeoCity`, etc.) now include rich API docs.
- **Improved dial-code search**
  - Picker-friendly digit-based prefix matching (with or without `+`).

### Changed
- **Nullability controlled by generator mode**
  - Strict mode:
    - `GeoCountry.currencyCode` → `String`
    - `GeoCountry.dialCode` → `String`
  - Lenient mode:
    - `GeoCountry.currencyCode` → `String?`
    - `GeoCountry.dialCode` → `String?`
- **`GeoCountry` model enhanced**
  - Embedded:
    - `currencyCode`
    - `dialCode`
- **Dial-code APIs simplified**
  - Removed concept of “multiple dial codes per country”.
  - `dialCodesOf(country)` deprecated internally in favor of:
    - `GeoCountry.dialCode`
    - `dialCodeEntryOf(country)`
- **ISO enum naming**
  - `GeoCountryIso2` renamed to `GeoCountryIso`.
- **Search normalization fix**
  - Fixed invalid raw string regex that caused compile errors.

### Fixed
- Compile-time regex escaping error in `_normalizeSearch`.
- Inconsistent dial-code normalization when `+` was missing.
- Silent failures in strict generation now produce actionable error messages.

---

## [0.1.0] – Initial Release
### Added
- Compile-time geo data store for:
  - countries
  - states
  - cities
  - currencies
  - dial codes
- Search APIs for pickers (country, state, city, currency, dial code).
- Deterministic generated output from JSON SoT.
- No runtime JSON parsing.

---

## Notes
- **Strict mode is recommended for published releases** to guarantee completeness.
- **Lenient mode is intended for SoT iteration and development**.
- Public APIs are designed for picker-style usage and may evolve conservatively.

---


## 1.0.1

Rename GeoData to GeoStore.

___

## 1.0.0

Initial release of `mystic_geo_store` — a compile-time generated geo metadata store for Dart and Flutter.

### Highlights

- Static, compile-time generated datasets for:
  - Countries
  - States/regions
  - Cities
  - Currencies
  - International dial codes

- Type-safe access using `GeoCountryIso2` (ISO 3166-1 alpha-2 enum):
  - Uppercase enum cases (avoids Dart keyword collisions)
  - `GeoCountryIso2.withCode(...)` factory parser (throws on invalid codes)
  - Per-case documentation describing each country

- Picker-friendly API via `GeoData` facade:
  - Fast lookups (e.g., `countryByIso2`, `currencyByCode`, `dialCodesOf`)
  - Scoped queries (`statesOf(country)`, `citiesOf(country)`, `citiesOfState(stateId)`)
  - Lightweight search helpers for countries, states, cities, currencies, and dial codes
  - All returned collections are unmodifiable

- Generated code structure optimized for maintainability:
  - No `part` / `part-of` usage (standalone Dart files with imports/exports)
  - Cities and states generated into separate folders for better organization
  - Deterministic output ordering to avoid diff churn

- Generator CLI included:
  - Accepts input as a zip file or extracted `sot/` directory
  - Supports optional entity/model generation via `--emit-models`
  - Safe Dart string escaping (e.g., currency symbols like `$`)

### Notes

- This package ships generated Dart constants only. Raw SoT JSON datasets are maintained separately.
