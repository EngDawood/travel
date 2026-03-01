// lib/screens/saved_itineraries_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/itinerary_provider.dart';
import '../widgets/saved_itinerary_tile.dart';

class SavedItinerariesScreen extends StatefulWidget {
  const SavedItinerariesScreen({super.key});

  @override
  State<SavedItinerariesScreen> createState() =>
      _SavedItinerariesScreenState();
}

class _SavedItinerariesScreenState extends State<SavedItinerariesScreen> {
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

  Future<void> _confirmDelete(BuildContext context, int id, String name) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.savedDeleteTitle),
        content: Text(l10n.savedDeleteContent(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.savedCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.savedDelete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ItineraryProvider>().deleteItinerary(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<ItineraryProvider>();
    final itineraries = provider.savedItineraries;
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savedItinerariesTitle)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : itineraries.isEmpty
              ? _buildEmpty(context, l10n)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: itineraries.length,
                    itemBuilder: (context, index) {
                      final it = itineraries[index];
                      final name =
                          it.name.isEmpty ? it.city : it.name;
                      return Dismissible(
                        key: Key('itinerary_${it.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete,
                              color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          if (it.id == null) return false;
                          await _confirmDelete(context, it.id!, name);
                          return false; // deletion handled inside
                        },
                        child: SavedItineraryTile(
                          itinerary: it,
                          onTap: () => context.push('/saved/${it.id}'),
                          onDelete: it.id == null
                              ? null
                              : () => _confirmDelete(context, it.id!, name),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.luggage, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            l10n.savedItinerariesEmpty,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.go('/search'),
            icon: const Icon(Icons.explore),
            label: Text(l10n.savedPlanFirstTrip),
          ),
        ],
      ),
    );
  }
}
