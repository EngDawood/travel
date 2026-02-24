// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/itinerary_provider.dart';
import '../widgets/saved_itinerary_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecent());
  }

  Future<void> _loadRecent() async {
    final userId = context.read<AuthProvider>().currentUser?.id ?? 0;
    await context.read<ItineraryProvider>().loadSaved(userId);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final itineraryProvider = context.watch<ItineraryProvider>();
    final recent = itineraryProvider.savedItineraries.take(3).toList();
    final username = auth.currentUser?.username ?? 'Traveler';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Travel Assistant'),
        actions: [
          if (auth.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () async {
                await auth.logout();
                if (context.mounted) context.go('/');
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecent,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Welcome banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $username! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Where do you want to explore today?',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/search'),
                      icon: const Icon(Icons.explore),
                      label: const Text('Plan a Trip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor:
                            Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Quick actions row
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.map,
                    label: 'My Trips',
                    onTap: () => context.go('/saved'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.place,
                    label: 'Explore Map',
                    onTap: () => context.go('/map'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: auth.isLoggedIn ? Icons.person : Icons.login,
                    label: auth.isLoggedIn ? 'Profile' : 'Login',
                    onTap: () => auth.isLoggedIn
                        ? _showProfileDialog(context)
                        : context.go('/login'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Recent itineraries
            if (recent.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Trips',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () => context.go('/saved'),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...recent.map((it) => SavedItineraryTile(
                    itinerary: it,
                    onTap: () {
                      context
                          .read<ItineraryProvider>()
                          .viewItinerary(it);
                      context.go('/itinerary');
                    },
                    onDelete: () async {
                      await context
                          .read<ItineraryProvider>()
                          .deleteItinerary(it.id!);
                    },
                  )),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Icon(Icons.luggage, size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      'No trips yet. Start planning!',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: ${user.username}'),
            Text('Email: ${user.email}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
