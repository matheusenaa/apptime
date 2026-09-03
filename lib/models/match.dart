/// Modelo de uma partida (jogo) do Vasco, mapeado da API-Football.
class Match {
  final int id;
  final String competition;
  final String status; // scheduled | live | finished | postponed...
  final DateTime? date;
  final String homeTeam;
  final String awayTeam;
  final int homeGoals;
  final int awayGoals;
  final String? minute;
  final String venue;

  const Match({
    required this.id,
    required this.competition,
    required this.status,
    this.date,
    required this.homeTeam,
    required this.awayTeam,
    this.homeGoals = 0,
    this.awayGoals = 0,
    this.minute,
    this.venue = '',
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    final fixture = (json['fixture'] ?? {}) as Map<String, dynamic>;
    final league = (json['league'] ?? {}) as Map<String, dynamic>;
    final teams = (json['teams'] ?? {}) as Map<String, dynamic>;
    final goals = (json['goals'] ?? {}) as Map<String, dynamic>;

    final homeT = (teams['home'] ?? {}) as Map<String, dynamic>;
    final awayT = (teams['away'] ?? {}) as Map<String, dynamic>;

    final leagueName = league['name']?.toString() ?? 'Competição';
    final leagueRound = league['round']?.toString() ?? '';

    // Data da partida
    DateTime? matchDate;
    final rawDate = fixture['date']?.toString();
    if (rawDate != null && rawDate.isNotEmpty) {
      matchDate = DateTime.tryParse(rawDate);
    }

    // Minuto/período para jogos ao vivo
    String? minute;
    final statusShort = fixture['status']?['short']?.toString() ?? '';
    if (statusShort == '1H' ||
        statusShort == '2H' ||
        statusShort == 'HT' ||
        statusShort == 'ET' ||
        statusShort == 'P') {
      minute = fixture['status']?['elapsed']?.toString() ?? '';
    }

    return Match(
      id: (fixture['id'] as num?)?.toInt() ?? 0,
      competition: leagueName.isEmpty ? leagueRound : leagueName,
      status: _normalizeStatus(statusShort),
      date: matchDate,
      homeTeam: homeT['name']?.toString() ?? 'Casa',
      awayTeam: awayT['name']?.toString() ?? 'Visitante',
      homeGoals: (goals['home'] as num?)?.toInt() ?? 0,
      awayGoals: (goals['away'] as num?)?.toInt() ?? 0,
      minute: minute,
      venue: fixture['venue']?['name']?.toString() ?? '',
    );
  }

  static String _normalizeStatus(String short) {
    switch (short) {
      case '1H':
      case '2H':
      case 'HT':
      case 'ET':
      case 'P':
        return 'live';
      case 'FT':
      case 'AET':
      case 'PEN':
        return 'finished';
      case 'TBD':
      case 'NS':
        return 'scheduled';
      default:
        return short.toLowerCase().isEmpty ? 'scheduled' : short.toLowerCase();
    }
  }

  bool get isVascoHome => homeTeam.toLowerCase().contains('vasco');

  bool get isLive => status == 'live';

  bool get isFinished => status == 'finished';

  bool get isScheduled => status == 'scheduled';

  String get scoreLine => '$homeGoals x $awayGoals';

  String get vascaoScore => isVascoHome ? '$homeGoals' : '$awayGoals';

  String get opponentScore => isVascoHome ? '$awayGoals' : '$homeGoals';

  String get opponentName => isVascoHome ? awayTeam : homeTeam;

  String get statusLabel {
    if (isLive) {
      final m = (minute ?? '').trim();
      return m.isEmpty ? 'AO VIVO' : "$m'";
    }
    if (isFinished) return 'ENCERRADO';
    return 'AGENDADO';
  }
}
