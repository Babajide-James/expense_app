import 'package:flutter/material.dart';

import '../models/app_models.dart';

class PasswordStrengthEvaluator {
  static PasswordStrength evaluate(String input) {
    final requirements = [
      PasswordRequirement(
        label: 'At least 12 characters long',
        met: input.length >= 12,
      ),
      PasswordRequirement(
        label: 'Contains uppercase and lowercase letters',
        met: RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(input),
      ),
      PasswordRequirement(
        label: 'Contains numbers or symbols',
        met: RegExp(r'(?=.*[\d\W])').hasMatch(input),
      ),
    ];

    final metCount = requirements.where((item) => item.met).length;
    final hasNoSpaces = input.isNotEmpty && !input.contains(' ');
    final score = ((metCount + (hasNoSpaces ? 1 : 0)) / 4).clamp(0.0, 1.0);

    if (score >= 0.85) {
      return PasswordStrength(
        label: 'Strong',
        score: score,
        color: const Color(0xFF12B76A),
        requirements: requirements,
      );
    }
    if (score >= 0.5) {
      return PasswordStrength(
        label: 'Medium',
        score: score,
        color: const Color(0xFFF79009),
        requirements: requirements,
      );
    }
    return PasswordStrength(
      label: 'Weak',
      score: score,
      color: const Color(0xFFD92D20),
      requirements: requirements,
    );
  }
}
