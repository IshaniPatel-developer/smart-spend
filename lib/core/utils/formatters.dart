import 'package:intl/intl.dart';

class Formatters {
  /// Formats double amount to currency string: $X.XX
  static String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$').format(amount);
  }

  /// Formats date to long layout: Tuesday, Jun 30, 2026
  static String formatDate(DateTime date) {
    return DateFormat('EEEE, MMM dd, yyyy').format(date);
  }

  /// Formats date to short layout: Jun 30, 2026
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
