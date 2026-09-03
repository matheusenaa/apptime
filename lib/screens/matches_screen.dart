import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/demo_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/match_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/section_header.dart';

/// Tela de jogos: AO VIVO (com atualização automática), próximos e recentes.
class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.isDemo) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          DemoBanner(),
          SizedBox(height: 20),
          EmptyState(
            icon: Icons.sports_soccer,
            title: 'Jogos não carregados',
            subtitle:
                'Em modo demonstração os jogos não são exibidos. Configure a '
                'chave da API-Football para dados reais.',
          ),
        ],
      );
    }

    if (state.loadingMatches && !state.initialized) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LoadingSkeleton(lines: 5),
      );
    }

    final live = state.live;
    final next = state.nextMatches;

    if (live.isEmpty && next.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<AppState>().refreshMatches(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (state.offline) ...[
              const OfflineBanner(),
              const SizedBox(height: 20),
            ],
            const EmptyState(
              icon: Icons.event_busy,
              title: 'Nenhum jogo encontrado',
              subtitle: 'Puxe para atualizar.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: state.refreshMatches,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (state.offline) ...[
            const OfflineBanner(),
            const SizedBox(height: 16),
          ],
          if (live.isNotEmpty) ...[
            const SectionHeader(
              icon: Icons.radio_button_checked,
              title: 'AO VIVO',
              trailing: '30s',
            ),
            ...live.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MatchCard(match: m),
                )),
            const SizedBox(height: 16),
          ],
          if (next.isNotEmpty) ...[
            const SectionHeader(icon: Icons.calendar_today, title: 'Próximos jogos'),
            ...next.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MatchCard(match: m),
                )),
          ],
        ],
      ),
    );
  }
}
