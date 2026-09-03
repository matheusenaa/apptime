import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/demo_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/player_card.dart';

/// Tela de elenco profissional do Vasco.
class SquadScreen extends StatelessWidget {
  const SquadScreen({super.key});

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
            icon: Icons.groups,
            title: 'Elenco indisponível',
            subtitle:
                'A lista de atletas é carregada com a chave da API-Football '
                'em Configurações.',
          ),
        ],
      );
    }

    if (state.loadingSquad && !state.initialized) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LoadingSkeleton(lines: 6),
      );
    }

    final squad = state.squad;
    if (squad.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<AppState>().refreshSquad(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: const [
            EmptyState(
              icon: Icons.groups,
              title: 'Sem dados do elenco',
              subtitle: 'Não foi possível carregar os atletas.',
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 0.82,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => PlayerCard(player: squad[i]),
              childCount: squad.length,
            ),
          ),
        ),
      ],
    );
  }
}
