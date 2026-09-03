/// Dados históricos do Club de Regatas Vasco da Gama.
///
/// REAPROVEITADOS do projeto legado (`legacy_python/central_vasco/historico.py`),
/// verificados a partir de fontes públicas (Wikipédia — tabelas de classificação
/// final —, CBF e site oficial). NENHUM número aqui foi inventado: campos sem
/// valor ficam nulos e são exibidos como "Não disponível".
///
/// Fonte: projeto original App Time Vasco (Flet) — mantido fielmente.
class HistoricalTeamSeason {
  final int year;
  final int finalPosition;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final bool champion;
  final bool relegated;
  final String? note;

  const HistoricalTeamSeason({
    required this.year,
    required this.finalPosition,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.champion,
    required this.relegated,
    this.note,
  });

  int get goalDifference => goalsFor - goalsAgainst;

  double? get aproveitamento {
    if (played <= 0) return null;
    final pontos = wins * 3 + draws;
    return pontos / (played * 3) * 100;
  }
}

class HistoricalFinals {
  final int year;
  final String result;
  final String opponent;
  final bool champion;

  const HistoricalFinals({
    required this.year,
    required this.result,
    required this.opponent,
    required this.champion,
  });
}

class CompetitionHistory {
  final String id;
  final String name;
  final String division;
  final String description;
  final Map<String, String?> summary;
  final List<HistoricalTeamSeason>? seasons;
  final List<HistoricalFinals>? finals;
  final List<String> sources;
  final String? currentSeasonNote;

  const CompetitionHistory({
    required this.id,
    required this.name,
    required this.division,
    required this.description,
    required this.summary,
    this.seasons,
    this.finals,
    required this.sources,
    this.currentSeasonNote,
  });
}

/// Tempo real do Brasileirão (Série A) — temporadas verificadas.
const List<HistoricalTeamSeason> _brasileiraoSeasons = [
  HistoricalTeamSeason(year: 1974, finalPosition: 1, played: 28, wins: 12, draws: 12, losses: 4, goalsFor: 33, goalsAgainst: 18, champion: true, relegated: false, note: 'Campeão (Taça de Prata — 1º título nacional do clube)'),
  HistoricalTeamSeason(year: 1989, finalPosition: 1, played: 19, wins: 9, draws: 8, losses: 2, goalsFor: 27, goalsAgainst: 16, champion: true, relegated: false, note: 'Campeão'),
  HistoricalTeamSeason(year: 1997, finalPosition: 1, played: 33, wins: 21, draws: 7, losses: 5, goalsFor: 69, goalsAgainst: 37, champion: true, relegated: false, note: 'Campeão'),
  HistoricalTeamSeason(year: 2000, finalPosition: 1, played: 32, wins: 15, draws: 9, losses: 8, goalsFor: 54, goalsAgainst: 49, champion: true, relegated: false, note: 'Campeão (Copa João Havelange)'),
  HistoricalTeamSeason(year: 2004, finalPosition: 16, played: 46, wins: 14, draws: 12, losses: 20, goalsFor: 64, goalsAgainst: 68, champion: false, relegated: false, note: '16º colocado. Edição recorde com 24 clubes; permaneceu na Série A.'),
  HistoricalTeamSeason(year: 2008, finalPosition: 18, played: 38, wins: 11, draws: 7, losses: 20, goalsFor: 56, goalsAgainst: 72, champion: false, relegated: true, note: 'Rebaixado'),
  HistoricalTeamSeason(year: 2010, finalPosition: 11, played: 38, wins: 11, draws: 16, losses: 11, goalsFor: 43, goalsAgainst: 45, champion: false, relegated: false),
  HistoricalTeamSeason(year: 2011, finalPosition: 2, played: 38, wins: 19, draws: 12, losses: 7, goalsFor: 57, goalsAgainst: 40, champion: false, relegated: false, note: 'Vice-campeão'),
  HistoricalTeamSeason(year: 2012, finalPosition: 5, played: 38, wins: 16, draws: 10, losses: 12, goalsFor: 45, goalsAgainst: 44, champion: false, relegated: false),
  HistoricalTeamSeason(year: 2013, finalPosition: 18, played: 38, wins: 11, draws: 11, losses: 16, goalsFor: 50, goalsAgainst: 61, champion: false, relegated: true, note: 'Rebaixado'),
  HistoricalTeamSeason(year: 2015, finalPosition: 18, played: 38, wins: 10, draws: 11, losses: 17, goalsFor: 28, goalsAgainst: 54, champion: false, relegated: true, note: 'Rebaixado'),
  HistoricalTeamSeason(year: 2017, finalPosition: 7, played: 38, wins: 15, draws: 11, losses: 12, goalsFor: 40, goalsAgainst: 47, champion: false, relegated: false),
  HistoricalTeamSeason(year: 2018, finalPosition: 16, played: 38, wins: 10, draws: 13, losses: 15, goalsFor: 41, goalsAgainst: 48, champion: false, relegated: false),
  HistoricalTeamSeason(year: 2019, finalPosition: 12, played: 38, wins: 12, draws: 13, losses: 13, goalsFor: 39, goalsAgainst: 45, champion: false, relegated: false),
  HistoricalTeamSeason(year: 2020, finalPosition: 17, played: 38, wins: 10, draws: 11, losses: 17, goalsFor: 37, goalsAgainst: 56, champion: false, relegated: true, note: 'Rebaixado'),
  HistoricalTeamSeason(year: 2023, finalPosition: 15, played: 38, wins: 12, draws: 9, losses: 17, goalsFor: 41, goalsAgainst: 51, champion: false, relegated: false),
  HistoricalTeamSeason(year: 2024, finalPosition: 10, played: 38, wins: 14, draws: 8, losses: 16, goalsFor: 43, goalsAgainst: 56, champion: false, relegated: false),
  HistoricalTeamSeason(year: 2025, finalPosition: 14, played: 38, wins: 13, draws: 6, losses: 19, goalsFor: 55, goalsAgainst: 60, champion: false, relegated: false),
];

