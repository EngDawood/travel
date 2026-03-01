// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class LocaleProvider extends ChangeNotifier {
  static const _supported = [Locale('en'), Locale('ar')];
  static List<Locale> get supportedLocales => _supported;

  final PreferencesService _prefs;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  LocaleProvider(this._prefs);

  Future<void> loadSavedLocale() async {
    final code = await _prefs.getLocale();
    if (code != null) {
      final locale = Locale(code);
      if (_supported.contains(locale)) {
        _locale = locale;
        notifyListeners();
      }
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!_supported.contains(locale)) return;
    _locale = locale;
    notifyListeners();
    await _prefs.saveLocale(locale.languageCode);
  }
}
