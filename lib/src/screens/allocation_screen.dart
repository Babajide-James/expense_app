import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/app_scope.dart';
import '../utils/app_formatters.dart';
import '../widgets/common_widgets.dart';
import 'new_allocation_screen.dart';

class AllocationScreen extends StatelessWidget {
  const AllocationScreen({
    super.key,
    required this.onNavigateToTransport,
  });

  final VoidCallback onNavigateToTransport;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = app.filteredAllocations;
    final filters = app.allocationFilters;

    return PagePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackHeader(
            title: 'Allocation',
            trailing: IconButton(
              onPressed: onNavigateToTransport,
              icon: const Icon(Icons.swap_horiz_rounded),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final label = filters[index];
                final selected = label == app.selectedAllocationFilter;
                return ChoiceChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (_) => app.selectAllocationFilter(label),
                  showCheckmark: false,
                  side: BorderSide.none,
                  selectedColor: const Color(0xFFDDE8FF),
                  backgroundColor: Colors.white,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                if (items.isEmpty)
                  const EmptyStateCard(
                    title: 'No allocations in this filter',
                    message:
                        'Create a new allocation or switch the filter to view existing budget cards.',
                  ),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: AllocationCard(
                      item: item,
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => NewAllocationScreen(existing: item),
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
                        builder: (_) => const NewAllocationScreen(),
                      ),
                    );
                  },
                  child: const Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFFDDE8FF),
                        child: Icon(
                          Icons.post_add_rounded,
                          color: Color(0xFF1148A5),
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'New Allocation',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Create and save a working budget card',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF667085)),
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
        title: const Text('Delete allocation'),
        content: const Text(
          'This removes the allocation card from the list. You can still create it again later.',
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
      app.deleteAllocation(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allocation deleted')),
      );
    }
  }
}

class AllocationCard extends StatelessWidget {
  const AllocationCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final AllocationItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF2F4F7),
                child: Icon(item.icon, color: const Color(0xFF1148A5)),
              ),
              const Spacer(),
              StatusPill(
                label: item.status,
                backgroundColor: item.tagColor,
                textColor: item.tagTextColor,
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
          const SizedBox(height: 18),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.group,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Color(0xFF1D2939)),
              children: [
                TextSpan(
                  text: AppFormatters.compactMoney(item.spent),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' / ${AppFormatters.compactMoney(item.budget)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'USED ${item.usedPercent}%',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${item.remaining >= 0 ? '+' : '-'}${AppFormatters.compactMoney(item.remaining.abs())} LEFT',
                style: TextStyle(
                  fontSize: 11,
                  color: item.progressColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              backgroundColor: const Color(0xFFE4E7EC),
              value: (item.usedPercent / 100).clamp(0.0, 1.0),
              valueColor: AlwaysStoppedAnimation<Color>(item.progressColor),
            ),
          ),
        ],
      ),
    );
  }
}
