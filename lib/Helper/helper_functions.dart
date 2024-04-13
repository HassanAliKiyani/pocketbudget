import "package:intl/intl.dart";
/* 
 * Helper functions to use across the application
 */

//Convert the amount in string to double

double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0.00;
}

String convertAmountToCurreny(double amount) {
  final format =
      NumberFormat.currency(locale: "en_US", symbol: "PKR", decimalDigits: 2);
  return format.format(amount);
}

int calculateNumberOfMonth(
    {required int startYear,
    required int startMonth,
    required int currentYear,
    required int currentMonth}) {
  int totalMonths =
      (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return totalMonths;
}

String getMonthInitials(int month) {
  final months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC'
  ];
  if (month >= 1 && month <= 12) {
    return months[month - 1];
  } else {
    return '';
  }
}
