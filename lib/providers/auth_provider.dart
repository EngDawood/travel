// lib/providers/auth_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/database_helper.dart';
import '../services/preferences_service.dart';
import '../utils/app_logger.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _error;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  final DatabaseHelper _db = DatabaseHelper.instance;
  final PreferencesService _prefs = PreferencesService();

  /// Try to restore session on app start.
  Future<void> restoreSession() async {
    try {
      final userId = await _prefs.getUserId();
      if (userId != null) {
        AppLogger.info('[Auth] Restoring session for userId=$userId');
        _currentUser = await _db.getUserById(userId);
        AppLogger.info('[Auth] Session restored: ${_currentUser?.email ?? "user not found"}');
      }
      notifyListeners();
    } catch (e, stack) {
      AppLogger.error('[Auth] Failed to restore session', error: e, stack: stack);
      // Non-fatal: user will just see login screen.
    }
  }

  /// Register a new user.
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final existing = await _db.getUserByEmail(email);
      if (existing != null) {
        _error = 'An account with this email already exists.';
        return false;
      }
      final user = User(
        username: username.trim(),
        email: email.trim().toLowerCase(),
        password: _hashPassword(password),
      );
      final id = await _db.insertUser(user);
      _currentUser = user.copyWith(id: id);
      await _prefs.saveUserId(id);
      return true;
    } catch (e, stack) {
      AppLogger.error('[Auth] Registration failed', error: e, stack: stack);
      _error = _dbErrorMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login with email and password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _db.getUserByEmail(email.trim().toLowerCase());
      if (user == null) {
        _error = 'No account found with this email.';
        return false;
      }
      if (user.password != _hashPassword(password)) {
        _error = 'Incorrect password.';
        return false;
      }
      _currentUser = user;
      await _prefs.saveUserId(user.id!);
      return true;
    } catch (e, stack) {
      AppLogger.error('[Auth] Login failed', error: e, stack: stack);
      _error = _dbErrorMessage(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout the current user.
  Future<void> logout() async {
    _currentUser = null;
    await _prefs.clear();
    notifyListeners();
  }

  /// Update the current user's preferred categories.
  Future<void> updatePreferences(List<String> categories) async {
    if (_currentUser == null) return;
    try {
      await _db.updateUserCategories(_currentUser!.id!, categories);
      _currentUser = _currentUser!.copyWith(preferredCategories: categories);
      notifyListeners();
    } catch (e, stack) {
      AppLogger.error('[Auth] Failed to update preferences', error: e, stack: stack);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  String _dbErrorMessage(Object e) {
    if (e is TimeoutException) return 'Request timed out. Please try again.';
    return 'Local storage error. Try restarting the app.';
  }
}
