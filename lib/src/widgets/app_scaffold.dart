import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: child,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        indicatorColor: const Color(0xFFDDE8FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.airplane_ticket_outlined),
            selectedIcon: Icon(Icons.airplane_ticket),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
