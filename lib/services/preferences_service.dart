// lib/services/preferences_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

/// Stores lightweight user session data (logged-in user id).
class PreferencesService {
  static const _keyUserId = 'user_id';
  static const _keyRecentSearches = 'recent_searches';
  static const _maxRecentSearches = 10;

  /// Save the logged-in user id.
  Future<void> saveUserId(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyUserId, id);
      AppLogger.info('[Prefs] Saved userId=$id');
    } catch (e, stack) {
      AppLogger.error('[Prefs] Failed to save userId', error: e, stack: stack);
      rethrow;
    }
  }

  /// Get the logged-in user id, or null if not logged in.
  Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyUserId);
    } catch (e, stack) {
      AppLogger.error('[Prefs] Failed to read userId', error: e, stack: stack);
      return null;
    }
  }

  /// Get recent city searches.
  Future<List<Map<String, String>>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyRecentSearches);
      if (raw == null) return [];
      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => Map<String, String>.from(e as Map))
          .toList();
    } catch (e, stack) {
      AppLogger.error('[Prefs] Failed to read recent searches',
          error: e, stack: stack);
      return [];
    }
  }

  /// Add a city to recent searches (prepend, deduplicate, cap at max).
  Future<void> addRecentSearch(String description, String placeId) async {
    try {
      final current = await getRecentSearches();
      current.removeWhere((e) => e['place_id'] == placeId);
      current.insert(0, {'description': description, 'place_id': placeId});
      final capped = current.take(_maxRecentSearches).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyRecentSearches, jsonEncode(capped));
      AppLogger.info('[Prefs] Saved recent search: $description');
    } catch (e, stack) {
      AppLogger.error('[Prefs] Failed to save recent search',
          error: e, stack: stack);
    }
  }

  // ── Favorites ──────────────────────────────────────────────────────────────
  static const _keyFavorites = 'favorite_ids';

  Future<List<String>> getFavoriteIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_keyFavorites) ?? [];
    } catch (e, stack) {
      AppLogger.error('[Prefs] Failed to read favorites', error: e, stack: stack);
      return [];
    }
  }

  Future<bool> isFavorite(String placeId) async {
    final ids = await getFavoriteIds();
    return ids.contains(placeId);
  }

  /// Toggles favourite state. Returns new state (true = now favourited).
  Future<bool> toggleFavorite(String placeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_keyFavorites) ?? [];
      final nowFavorited = !ids.contains(placeId);
      if (nowFavorited) {
        ids.add(placeId);
      } else {
        ids.remove(placeId);
      }
      await prefs.setStringList(_keyFavorites, ids);
      AppLogger.info('[Prefs] Toggled favorite placeId=$placeId → $nowFavorited');
      return nowFavorited;
    } catch (e, stack) {
      AppLogger.error('[Prefs] Failed to toggle favorite', error: e, stack: stack);
      return false;
    }
  }

  /// Clear session (logout).
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserId);
      AppLogger.info('[Prefs] Session cleared');
    } catch (e, stack) {
      AppLogger.error('[Prefs] Failed to clear session', error: e, stack: stack);
    }
  }
}
