/// Modelo de uma linha da classificação (tabela).
class Standing {
  final int position;
  final String team;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  final int goalDifference;
  final bool isVasco;

  const Standing({
    required this.position,
    required this.team,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
    required this.goalDifference,
    required this.isVasco,
  });

  factory Standing.fromJson(Map<String, dynamic> json, {int vascoId = 0}) {
    final team = json['team'] ?? {};
    final all = json['all'] ?? json['points'];
    final goals = json['goals'] ?? {};

    final Map<String, dynamic> allMap =
        all is Map<String, dynamic> ? all : const {};
    final Map<String, dynamic> teamMap =
        team is Map<String, dynamic> ? team : const {};
    final Map<String, dynamic> goalsMap =
        goals is Map<String, dynamic> ? goals : const {};

    final Map<String, dynamic> p = allMap;
    final forGoals = (goalsMap['for'] as num?)?.toInt() ?? 0;
    final against = (goalsMap['against'] as num?)?.toInt() ?? 0;

    return Standing(
      position: (json['rank'] as num?)?.toInt() ?? 0,
      team: teamMap['name']?.toString() ?? '—',
      played: (p['played'] as num?)?.toInt() ?? 0,
      wins: (p['win'] as num?)?.toInt() ?? 0,
      draws: (p['draw'] as num?)?.toInt() ?? 0,
      losses: (p['lose'] as num?)?.toInt() ?? 0,
      goalsFor: forGoals,
      goalsAgainst: against,
      points: (json['points'] as num?)?.toInt() ?? 0,
      goalDifference: forGoals - against,
      isVasco: (teamMap['id'] as num?)?.toInt() == vascoId,
    );
  }
}
