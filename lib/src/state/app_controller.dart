import 'package:flutter/material.dart';

import '../models/app_models.dart';

class AppController extends ChangeNotifier {
  AppController.seeded()
    : _allocations = _seedAllocations(),
      _ledgerEntries = _seedLedgers();

  final List<AllocationItem> _allocations;
  final List<LedgerEntry> _ledgerEntries;

  String _selectedAllocationFilter = 'All';
  bool _biometricVerified = false;

  List<AllocationItem> get allocations => List.unmodifiable(_allocations);
  List<LedgerEntry> get ledgerEntries => List.unmodifiable(_ledgerEntries);
  String get selectedAllocationFilter => _selectedAllocationFilter;
  bool get biometricVerified => _biometricVerified;

  List<String> get allocationFilters {
    final filters = <String>{'All'};
    for (final item in _allocations) {
      filters.add(item.group);
    }
    return filters.toList();
  }

  List<AllocationItem> get filteredAllocations {
    if (_selectedAllocationFilter == 'All') return allocations;
    return _allocations
        .where((item) => item.group == _selectedAllocationFilter)
        .toList();
  }

  void selectAllocationFilter(String filter) {
    _selectedAllocationFilter = filter;
    notifyListeners();
  }

  void addOrUpdateAllocation(AllocationItem allocation) {
    final index = _allocations.indexWhere((item) => item.id == allocation.id);
    if (index == -1) {
      _allocations.add(allocation);
    } else {
      _allocations[index] = allocation;
    }
    notifyListeners();
  }

  void deleteAllocation(String id) {
    _allocations.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  AllocationItem? getAllocationById(String id) {
    for (final item in _allocations) {
      if (item.id == id) return item;
    }
    return null;
  }

  void addOrUpdateLedgerEntry(LedgerEntry entry) {
    final existing = _ledgerEntries.indexWhere((item) => item.id == entry.id);
    final previous = existing == -1 ? null : _ledgerEntries[existing];

    if (existing == -1) {
      _ledgerEntries.insert(0, entry);
    } else {
      _ledgerEntries[existing] = entry;
    }

    _applyLedgerImpact(previous: previous, next: entry);
    notifyListeners();
  }

  void deleteLedgerEntry(String id) {
    final existing = _ledgerEntries.where((item) => item.id == id).firstOrNull;
    _ledgerEntries.removeWhere((item) => item.id == id);
    if (existing != null) {
      _applyLedgerImpact(previous: existing, next: null);
    }
    notifyListeners();
  }

  void markBiometricVerified(bool verified) {
    _biometricVerified = verified;
    notifyListeners();
  }

  void _applyLedgerImpact({
    required LedgerEntry? previous,
    required LedgerEntry? next,
  }) {
    if (previous != null) {
      _updateAllocationSpend(previous.category, -previous.amount.abs());
    }
    if (next != null) {
      _updateAllocationSpend(next.category, next.amount.abs());
    }
  }

  void _updateAllocationSpend(String category, double delta) {
    final normalized = category.toLowerCase();
    final index = _allocations.indexWhere(
      (item) =>
          item.title.toLowerCase() == normalized ||
          item.group.toLowerCase() == normalized,
    );

    if (index == -1) return;

    final item = _allocations[index];
    final nextSpent = (item.spent + delta).clamp(0.0, double.infinity);
    _allocations[index] = item.copyWith(spent: nextSpent);
  }

  static List<AllocationItem> _seedAllocations() {
    return [
      AllocationItem(
        id: 'allocation_housing',
        title: 'Housing',
        group: 'Home',
        budget: 2500,
        spent: 2450,
        timeframe: 'Monthly',
        date: DateTime(2023, 11, 24),
        recurring: true,
        thresholdAlert: true,
        notes: 'Rent and related utilities',
        icon: Icons.home_outlined,
      ),
      AllocationItem(
        id: 'allocation_dining',
        title: 'Dining Out',
        group: 'Food',
        budget: 850,
        spent: 420,
        timeframe: 'Weekly',
        date: DateTime(2023, 11, 24),
        recurring: true,
        thresholdAlert: true,
        notes: 'Eating out and brunch',
        icon: Icons.restaurant_outlined,
      ),
      AllocationItem(
        id: 'allocation_groceries',
        title: 'Groceries',
        group: 'Shop',
        budget: 1200,
        spent: 680,
        timeframe: 'Monthly',
        date: DateTime(2023, 11, 24),
        recurring: true,
        thresholdAlert: false,
        notes: 'Home restock and perishables',
        icon: Icons.shopping_basket_outlined,
      ),
      AllocationItem(
        id: 'allocation_transport',
        title: 'Transport',
        group: 'Travel',
        budget: 400,
        spent: 215,
        timeframe: 'Weekly',
        date: DateTime(2023, 11, 24),
        recurring: true,
        thresholdAlert: true,
        notes: 'Flights, buses, local travel',
        icon: Icons.directions_bus_outlined,
      ),
    ];
  }

  static List<LedgerEntry> _seedLedgers() {
    return [
      LedgerEntry(
        id: 'ledger_1',
        title: 'Flight to ABJ',
        category: 'Transport',
        amount: -1299,
        date: DateTime(2023, 10, 12, 14, 45),
        notes: 'Executive flight ticket',
        inputMode: 'Manual',
      ),
      LedgerEntry(
        id: 'ledger_2',
        title: 'Back to Lagos',
        category: 'Transport',
        amount: -1599,
        date: DateTime(2023, 10, 16, 20, 45),
        notes: 'Return trip',
        inputMode: 'Manual',
      ),
      LedgerEntry(
        id: 'ledger_3',
        title: 'Train to Abuja',
        category: 'Transport',
        amount: -150,
        date: DateTime(2023, 10, 14, 10, 00),
        notes: 'Interstate train',
        inputMode: 'Capture',
      ),
      LedgerEntry(
        id: 'ledger_4',
        title: 'Bus to Kano',
        category: 'Transport',
        amount: -80,
        date: DateTime(2023, 10, 15, 5, 30),
        notes: 'Early bus ride',
        inputMode: 'Upload Data',
      ),
    ];
  }
}

extension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
