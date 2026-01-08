# Changelog

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
