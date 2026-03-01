// lib/main.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/places_provider.dart';
import 'providers/itinerary_provider.dart';
import 'providers/map_provider.dart';
import 'services/api_service.dart';
import 'services/mock_api_service.dart';
import 'services/preferences_service.dart';
import 'utils/app_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch widget build errors and layout failures (e.g. blank white screen).
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.fatal(
      'Flutter error: ${details.exceptionAsString()}',
      stack: details.stack,
    );
    FlutterError.presentError(details);
  };

  // Catch async errors that escape all try/catch blocks.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.fatal('Unhandled async error', error: error, stack: stack);
    return true; // Prevents crash on some platforms.
  };

  final bool mockMode = useMockApi;
  final ApiService apiService =
      mockMode ? MockApiService() : ApiService(apiKey: googleApiKey);

  if (mockMode) {
    AppLogger.warn('[App] Running in MOCK mode — no real API key detected.');
  } else {
    AppLogger.info('[App] Running with real Google Places API.');
  }

  final preferencesService = PreferencesService();

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<PreferencesService>.value(value: preferencesService),
        ChangeNotifierProvider(
            create: (ctx) => LocaleProvider(ctx.read<PreferencesService>())),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
            create: (ctx) => PlacesProvider(ctx.read<ApiService>())),
        ChangeNotifierProvider(create: (_) => ItineraryProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: const TravelApp(),
    ),
  );
}
