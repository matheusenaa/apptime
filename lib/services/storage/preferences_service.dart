import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Camada de persistência local (preferências + cache leve).
///
/// Usa SharedPreferences — suficiente para cache simples (últimos dados
/// obtidos) e configurações (tema, última atualização).
class PreferencesService {
  PreferencesService._();
  static final PreferencesService instance = PreferencesService._();

  static const _kThemeMode = 'theme_mode'; // system | light | dark
  static const _kLastUpdate = 'last_online_update';
  static const _kCacheMatches = 'cache_matches';
  static const _kCacheStandings = 'cache_standings';
  static const _kCacheSquad = 'cache_squad';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _db async =>
      _prefs ??= await SharedPreferences.getInstance();

  // --- Tema -------------------------------------------------------------
  Future<String> getThemeMode() async =>
      (await _db).getString(_kThemeMode) ?? 'system';

  Future<void> setThemeMode(String mode) async =>
      (await _db).setString(_kThemeMode, mode);

  // --- Cache (JSON serializado) ------------------------------------------
  Future<void> saveCache(String key, String json) async =>
      (await _db).setString(key, json);

  Future<String?> readCache(String key) async =>
      (await _db).getString(key);

  // Atalhos específicos de cache
  Future<void> cacheMatches(List<Map<String, dynamic>> list) async =>
      saveCache(_kCacheMatches, jsonEncode(list));

  Future<String?> getCacheMatches() async => readCache(_kCacheMatches);

  Future<void> cacheStandings(List<Map<String, dynamic>> list) async =>
      saveCache(_kCacheStandings, jsonEncode(list));

  Future<String?> getCacheStandings() async => readCache(_kCacheStandings);

  Future<void> cacheSquad(List<Map<String, dynamic>> list) async =>
      saveCache(_kCacheSquad, jsonEncode(list));

  Future<String?> getCacheSquad() async => readCache(_kCacheSquad);

  // Timestamp da última atualização online
  Future<void> recordLastOnlineUpdate() async =>
      (await _db).setInt(_kLastUpdate, DateTime.now().millisecondsSinceEpoch);

  Future<DateTime?> getLastOnlineUpdate() async {
    final ms = (await _db).getInt(_kLastUpdate);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}
