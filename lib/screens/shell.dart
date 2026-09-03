import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../state/app_state.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'more_screen.dart';
import 'squad_screen.dart';
import 'standings_screen.dart';

/// Casca principal do app: barra de navegação inferior com 5 abas.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    MatchesScreen(),
    StandingsScreen(),
    SquadScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento dos dados.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDemo = context.select((AppState s) => s.isDemo);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, color: AppConstants.vascoRed, size: 22),
            SizedBox(width: 8),
            Text('APP TIME VASCO'),
          ],
        ),
        actions: [
          if (isDemo)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: Chip(
                  avatar: Icon(Icons.science_outlined,
                      size: 16, color: AppConstants.vascoRed),
                  label: Text('DEMO',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: AppConstants.vascoRed),
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer),
            label: 'Jogos',
          ),
          NavigationDestination(
            icon: Icon(Icons.format_list_numbered_outlined),
            selectedIcon: Icon(Icons.format_list_numbered),
            label: 'Tabela',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Elenco',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            label: 'Mais',
          ),
        ],
      ),
    );
  }
}
