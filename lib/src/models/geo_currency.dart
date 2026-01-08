/// A currency (ISO 4217) record intended for UI pickers.
///
/// Instances are generated as compile-time constants from the SoT dataset.
class GeoCurrency {
  const GeoCurrency({
    required this.code,
    required this.name,
    this.symbol,
  });

  /// ISO 4217 currency code (e.g., "USD").
  final String code;

  /// English currency name.
  final String name;

  /// Common currency symbol (may be null).
  final String? symbol;
}
