import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../data/historical_data.dart';

/// Tela de histórico — Campeonato Brasileiro e Copa do Brasil.
///
/// Dados verificados (nada é inventado). Campos sem fonte ficam nulos e são
/// exibidos como "Não disponível".
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: Column(
        children: [
          TabBar(
            controller: _tab,
            tabs: const [
              Tab(text: 'Brasileirão'),
              Tab(text: 'Copa do Brasil'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _BrasileiraoView(data: historicalCompetitions[0]),
                _CopaBrasilView(data: historicalCompetitions[1]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Brasileirão
// ---------------------------------------------------------------------------
class _BrasileiraoView extends StatelessWidget {
  final CompetitionHistory data;
  const _BrasileiraoView({required this.data});

  @override
  Widget build(BuildContext context) {
    final summary = data.summary;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryGrid(summary: summary),
        const SizedBox(height: 16),
        _TotalsCard(seasons: data.seasons),
        if (data.currentSeasonNote != null) ...[
          const SizedBox(height: 16),
          _NoteCard(text: data.currentSeasonNote!),
        ],
        const SizedBox(height: 10),
        const Text('TEMPORADAS',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1)),
        const SizedBox(height: 8),
        ...(data.seasons ?? []).map(
          (s) => _SeasonRow(season: s),
        ),
        const SizedBox(height: 12),
        _SourcesRow(sources: data.sources),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final Map<String, String?> summary;
  const _SummaryGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = [
      ('Títulos', summary['titulos']),
      ('Vices', summary['vices']),
      ('Participações', summary['participacoes']),
      ('Rebaixamentos', summary['rebaixamentos']),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: items.map((it) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                it.$2 ?? '—',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppConstants.vascoRed,
                ),
              ),
              Text(
                it.$1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final List<HistoricalTeamSeason>? seasons;
  const _TotalsCard({required this.seasons});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = summarizeSeasons(seasons);
    if (total == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOTAIS DAS TEMPORADAS LISTADAS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: scheme.secondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TotalItem(label: 'Jogos', value: '${total.played}'),
                _TotalItem(label: 'Vitórias', value: '${total.wins}'),
                _TotalItem(label: 'Empates', value: '${total.draws}'),
                _TotalItem(label: 'Derrotas', value: '${total.losses}'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TotalItem(label: 'Gols pró', value: '${total.goalsFor}'),
                _TotalItem(label: 'Gols contra', value: '${total.goalsAgainst}'),
                _TotalItem(label: 'Saldo', value: '${total.goalDifference}'),
                _TotalItem(
                    label: 'Aproveit.',
                    value: total.aproveitamento != null
                        ? '${total.aproveitamento!.toStringAsFixed(1)}%'
                        : '—'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalItem extends StatelessWidget {
  final String label;
  final String value;
  const _TotalItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: scheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _SeasonRow extends StatelessWidget {
  final HistoricalTeamSeason season;
  const _SeasonRow({required this.season});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: season.champion
            ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04))
            : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: season.champion
            ? Border.all(color: AppConstants.vascoRed, width: 1.2)
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                season.champion ? '🏆' : season.relegated ? '🔻' : '◆',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(width: 8),
              Text(
                season.year.toString(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  season.champion
                      ? 'CAMPEÃO'
                      : '${season.finalPosition}º colocado',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: season.champion ? AppConstants.vascoRed : scheme.onSurface,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                season.relegated ? 'Rebaixado' : '',
                style: TextStyle(
                  fontSize: 10,
                  color: scheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat('PJ', season.played),
              _Stat('V', season.wins),
              _Stat('E', season.draws),
              _Stat('D', season.losses),
              _Stat('GP', season.goalsFor),
              _Stat('GC', season.goalsAgainst),
              _Stat('SG', season.goalDifference),
              _Stat('APR', season.aproveitamento?.toStringAsFixed(0) ?? '—'),
            ],
          ),
          if (season.note != null) ...[
            const SizedBox(height: 6),
            Text(
              season.note!,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.4,
                color: scheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final Object? value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value?.toString() ?? '—',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: scheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String text;
  const _NoteCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: scheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Copa do Brasil
// ---------------------------------------------------------------------------
class _CopaBrasilView extends StatelessWidget {
  final CompetitionHistory data;
  const _CopaBrasilView({required this.data});

  @override
  Widget build(BuildContext context) {
    final summary = data.summary;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryGrid(summary: summary),
        const SizedBox(height: 16),
        if (summary['campanha_2011'] != null) ...[
          _NoteCard(text: 'Campanha do título (2011): ${summary['campanha_2011']}'),
          const SizedBox(height: 16),
        ],
        const Text('FINAIS',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1)),
        const SizedBox(height: 8),
        ...(data.finals ?? []).map((f) => _FinalRow(f: f)),
        if (data.currentSeasonNote != null) ...[
          const SizedBox(height: 12),
          _NoteCard(text: data.currentSeasonNote!),
        ],
        const SizedBox(height: 12),
        _SourcesRow(sources: data.sources),
      ],
    );
  }
}

class _FinalRow extends StatelessWidget {
  final HistoricalFinals f;
  const _FinalRow({required this.f});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isChampion = f.year == 2011;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: isChampion ? Border.all(color: AppConstants.vascoRed, width: 1.2) : null,
      ),
      child: Row(
        children: [
          Text('${f.year}',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'x ${f.opponent}',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
          Text(
            f.champion ? 'CAMPEÃO' : 'Vice',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: f.champion ? AppConstants.vascoRed : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SourcesRow extends StatelessWidget {
  final List<String> sources;
  const _SourcesRow({required this.sources});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      'Fontes: ${sources.join(', ')}',
      style: TextStyle(
        fontSize: 10.5,
        color: scheme.onSurface.withValues(alpha: 0.45),
      ),
    );
  }
}
