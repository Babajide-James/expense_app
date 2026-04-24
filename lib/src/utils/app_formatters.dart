class AppFormatters {
  static String money(double amount) {
    final sign = amount < 0 ? '-' : '';
    final absolute = amount.abs().toStringAsFixed(2);
    return '$sign\$$absolute';
  }

  static String compactMoney(double amount) {
    final absolute = amount.abs();
    final text = absolute.truncateToDouble() == absolute
        ? absolute.toStringAsFixed(0)
        : absolute.toStringAsFixed(2);
    return '\$$text';
  }

  static String shortDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$month/$day/${value.year}';
  }

  static String monthDay(DateTime value) {
    const months = [
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
      'DEC',
    ];
    return '${months[value.month - 1]} ${value.day}';
  }

  static String time(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
