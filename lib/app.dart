// lib/app.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/city_search_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/places_list_screen.dart';
import 'screens/place_detail_screen.dart';
import 'screens/itinerary_screen.dart';
import 'screens/saved_itineraries_screen.dart';
import 'screens/map_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/search',
      name: 'citySearch',
      builder: (context, state) => const CitySearchScreen(),
    ),
    GoRoute(
      path: '/preferences',
      name: 'preferences',
      builder: (context, state) => const PreferencesScreen(),
    ),
    GoRoute(
      path: '/places',
      name: 'places',
      builder: (context, state) => const PlacesListScreen(),
    ),
    GoRoute(
      path: '/place/:id',
      name: 'placeDetail',
      builder: (context, state) => PlaceDetailScreen(
        placeId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/itinerary',
      name: 'itinerary',
      builder: (context, state) => const ItineraryScreen(),
    ),
    GoRoute(
      path: '/saved',
      name: 'saved',
      builder: (context, state) => const SavedItinerariesScreen(),
    ),
    GoRoute(
      path: '/map',
      name: 'map',
      builder: (context, state) => const MapScreen(),
    ),
  ],
);

class TravelApp extends StatefulWidget {
  const TravelApp({super.key});

  @override
  State<TravelApp> createState() => _TravelAppState();
}

class _TravelAppState extends State<TravelApp> {
  @override
  void initState() {
    super.initState();
    // Restore login session on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mini Travel Assistant',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
