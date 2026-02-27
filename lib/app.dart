// lib/app.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/shell_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/city_search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/history_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/places_list_screen.dart';
import 'screens/place_detail_screen.dart';
import 'screens/itinerary_screen.dart';
import 'screens/saved_itineraries_screen.dart';
import 'screens/saved_itinerary_detail_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/account_settings_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/search',
  redirect: (context, state) {
    if (state.uri.path == '/') return '/search';
    return null;
  },
  routes: [
    // Bottom nav shell with 3 tabs
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScreen(navigationShell: navigationShell),
      branches: [
        // Tab 0: Home (City Search)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              name: 'citySearch',
              builder: (context, state) => const CitySearchScreen(),
            ),
          ],
        ),
        // Tab 1: Saved Itineraries
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/saved',
              name: 'saved',
              builder: (context, state) => const SavedItinerariesScreen(),
            ),
          ],
        ),
        // Tab 2: Favourites
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              name: 'favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        // Tab 3: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'settings',
                  name: 'accountSettings',
                  builder: (context, state) =>
                      const AccountSettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // Non-tab routes (push on top, hide bottom nav)
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const AuthScreen(),
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
      path: '/map',
      name: 'map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/saved/:id',
      name: 'savedDetail',
      builder: (context, state) => SavedItineraryDetailScreen(
        id: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/history',
      name: 'history',
      builder: (context, state) => const HistoryScreen(),
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
