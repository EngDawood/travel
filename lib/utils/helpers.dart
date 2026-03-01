// lib/utils/helpers.dart
import 'package:intl/intl.dart';

/// Format a DateTime as a readable date string (e.g. "Mon, 24 Feb 2026").
/// Pass [locale] to get locale-aware day/month names.
String formatDate(DateTime date, {String locale = 'en'}) =>
    DateFormat('EEE, d MMM yyyy', locale).format(date);

/// Convert a price level int to dollar signs.
String priceLevelToString(int level) {
  if (level == 0) return 'Free';
  return '\$' * level;
}

/// Capitalise first letter of a string.
String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
