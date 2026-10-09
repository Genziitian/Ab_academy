import 'package:intl/intl.dart';

/// ₹2,999 — Indian digit grouping, no decimals.
String formatRupees(int amount) =>
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(amount);
