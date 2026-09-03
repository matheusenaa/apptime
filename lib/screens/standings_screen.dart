import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../state/app_state.dart';
import '../widgets/demo_banner.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/offline_banner.dart';
import '../widgets/standing_row.dart';

/// Tela de classificação do Campeonato Brasileiro (Série A).
class StandingsScreen extends StatelessWidget {
  const StandingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;

    if (state.isDemo) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          DemoBanner(),
          SizedBox(height: 20),
          EmptyState(
            icon: Icons.format_list_numbered,
            title: 'Classificação indisponível',
            subtitle:
                'A tabela do Brasileirão é carregada com a chave da '
                'API-Football. Configure em Configurações para ver os dados reais.',
          ),
        ],
      );
    }

    if (state.loadingStandings && !state.initialized) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LoadingSkeleton(lines: 6),
      );
    }

    final list = state.standings;
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<AppState>().refreshStandings(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: const [
            EmptyState(
              icon: Icons.table_chart,
              title: 'Sem dados da tabela',
              subtitle: 'Não foi possível carregar a classificação.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: state.refreshStandings,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          if (state.offline) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: OfflineBanner(),
            ),
            const SizedBox(height: 12),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'BRASILEIRÃO — SÉRIE A',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1,
                color: AppConstants.vascoRed,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: const [
                SizedBox(width: 22),
                SizedBox(width: 6),
                Expanded(child: Text('Time', style: _headerStyle)),
                _HeaderCell('PJ'),
                _HeaderCell('V'),
                _HeaderCell('E'),
                _HeaderCell('D'),
                _HeaderCell('GP'),
                _HeaderCell('SG'),
                _HeaderCell('PTS', strong: true),
              ],
            ),
          ),
          const Divider(),
          ...list.map(
            (s) => StandingRow(standing: s),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Destaque em vermelho = Vasco. Os dados são atualizados '
              'periodicamente; puxe para baixo para atualizar.',
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

const _headerStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w800,
  color: Colors.grey,
);

class _HeaderCell extends StatelessWidget {
  final String text;
  final bool strong;
  const _HeaderCell(this.text, {this.strong = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
          color: Colors.grey,
        ),
      ),
    );
  }
}
