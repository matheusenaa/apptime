import 'package:flutter/material.dart';

/// Constantes centrais do App Time Vasco.
///
/// Mantém em um só lugar a identidade do clube, textos padroes e
/// parametros de configuração. As cores seguem a identidade preto/branco
/// do Club de Regatas Vasco da Gama, com vermelho usado de forma pontual
/// (Cruz de Malta e destaques).
class AppConstants {
  AppConstants._();

  // Identidade do clube
  static const String nomeClube = 'CR Vasco da Gama';
  static const String nomeApp = 'App Time Vasco';
  static const String tagline = 'Sou Vasco. Nada a declarar.';

  // Cores principais (identidade preto/branco, vermelho pontual)
  static const Color vascoRed = Color(0xFFE30613);
  static const Color crossOfMaltaRed = Color(0xFFB80A1C);

  // Tema escuro
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkCard = Color(0xFF161616);
  static const Color darkCardAlt = Color(0xFF1F1F1F);
  static const Color darkBorder = Color(0xFF2A2A2A);

  // Tema claro
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardAlt = Color(0xFFEFEFEF);
  static const Color lightBorder = Color(0xFFDDDDDD);

  // Id do Vasco na API-Football (Brazil Serie A / Copa do Brasil).
  // Este id e estavel na API-Football: 129 = Vasco da Gama.
  static const int teamId = 129;

  // Pooling em tempo real (em segundos)
  static const Duration liveRefreshInterval = Duration(seconds: 30);
  static const Duration idleRefreshInterval = Duration(minutes: 5);

  // Mensagens amigaveis
  static const String msgSemConexao =
      'Sem conexão. Exibindo as últimas informações disponíveis.';
  static const String msgErroGenerico =
      'Não foi possível atualizar os dados. Verifique sua conexão e tente novamente.';
}
