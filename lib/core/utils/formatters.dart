import 'package:intl/intl.dart';

class Formatters {
  /// Updated by SettingsProvider whenever the user changes country.
  static String currencySymbol = 'RM';

  static String currency(double amount, {String? symbol}) {
    final sym = symbol ?? currencySymbol;
    final f = NumberFormat('#,##0.00');
    return '$sym ${f.format(amount)}';
  }

  static String currencyCompact(double amount) {
    final sym = currencySymbol;
    if (amount >= 1000000) return '$sym${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000)    return '$sym${(amount / 1000).toStringAsFixed(1)}K';
    return '$sym${amount.toStringAsFixed(0)}';
  }

  static String date(DateTime d) => DateFormat('dd MMM yyyy').format(d);
  static String dateShort(DateTime d) => DateFormat('dd MMM').format(d);
  static String monthYear(DateTime d) => DateFormat('MMM yyyy').format(d);
  static String monthShort(DateTime d) => DateFormat('MMM').format(d);

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(date);
  }
}
