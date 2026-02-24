// lib/services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Stores lightweight user session data (logged-in user id).
class PreferencesService {
  static const _keyUserId = 'user_id';

  /// Save the logged-in user id.
  Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, id);
  }

  /// Get the logged-in user id, or null if not logged in.
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Clear session (logout).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
  }
}
