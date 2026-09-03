import '../../models/match.dart';
import '../../models/player.dart';
import '../../models/standing.dart';

/// Resultado de uma operação de dados, sinalizando se veio da rede
/// (atualizado) ou do cache local (offline).
class DataResult<T> {
  final T? data;
  final bool fromCache;

  const DataResult(this.data, {this.fromCache = false});

  bool get isFromCache => fromCache;
  bool get hasData => data != null;
}

/// Contrato da camada de dados de futebol.
///
/// A interface mantém a UI independente da fonte (API real, demonstração
/// ou cache). Isso permite trocar a implementação sem tocar nas telas.
abstract class FootballApi {
  bool get isDemo;

  /// Próximo jogo do Vasco (agendado, encerrado ou ao vivo).
  Future<DataResult<List<Match>>> nextMatches();

  /// Jogos AO VIVO envolvendo o Vasco.
  Future<DataResult<List<Match>>> liveMatches();

  /// Classificação do campeonato (Brasileirão Série A).
  Future<DataResult<List<Standing>>> standings();

  /// Elenco profissional atual do Vasco.
  Future<DataResult<List<Player>>> squad();
}
