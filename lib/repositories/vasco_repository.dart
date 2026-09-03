import 'dart:convert';

import '../core/network/api_config.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../models/standing.dart';
import '../services/api/api_football_service.dart';
import '../services/api/demo_service.dart';
import '../services/api/football_api.dart';
import '../services/storage/preferences_service.dart';

/// Orquestra a obtenção de dados: API real → cache → modo demonstração.
///
/// Fluxo (por tela):
/// 1. Tenta a API (se houver chave configurada).
/// 2. Em sucesso: devolve dados atuais e grava no cache local.
/// 3. Em erro de rede: devolve o cache local (offline) sinalizado.
/// 4. Sem chave: ativa o modo demonstração.
class VascoRepository {
  VascoRepository({FootballApi? api, PreferencesService? prefs})
      : _api = api ?? _buildApi(),
        _prefs = prefs ?? PreferencesService.instance;

  final FootballApi _api;
  final PreferencesService _prefs;

  static FootballApi _buildApi() {
    if (ApiConfig.hasApiKey) {
      return ApiFootballService();
    }
    // Sem chave configurada → modo demonstração.
    return DemoFootballApi();
  }

  bool get isDemo => _api.isDemo;

  // --- Próximos jogos -----------------------------------------------------
  Future<DataResult<List<Match>>> nextMatches() async {
    if (_api.isDemo) return const DataResult(null);
    try {
      final r = await _api.nextMatches();
      if (r.hasData) {
        await _prefs.cacheMatches(
          r.data!.map((m) => _matchToMap(m)).toList(),
        );
        await _prefs.recordLastOnlineUpdate();
      }
      return r;
    } catch (_) {
      return DataResult(await _readCachedMatches(), fromCache: true);
    }
  }

  // --- AO VIVO -------------------------------------------------------------
  Future<DataResult<List<Match>>> liveMatches() async {
    if (_api.isDemo) return const DataResult(null);
    try {
      final r = await _api.liveMatches();
      if (r.hasData) {
        await _prefs.cacheMatches(
          r.data!.map((m) => _matchToMap(m)).toList(),
        );
        await _prefs.recordLastOnlineUpdate();
      }
      return r;
    } catch (_) {
      return DataResult(await _readCachedMatches(), fromCache: true);
    }
  }

  // --- Classificação ---------------------------------------------------------
  Future<DataResult<List<Standing>>> standings() async {
    if (_api.isDemo) return const DataResult(null);
    try {
      final r = await _api.standings();
      if (r.hasData) {
        await _prefs.cacheStandings(
          r.data!.map((s) => _standingToMap(s)).toList(),
        );
        await _prefs.recordLastOnlineUpdate();
      }
      return r;
    } catch (_) {
      return DataResult(await _readCachedStandings(), fromCache: true);
    }
  }

  // --- Elenco ----------------------------------------------------------------
  Future<DataResult<List<Player>>> squad() async {
    if (_api.isDemo) return const DataResult(null);
    try {
      final r = await _api.squad();
      if (r.hasData) {
        await _prefs.cacheSquad(r.data!.map((p) => _playerToMap(p)).toList());
        await _prefs.recordLastOnlineUpdate();
      }
      return r;
    } catch (_) {
      return DataResult(await _readCachedSquad(), fromCache: true);
    }
  }

  Future<List<Match>?> _readCachedMatches() async {
    final raw = await _prefs.getCacheMatches();
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Match.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<List<Standing>?> _readCachedStandings() async {
    final raw = await _prefs.getCacheStandings();
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Standing.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<List<Player>?> _readCachedSquad() async {
    final raw = await _prefs.getCacheSquad();
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Player.fromMap((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // Serializadores (para cache)
  Map<String, dynamic> _matchToMap(Match m) => {
        'fixture': {'id': m.id, 'date': m.date?.toIso8601String(), 'status': {'short': m.status}, 'venue': {'name': m.venue}},
        'league': {'name': m.competition},
        'teams': {
          'home': {'name': m.homeTeam},
          'away': {'name': m.awayTeam},
        },
        'goals': {'home': m.homeGoals, 'away': m.awayGoals},
      };

  Map<String, dynamic> _standingToMap(Standing s) => {
        'rank': s.position,
        'team': {'name': s.team, 'id': s.isVasco ? ApiConfig.teamId : 0},
        'points': s.points,
        'all': {
          'played': s.played,
          'win': s.wins,
          'draw': s.draws,
          'lose': s.losses,
        },
        'goals': {'for': s.goalsFor, 'against': s.goalsAgainst},
      };

  Map<String, dynamic> _playerToMap(Player p) => {
        'number': p.number,
        'name': p.name,
        'position': p.position,
        'photo': p.photo,
      };
}
