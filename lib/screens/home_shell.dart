import 'package:flutter/material.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'insights_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Dashboard', 'History', 'Insights', 'Profile'];
  static const _icons = [
    Icons.dashboard_outlined,
    Icons.receipt_long_outlined,
    Icons.pie_chart_outline,
    Icons.person_outline,
  ];
  static const _selectedIcons = [
    Icons.dashboard,
    Icons.receipt_long,
    Icons.pie_chart,
    Icons.person,
  ];

  Widget _page() {
    switch (_index) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const HistoryScreen();
      case 2:
        return const InsightsScreen();
      default:
        return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final useRail = !Breakpoints.isMobile(w);

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0.03, 0), end: Offset.zero)
              .animate(anim),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(_index),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: _page(),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.savings, color: AppColors.mustard),
          const SizedBox(width: 8),
          Text('FinFlow • ${_titles[_index]}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
      ),
      body: useRail
          ? Row(children: [
              NavigationRail(
                extended: Breakpoints.isDesktop(w),
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: List.generate(
                  4,
                  (i) => NavigationRailDestination(
                    icon: Icon(_icons[i]),
                    selectedIcon:
                        Icon(_selectedIcons[i], color: AppColors.blue),
                    label: Text(_titles[i]),
                  ),
                ),
              ),
              Expanded(child: body),
            ])
          : body,
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: List.generate(
                4,
                (i) => NavigationDestination(
                  icon: Icon(_icons[i]),
                  selectedIcon: Icon(_selectedIcons[i], color: AppColors.blue),
                  label: _titles[i],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}
