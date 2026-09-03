import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/network/api_config.dart';
import '../../models/match.dart';
import '../../models/player.dart';
import '../../models/standing.dart';
import 'football_api.dart';

/// Implementação real usando a API-Football (api-sports.io).
///
/// Usa a chave contida no .env. Lança [ApiFootballException] em caso de
/// erro de rede ou resposta não-2xx, para que a camada de repositório
/// possa decidir entre cache e mensagem amigável.
class ApiFootballService implements FootballApi {
  ApiFootballService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  bool get isDemo => false;

  Map<String, String> get _headers => {
        'x-apisports-key': ApiConfig.apiKey,
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>> _get(String endpoint) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    final res = await _client.get(uri, headers: _headers).timeout(
          const Duration(seconds: 15),
        );

    if (res.statusCode != 200) {
      throw ApiFootballException(
        'API retornou ${res.statusCode}. Verifique sua chave e a cota diária.',
      );
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final errors = body['errors'] as Map<String, dynamic>? ?? const {};
    if (errors.isNotEmpty && body['response'] == null) {
      throw ApiFootballException(errors.values.join('; '));
    }
    return body;
  }

  // ---------------------------------------------------------------------
  // Próximos jogos do Vasco (próximas 10 partidas)
  // ---------------------------------------------------------------------
  @override
  Future<DataResult<List<Match>>> nextMatches() async {
    final body = await _get(
      'fixtures?team=${ApiConfig.teamId}&next=10',
    );
    final list = (body['response'] as List? ?? const [])
        .map((e) => Match.fromJson(e as Map<String, dynamic>))
        .toList();
    return DataResult(list);
  }

  // ---------------------------------------------------------------------
  // Jogos ao vivo / últimas 10 do Vasco
  // ---------------------------------------------------------------------
  @override
  Future<DataResult<List<Match>>> liveMatches() async {
    final body = await _get(
      'fixtures?team=${ApiConfig.teamId}&last=10',
    );
    final all = (body['response'] as List? ?? const [])
        .map((e) => Match.fromJson(e as Map<String, dynamic>))
        .toList();
    // Prioriza ao vivo; se não houver, traz o último jogo de todos.
    final live = all.where((m) => m.isLive).toList();
    return DataResult(live.isEmpty ? all.take(1).toList() : live);
  }

  // ---------------------------------------------------------------------
  // Classificação do Brasileirão Série A (temporada atual)
  // ---------------------------------------------------------------------
  @override
  Future<DataResult<List<Standing>>> standings() async {
    final year = DateTime.now().year;
    final body = await _get(
      'standings?league=71&season=$year',
    );
    final leagues =
        (body['response'] as List? ?? const []).cast<Map<String, dynamic>>();
    if (leagues.isEmpty) return const DataResult(null);

    final rows = leagues.first['league']?['standings'] as List? ?? const [];
    final result = <Standing>[];
    for (final row in rows) {
      if (row is Map<String, dynamic>) {
        result.add(Standing.fromJson(row, vascoId: ApiConfig.teamId));
      }
    }
    return DataResult(result);
  }

  // ---------------------------------------------------------------------
  // Elenco profissional atual do Vasco
  // ---------------------------------------------------------------------
  @override
  Future<DataResult<List<Player>>> squad() async {
    final body = await _get('players/squads?team=${ApiConfig.teamId}');
    final response = (body['response'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    if (response.isEmpty) return const DataResult(null);

    final players = response.first['players'] as List? ?? const [];
    final result = players
        .whereType<Map<String, dynamic>>()
        .map(
          (p) => Player(
            number: p['number']?.toString() ?? '-',
            name: p['name']?.toString() ?? '-',
            position: p['position']?.toString() ?? '-',
            photo: p['photo']?.toString(),
          ),
        )
        .toList();
    return DataResult(result);
  }
}

/// Erro amigável da camada de API.
class ApiFootballException implements Exception {
  final String message;
  ApiFootballException(this.message);

  @override
  String toString() => message;
}