/// Finais da Copa do Brasil com participação do Vasco.
const List<HistoricalFinals> _copaBrasilFinals = [
  HistoricalFinals(year: 2006, result: 'Vice-campeão', opponent: 'Flamengo', champion: false),
  HistoricalFinals(year: 2011, result: 'CAMPEÃO', opponent: 'Coritiba', champion: true),
  HistoricalFinals(year: 2025, result: 'Vice-campeão', opponent: 'Corinthians', champion: false),
];

const List<CompetitionHistory> historicalCompetitions = [
  CompetitionHistory(
    id: 'brasileirao',
    name: 'Campeonato Brasileiro',
    division: 'Série A',
    description: 'Principal competição nacional de clubes do Brasil.',
    summary: {
      'titulos': '4',
      'anos_titulos': '1974, 1989, 1997 e 2000',
      'vices': '1',
      'anos_vices': '2011',
      'participacoes': '57',
      'rebaixamentos': '4',
      'anos_rebaixados': '2008, 2013, 2015 e 2020',
    },
    seasons: _brasileiraoSeasons,
    sources: ['Wikipédia (tabelas oficiais por edição)', 'CBF'],
    currentSeasonNote:
        'A temporada 2026 está em andamento — seus dados serão exibidos aqui quando a competição for concluída.',
  ),
  CompetitionHistory(
    id: 'copa_brasil',
    name: 'Copa do Brasil',
    division: 'Competição mata-mata nacional',
    description: 'Torneio eliminatório da CBF disputado por clubes de todas as divisões.',
    summary: {
      'titulos': '1',
      'anos_titulos': '2011',
      'vices': '2',
      'anos_vices': '2006 e 2025',
      'finais': '3',
      'campanha_2011':
          '11 jogos, 5 vitórias, 5 empates e 1 derrota. Na final, 1x0 (São Januário) e 3x2 (Couto Pereira) contra o Coritiba — título pelo gol fora de casa (3x3 no agregado).',
    },
    finals: _copaBrasilFinals,
    sources: ['Wikipédia', 'Globo Esporte', 'Site oficial do Vasco'],
    currentSeasonNote:
        'O histórico completo por temporada da Copa do Brasil será adicionado quando houver fonte confiável para todos os anos.',
  ),
];

/// Totais agregados das temporadas listadas (apenas temporadas verificadas).
class HistoricalSummary {
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final double? aproveitamento;

  const HistoricalSummary({
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.aproveitamento,
  });
}

HistoricalSummary? summarizeSeasons(List<HistoricalTeamSeason>? seasons) {
  if (seasons == null || seasons.isEmpty) return null;
  var played = 0, wins = 0, draws = 0, losses = 0, gf = 0, ga = 0;
  for (final s in seasons) {
    played += s.played;
    wins += s.wins;
    draws += s.draws;
    losses += s.losses;
    gf += s.goalsFor;
    ga += s.goalsAgainst;
  }
  final pontos = wins * 3 + draws;
  final aproveitamento =
      played > 0 ? pontos / (played * 3) * 100 : null;
  return HistoricalSummary(
    played: played,
    wins: wins,
    draws: draws,
    losses: losses,
    goalsFor: gf,
    goalsAgainst: ga,
    goalDifference: gf - ga,
    aproveitamento: aproveitamento,
  );
}
