import 'package:intl/intl.dart';

/// Utility class for formatting numbers with thousand separators
class NumberFormatter {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0', 'en_US');
  static final NumberFormat _currencyFormatDecimal = NumberFormat('#,##0.00', 'en_US');
  static final NumberFormat _weightFormat = NumberFormat('#,##0.0', 'en_US');
  
  /// Format a number with thousand separators (no decimals)
  /// Example: 10000 -> "10,000"
  static String format(num value) {
    return _currencyFormat.format(value);
  }
  
  /// Format a number with thousand separators and 2 decimal places
  /// Example: 10000.5 -> "10,000.50"
  static String formatDecimal(num value) {
    return _currencyFormatDecimal.format(value);
  }
  
  /// Format weight with 1 decimal place
  /// Example: 50.5 -> "50.5"
  static String formatWeight(num value) {
    return _weightFormat.format(value);
  }
  
  /// Format currency with ETB prefix
  /// Example: 10000 -> "ETB 10,000"
  static String formatCurrency(num value, {String currency = 'ETB'}) {
    return '$currency ${format(value)}';
  }
  
  /// Format currency with ETB prefix and decimals
  /// Example: 10000.5 -> "ETB 10,000.50"
  static String formatCurrencyDecimal(num value, {String currency = 'ETB'}) {
    return '$currency ${formatDecimal(value)}';
  }
}

/// Extension on num for easier formatting
extension NumFormatting on num {
  /// Format with thousand separators
  String get formatted => NumberFormatter.format(this);
  
  /// Format with thousand separators and 2 decimals
  String get formattedDecimal => NumberFormatter.formatDecimal(this);
  
  /// Format as currency (ETB)
  String get asCurrency => NumberFormatter.formatCurrency(this);
  
  /// Format as weight (Kg)
  String get asWeight => '${NumberFormatter.formatWeight(this)} Kg';
}
