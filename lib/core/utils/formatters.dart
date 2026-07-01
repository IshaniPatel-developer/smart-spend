import 'package:intl/intl.dart';

class Formatters {
  /// Formats double amount to currency string with Indian Rupees: ₹X.XX
  static String formatCurrency(double amount) {
    return formatRupee(amount);
  }

  /// Formats double amount to standard Indian Rupees format
  static String formatRupee(double amount) {
    return NumberFormat.currency(symbol: '₹').format(amount);
  }

  /// Abbreviates large currency values (e.g. 5k, 1M, 2.5B)
  static String abbreviateRupee(double amount) {
    return formatRupee(amount);
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
