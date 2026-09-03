import '../../models/match.dart';
import '../../models/player.dart';
import '../../models/standing.dart';
import 'football_api.dart';

/// MODO DEMONSTRAÇÃO — fallback quando não há chave de API configurada.
///
/// PROIBIDO exibir dados como se fossem reais. Todos os dados aqui são
/// rotulados explicitamente como EXEMPLO (modo demonstração). Não há
/// placares, resultados ou classificações inventados como se fossem de
/// verdade — apenas uma indicação clara de que o modo real exige uma
/// chave de API.
class DemoFootballApi implements FootballApi {
  @override
  bool get isDemo => true;

  @override
  Future<DataResult<List<Match>>> nextMatches() async {
    // Nenhum jogo real é fabricado. A UI mostra a mensagem de configuração.
    return const DataResult(null);
  }

  @override
  Future<DataResult<List<Match>>> liveMatches() async {
    return const DataResult(null);
  }

  @override
  Future<DataResult<List<Standing>>> standings() async {
    return const DataResult(null);
  }

  @override
  Future<DataResult<List<Player>>> squad() async {
    return const DataResult(null);
  }
}
