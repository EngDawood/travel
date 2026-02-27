// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/itinerary_provider.dart';
import '../widgets/saved_itinerary_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final userId =
        context.read<AuthProvider>().currentUser?.id ?? 0;
    await context.read<ItineraryProvider>().loadSaved(userId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItineraryProvider>();
    final itineraries = provider.savedItineraries;
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Trip History')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : itineraries.isEmpty
              ? _buildEmpty(context)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: itineraries.length,
                    itemBuilder: (context, index) {
                      final it = itineraries[index];
                      return SavedItineraryTile(
                        itinerary: it,
                        onTap: () => context.push('/saved/${it.id}'),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'No trips yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.go('/search'),
            icon: const Icon(Icons.explore),
            label: const Text('Plan Your First Trip'),
          ),
        ],
      ),
    );
  }
}
