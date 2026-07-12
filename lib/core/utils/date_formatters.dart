import 'package:intl/intl.dart';

class DateFormatters {
  const DateFormatters._();

  static String compact(DateTime date) =>
      DateFormat.yMMMd().add_Hm().format(date.toLocal());

  static String relative(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final difference = current.difference(date);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return compact(date);
  }
}
