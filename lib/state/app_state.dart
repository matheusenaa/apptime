import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../models/standing.dart';
import '../repositories/vasco_repository.dart';
import '../services/api/football_api.dart';
import '../services/storage/preferences_service.dart';

/// Estado central do aplicativo (camada "GameState").
///
/// Expõe dados observáveis (próximos jogos, ao vivo, tabela, elenco),
/// flags de carregamento/offline/demonstração, e o modo de tema. As telas
/// consomem este estado via `ChangeNotifierProvider`.
class AppState extends ChangeNotifier {
  AppState({VascoRepository? repository, PreferencesService? prefs})
      : _repo = repository ?? VascoRepository(),
        _prefs = prefs ?? PreferencesService.instance;

  final VascoRepository _repo;
  final PreferencesService _prefs;

  Timer? _pollTimer;

  // --- Dados -------------------------------------------------------------
  List<Match> _nextMatches = [];
  List<Match> _live = [];
  List<Standing> _standings = [];
  List<Player> _squad = [];

  bool _loadingMatches = false;
  bool _loadingStandings = false;
  bool _loadingSquad = false;
  bool _offline = false;
  bool _initialized = false;

  ThemeMode _themeMode = ThemeMode.system;

  // Getters
  List<Match> get nextMatches => _nextMatches;
  List<Match> get live => _live;
  List<Standing> get standings => _standings;
  List<Player> get squad => _squad;
  bool get loadingMatches => _loadingMatches;
  bool get loadingStandings => _loadingStandings;
  bool get loadingSquad => _loadingSquad;
  bool get offline => _offline;
  bool get initialized => _initialized;
  bool get isDemo => _repo.isDemo;
  ThemeMode get themeMode => _themeMode;

  /// Próximo jogo agendado/ao vivo (para destaque na home).
  Match? get featuredMatch {
    if (_live.isNotEmpty) return _live.first;
    if (_nextMatches.isNotEmpty) return _nextMatches.first;
    return null;
  }

  // --- Tema --------------------------------------------------------------
  Future<void> loadTheme() async {
    final mode = await _prefs.getThemeMode();
    _themeMode = _parseThemeMode(mode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setThemeMode(mode.name);
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // --- Inicialização e refresh ------------------------------------------
  /// Carrega tudo na primeira abertura.
  Future<void> init() async {
    if (_initialized) return;
    await loadTheme();
    await refreshAll();
    _startPolling();
  }

  /// Polling inteligente: frequente quando há jogo ao vivo, espaçado fora.
  void _startPolling() {
    _pollTimer?.cancel();
    final interval =
        _live.isNotEmpty ? AppConstants.liveRefreshInterval : AppConstants.idleRefreshInterval;
    _pollTimer = Timer(interval, _pollTick);
  }

  Future<void> _pollTick() async {
    // Ao vivo ligado → só atualiza jogos (mais frequente). Senão, atualiza tudo.
    if (_live.isNotEmpty) {
      await refreshMatches();
    } else {
      await refreshAll();
    }
    if (!_disposed) _startPolling();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    super.dispose();
  }

  /// Atualiza todos os dados (polling).
  Future<void> refreshAll() async {
    await Future.wait([
      refreshMatches(),
      refreshStandings(),
      refreshSquad(),
    ]);
    _initialized = true;
    notifyListeners();
  }

  // --- Matches -------------------------------------------------------------
  Future<DataResult<List<Match>>> refreshMatches() async {
    _loadingMatches = true;
    _notify();

    List<Match> result = [];
    var fromCache = false;
    try {
      var r = await _repo.liveMatches();
      if (r.hasData) result = r.data!;
      fromCache = r.isFromCache;

      // Enriquecer com próximos jogos (se ao vivo vazio)
      if (result.isEmpty || !result.any((m) => m.isLive)) {
        final r2 = await _repo.nextMatches();
        if (r2.hasData && result.isEmpty) {
          result = r2.data!;
        } else if (r2.hasData && result.any((m) => m.isLive)) {
          // mantém ao vivo + adiciona agendados complementares
          final existingIds = result.map((m) => m.id).toSet();
          final extra = r2.data!
              .where((m) => !existingIds.contains(m.id))
              .toList();
          result = [...result, ...extra];
        }
        fromCache = fromCache || r2.isFromCache;
      }
    } catch (_) {
      fromCache = true;
    }

    if (result.isEmpty) {
      _live = [];
      _nextMatches = [];
    } else {
      _live = result.where((m) => m.isLive).toList();
      _nextMatches = result.where((m) => !m.isLive).toList();
    }

    _loadingMatches = false;
    _offline = fromCache && _live.isEmpty;
    _notify();
    return DataResult(result, fromCache: fromCache);
  }

  // --- Standings ------------------------------------------------------------
  Future<DataResult<List<Standing>>> refreshStandings() async {
    _loadingStandings = true;
    _notify();
    var fromCache = false;
    try {
      final r = await _repo.standings();
      _standings = r.data ?? _standings;
      fromCache = r.isFromCache;
    } catch (_) {
      fromCache = true;
    }
    _loadingStandings = false;
    _notify();
    return DataResult(_standings, fromCache: fromCache);
  }

  // --- Elenco -------------------------------------------------------------
  Future<DataResult<List<Player>>> refreshSquad() async {
    _loadingSquad = true;
    _notify();
    var fromCache = false;
    try {
      final r = await _repo.squad();
      _squad = r.data ?? _squad;
      fromCache = r.isFromCache;
    } catch (_) {
      fromCache = true;
    }
    _loadingSquad = false;
    _notify();
    return DataResult(_squad, fromCache: fromCache);
  }

  void _notify() {
    if (!_disposed && hasListeners) notifyListeners();
  }
}
