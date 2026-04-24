import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';
import 'allocation_screen.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';
import 'transport_ledger_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: _index,
      onDestinationSelected: (value) => setState(() => _index = value),
      child: IndexedStack(
        index: _index,
        children: [
          TransportLedgerScreen(
            onNavigateToAllocation: () => setState(() => _index = 1),
          ),
          AllocationScreen(
            onNavigateToTransport: () => setState(() => _index = 0),
          ),
          const InsightsScreen(),
          SettingsScreen(
            onNavigateToAllocation: () => setState(() => _index = 1),
            onNavigateToTransport: () => setState(() => _index = 0),
          ),
        ],
      ),
    );
  }
}
