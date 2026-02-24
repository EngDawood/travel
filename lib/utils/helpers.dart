// lib/utils/helpers.dart

/// Format a DateTime as a readable date string (e.g. "Mon, 24 Feb 2026").
String formatDate(DateTime date) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final day = days[date.weekday - 1];
  final month = months[date.month - 1];
  return '$day, ${date.day} $month ${date.year}';
}

/// Convert a price level int to dollar signs.
String priceLevelToString(int level) {
  if (level == 0) return 'Free';
  return '\$' * level;
}

/// Capitalise first letter of a string.
String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
