/// Fields used for country searches.
enum GeoCountrySearchField {
  /// Search against country name only.
  name,

  /// Search against ISO only.
  iso,

  /// Search against both name and ISO.
  nameAndIso,
}

/// Fields used for city searches.
enum GeoCitySearchField {
  /// Search city name only.
  name,

  /// Search IATA only.
  iata,

  /// Search both city name and IATA.
  nameAndIata,
}

/// Fields used for currency searches.
enum GeoCurrencySearchField {
  /// Search currency code only (e.g. USD).
  code,

  /// Search currency name only (e.g. US Dollar).
  name,

  /// Search currency symbol only (e.g. $).
  symbol,

  /// Search code + name + symbol.
  codeNameSymbol,
}

// ---------------------------------------------------------------------------
// Search normalization
// ---------------------------------------------------------------------------

mixin StringSearchable {
  /// Normalizes user input for deterministic, case-insensitive matching.
  ///
  /// This is intentionally lightweight:
  /// - lowercases
  /// - collapses whitespace
  /// - strips a small set of punctuation characters commonly found in names
  String normalizeSearch(String input) => input
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[\u2019\'"`]'), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
