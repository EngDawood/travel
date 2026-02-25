// lib/services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

/// Stores lightweight user session data (logged-in user id).
class PreferencesService {
  static const _keyUserId = 'user_id';

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
