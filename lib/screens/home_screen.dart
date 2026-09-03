import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../state/app_state.dart';
import '../widgets/demo_banner.dart';
import '../widgets/loading_skeleton.dart';
import '../widgets/match_card.dart';
import '../widgets/offline_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/vasco_crest.dart';
import 'history_screen.dart';
import 'news_screen.dart';

/// Tela inicial: destaque do próximo jogo/ao vivo + acesso rápido.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<AppState>().refreshAll(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _HeroHeader(),
          const SizedBox(height: 16),
          const _FeaturedSection(),
          const SizedBox(height: 24),
          const SectionHeader(icon: Icons.history, title: 'Acesso rápido'),
          Row(
            children: [
              Expanded(
                child: _QuickCard(
                  icon: Icons.timeline,
                  label: 'Histórico',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickCard(
                  icon: Icons.newspaper,
                  label: 'Notícias',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NewsScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _AboutCard(),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F1F1F), Color(0xFF000000)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const VascoCrest(size: 72),
          const SizedBox(height: 12),
          Text(
            AppConstants.nomeClube.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1869 mancebos, 129 anos de história',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;

    if (state.isDemo) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DemoBanner(),
          const SizedBox(height: 16),
          const SectionHeader(icon: Icons.sports_soccer, title: 'Próximo jogo'),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Para acompanhar jogos e classificações em tempo real, '
              'configure sua chave da API-Football em Configurações.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      );
    }

    if (state.loadingMatches && !state.initialized) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SectionHeader(icon: Icons.sports_soccer, title: 'Próximo jogo'),
          LoadingSkeleton(lines: 2),
        ],
      );
    }

    final featured = state.featuredMatch;
    if (featured == null) {
      return const SectionHeader(
        icon: Icons.sports_soccer,
        title: 'Nenhum jogo encontrado',
      );
    }

    final isLive = featured.isLive;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.offline) ...[
          const OfflineBanner(),
          const SizedBox(height: 16),
        ],
        SectionHeader(
          icon: Icons.sports_soccer,
          title: isLive ? 'AO VIVO AGORA' : 'PRÓXIMA PARTIDA',
          trailing: isLive ? 'atualiza automaticamente' : null,
        ),
        MatchCard(match: featured),
      ],
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(
            children: [
              Icon(icon, size: 28, color: AppConstants.vascoRed),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDemo = context.select((AppState s) => s.isDemo);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SOBRE ESTE APP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: scheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isDemo
                  ? 'Em modo demonstração, o App Time Vasco exibe informações '
                      'históricas e institucionais do clube. Ative dados reais '
                      'em Configurações adicionando sua chave da API-Football.'
                  : 'O App Time Vasco acompanha o Gigante da Colina com dados '
                      'reais de jogos, classificação e elenco fornecidos pela '
                      'API-Football, além de um completo histórico do clube.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
