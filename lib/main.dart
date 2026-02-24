// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/places_provider.dart';
import 'providers/itinerary_provider.dart';
import 'providers/map_provider.dart';
import 'services/api_service.dart';
import 'services/mock_api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final ApiService apiService =
      useMockApi ? MockApiService() : ApiService(apiKey: googleApiKey);

  if (useMockApi) {
    // ignore: avoid_print
    debugPrint('⚠️  Running in MOCK mode — no real API key detected.');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
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
