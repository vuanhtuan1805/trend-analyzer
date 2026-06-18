import 'package:flutter/material.dart';

import 'screens/research_dashboard_screen.dart';
import 'screens/search_screen.dart';
import 'screens/trend_analysis_screen.dart';
import 'services/openalex_service.dart';
import 'state/research_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.openAlexService});

  final OpenAlexService? openAlexService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Journal Trend Analyzer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF15616D),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        useMaterial3: true,
      ),
      home: ResearchAppShell(
        openAlexService: openAlexService ?? OpenAlexService(),
      ),
    );
  }
}

class ResearchAppShell extends StatefulWidget {
  const ResearchAppShell({super.key, required this.openAlexService});

  final OpenAlexService openAlexService;

  @override
  State<ResearchAppShell> createState() => _ResearchAppShellState();
}

class _ResearchAppShellState extends State<ResearchAppShell> {
  late final ResearchController _controller;
  int _selectedIndex = 0;

  static const _destinations = [
    _AppDestination(
      label: 'Search',
      icon: Icons.search_outlined,
      selectedIcon: Icons.search,
    ),
    _AppDestination(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    _AppDestination(
      label: 'Trends',
      icon: Icons.stacked_line_chart_outlined,
      selectedIcon: Icons.stacked_line_chart,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = ResearchController(openAlexService: widget.openAlexService);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      SearchScreen(controller: _controller),
      ResearchDashboardScreen(
        controller: _controller,
        onOpenSearch: () => _selectDestination(0),
        onOpenTrends: () => _selectDestination(2),
      ),
      TrendAnalysisScreen(controller: _controller),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useNavigationRail = constraints.maxWidth >= 840;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Journal Trend Analyzer'),
            centerTitle: false,
          ),
          bottomNavigationBar: useNavigationRail
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _selectDestination,
                  destinations: [
                    for (final destination in _destinations)
                      NavigationDestination(
                        icon: Icon(destination.icon),
                        selectedIcon: Icon(destination.selectedIcon),
                        label: destination.label,
                      ),
                  ],
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (useNavigationRail)
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _selectDestination,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final destination in _destinations)
                        NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(destination.selectedIcon),
                          label: Text(destination.label),
                        ),
                    ],
                  ),
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: screens),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AppDestination {
  const _AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
