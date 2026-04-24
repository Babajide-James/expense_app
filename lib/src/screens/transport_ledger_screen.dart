import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_scope.dart';
import '../utils/app_formatters.dart';
import '../widgets/common_widgets.dart';
import 'add_transaction_screen.dart';

class TransportLedgerScreen extends StatelessWidget {
  const TransportLedgerScreen({
    super.key,
    required this.onNavigateToAllocation,
  });

  final VoidCallback onNavigateToAllocation;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final entries = app.ledgerEntries;

    return PagePadding(
      child: Column(
        children: [
          BackHeader(
            title: 'Transport Ledgers',
            trailing: IconButton(
              onPressed: onNavigateToAllocation,
              icon: const Icon(Icons.swap_horiz_rounded),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                if (entries.isEmpty)
                  const EmptyStateCard(
                    title: 'No transport ledgers yet',
                    message:
                        'Add a transport transaction and it will appear here immediately.',
                  ),
                ...entries.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LedgerTile(
                      item: item,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AddTransactionScreen(existing: item),
                          ),
                        );
                      },
                      onDelete: () => _confirmDelete(context, item.id),
                    ),
                  ),
                ),
                WhiteCard(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AddTransactionScreen(),
                      ),
                    );
                  },
                  child: const Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFFDDE8FF),
                        child: Icon(
                          Icons.playlist_add_rounded,
                          color: Color(0xFF1148A5),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'New Ledger',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Record a new receipt or transport expense',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF667085)),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Quick Add',
                        style: TextStyle(
                          color: Color(0xFF1148A5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final app = AppScope.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete ledger entry'),
        content: const Text(
          'This removes the transaction and recalculates the affected allocation spend.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      app.deleteLedgerEntry(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ledger deleted')),
      );
    }
  }
}

class LedgerTile extends StatelessWidget {
  const LedgerTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final LedgerEntry item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE7FBF1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.payments_outlined, color: Color(0xFF12B76A)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.category.toUpperCase()} • ${AppFormatters.time(item.date)}',
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.money(item.amount),
                style: const TextStyle(
                  color: Color(0xFFD92D20),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppFormatters.monthDay(item.date),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF98A2B3),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }
}
