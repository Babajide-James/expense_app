import 'package:flutter/material.dart';

class AllocationItem {
  AllocationItem({
    required this.id,
    required this.title,
    required this.group,
    required this.budget,
    required this.spent,
    required this.timeframe,
    required this.date,
    required this.recurring,
    required this.thresholdAlert,
    required this.notes,
    required this.icon,
  });

  final String id;
  final String title;
  final String group;
  final double budget;
  final double spent;
  final String timeframe;
  final DateTime date;
  final bool recurring;
  final bool thresholdAlert;
  final String notes;
  final IconData icon;

  AllocationItem copyWith({
    String? id,
    String? title,
    String? group,
    double? budget,
    double? spent,
    String? timeframe,
    DateTime? date,
    bool? recurring,
    bool? thresholdAlert,
    String? notes,
    IconData? icon,
  }) {
    return AllocationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      group: group ?? this.group,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      timeframe: timeframe ?? this.timeframe,
      date: date ?? this.date,
      recurring: recurring ?? this.recurring,
      thresholdAlert: thresholdAlert ?? this.thresholdAlert,
      notes: notes ?? this.notes,
      icon: icon ?? this.icon,
    );
  }

  int get usedPercent {
    if (budget <= 0) return 0;
    return ((spent / budget) * 100).clamp(0, 999).round();
  }

  double get remaining => budget - spent;

  String get status {
    if (usedPercent >= 95) return 'AT LIMIT';
    if (usedPercent >= 80) return 'WATCH';
    return 'ON TRACK';
  }

  Color get progressColor {
    if (usedPercent >= 95) return const Color(0xFFD92D20);
    if (usedPercent >= 80) return const Color(0xFFF79009);
    return const Color(0xFF175CD3);
  }

  Color get tagColor {
    if (usedPercent >= 95) return const Color(0xFFFEE4E2);
    if (usedPercent >= 80) return const Color(0xFFFEF0C7);
    return const Color(0xFFEFF4FF);
  }

  Color get tagTextColor {
    if (usedPercent >= 95) return const Color(0xFFB42318);
    if (usedPercent >= 80) return const Color(0xFFB54708);
    return const Color(0xFF175CD3);
  }
}

class LedgerEntry {
  LedgerEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.notes,
    required this.inputMode,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final String notes;
  final String inputMode;

  LedgerEntry copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    DateTime? date,
    String? notes,
    String? inputMode,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      inputMode: inputMode ?? this.inputMode,
    );
  }
}

class PasswordStrength {
  const PasswordStrength({
    required this.label,
    required this.score,
    required this.color,
    required this.requirements,
  });

  final String label;
  final double score;
  final Color color;
  final List<PasswordRequirement> requirements;
}

class PasswordRequirement {
  const PasswordRequirement({
    required this.label,
    required this.met,
  });

  final String label;
  final bool met;
}
