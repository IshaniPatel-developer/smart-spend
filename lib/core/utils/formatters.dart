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
    final symbol = amount < 0 ? '-₹' : '₹';
    final absAmount = amount.abs();
    
    if (absAmount < 1000) {
      return '$symbol${absAmount.toStringAsFixed(2)}';
    } else if (absAmount < 1000000) {
      final val = absAmount / 1000;
      final formattedVal = val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1);
      return '$symbol${formattedVal}k';
    } else if (absAmount < 1000000000) {
      final val = absAmount / 1000000;
      final formattedVal = val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1);
      return '$symbol${formattedVal}M';
    } else {
      final val = absAmount / 1000000000;
      final formattedVal = val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1);
      return '$symbol${formattedVal}B';
    }
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
