/// Controls which fields are considered during country search.
enum GeoCountrySearchField { nameOnly, nameAndIso2 }

/// Controls which fields are considered during currency search.
enum GeoCurrencySearchField { codeOnly, codeAndName, codeNameSymbol }

/// Controls which fields are considered during city search.
enum GeoCitySearchField { nameOnly, nameAndIata }

/// Normalizes input for basic picker search.
///
/// - Trims
/// - Lowercases
/// - Collapses whitespace
String geoNormalizeSearch(String input) {
  final trimmed = input.trim().toLowerCase();
  if (trimmed.isEmpty) return '';
  return trimmed.replaceAll(RegExp(r'\s+'), ' ');
}
