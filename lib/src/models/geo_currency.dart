import 'package:meta/meta.dart';

/// Currency entry (ISO 4217) for pickers.
///
/// [code] is the canonical identifier (e.g. "USD").
@immutable
class GeoCurrency {
  const GeoCurrency({
    required this.code,
    required this.name,
    this.symbol,
  });

  final String code;
  final String name;
  final String? symbol;
}
