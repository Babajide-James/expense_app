import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../widgets/common_widgets.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final totalBudget = app.allocations.fold<double>(
      0,
      (sum, item) => sum + item.budget,
    );
    final totalSpent = app.allocations.fold<double>(
      0,
      (sum, item) => sum + item.spent,
    );

    return PagePadding(
      child: ListView(
        children: [
          const Text(
            'Insights',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F254B),
            ),
          ),
          const SizedBox(height: 16),
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Budget Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Total budget: \$${totalBudget.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text('Total spent: \$${totalSpent.toStringAsFixed(2)}'),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: totalBudget == 0 ? 0 : (totalSpent / totalBudget).clamp(0, 1),
                  minHeight: 8,
                  color: const Color(0xFF2962E8),
                  backgroundColor: const Color(0xFFD9E3F3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const EmptyStateCard(
            title: 'Smart insights area',
            message:
                'This section is now connected to live budget values, and it is ready for category charts, alerts, and forecasting logic.',
          ),
        ],
      ),
    );
  }
}
