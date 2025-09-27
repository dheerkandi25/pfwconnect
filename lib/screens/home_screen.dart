import 'package:flutter/material.dart';

import 'carpool_tab.dart';
import 'marketplace_tab.dart';
import 'social_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<_HomeTab> tabs = <_HomeTab>[
      _HomeTab(
        label: 'Carpool',
        icon: Icons.directions_car,
        child: const CarpoolTab(),
      ),
      _HomeTab(
        label: 'Marketplace',
        icon: Icons.storefront,
        child: const MarketplaceTab(),
      ),
      _HomeTab(
        label: 'Social',
        icon: Icons.groups,
        child: const SocialTab(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('PFW Connect'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: tabs[_tabIndex].child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        destinations: tabs
            .map(
              (_HomeTab tab) => NavigationDestination(
                icon: Icon(tab.icon),
                label: tab.label,
              ),
            )
            .toList(),
        onDestinationSelected: (int index) {
          setState(() {
            _tabIndex = index;
          });
        },
      ),
    );
  }
}

class _HomeTab {
  const _HomeTab({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;
}
