import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuração da camada de rede.
///
/// Carrega a chave da API a partir do arquivo .env (que NUNCA é
/// versionado — está no .gitignore). Se a chave estiver ausente ou
/// vazia, o app opera em MODO DEMONSTRAÇÃO.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://v3.football.api-sports.io';

  /// Chave injetada em tempo de build via `--dart-define=APIFOOTBALL_KEY=...`
  /// (recomendado para release; não é versionada).
  static const String _definedKey = String.fromEnvironment('APIFOOTBALL_KEY');

  /// Chave da API-Football. Prioridade:
  /// 1) `--dart-define=APIFOOTBALL_KEY=...` (build/release).
  /// 2) arquivo .env (desenvolvimento; o arquivo está no .gitignore).
  static String get apiKey {
    if (_definedKey.isNotEmpty) return _definedKey.trim();
    if (!dotenv.isInitialized) return '';
    return dotenv.env['APIFOOTBALL_KEY']?.trim() ?? '';
  }

  /// Id do Vasco na API (default 129 se não informado).
  static int get teamId {
    const def = String.fromEnvironment('VASCO_TEAM_ID');
    if (def.isNotEmpty && int.tryParse(def) != null) return int.parse(def);
    if (!dotenv.isInitialized) return 129;
    return int.tryParse(dotenv.env['VASCO_TEAM_ID']?.trim() ?? '') ?? 129;
  }

  /// A API-Football possui plano Free com cota diária de requisições.
  static const int freeDailyLimit = 100;

  /// True quando há uma chave configurada (modo real).
  static bool get hasApiKey => apiKey.isNotEmpty;
}
