// lib/screens/saved_itinerary_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/itinerary.dart';
import '../models/place.dart';
import '../services/database_helper.dart';
import '../utils/helpers.dart';
import '../widgets/time_slot_section.dart';

class SavedItineraryDetailScreen extends StatefulWidget {
  final int id;
  const SavedItineraryDetailScreen({super.key, required this.id});

  @override
  State<SavedItineraryDetailScreen> createState() =>
      _SavedItineraryDetailScreenState();
}

class _SavedItineraryDetailScreenState
    extends State<SavedItineraryDetailScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Itinerary? _itinerary;
  bool _isLoading = true;
  String? _error;

  Map<String, List<Place>> _slotMap = {
    'morning': [],
    'afternoon': [],
    'evening': [],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final itinerary = await _db.getItinerary(widget.id);
      if (itinerary == null) {
        if (mounted) {
          setState(() {
            _error = l10n.savedDetailNotFound;
            _isLoading = false;
          });
        }
        return;
      }

      // Build slot map from cached places
      final map = <String, List<Place>>{
        'morning': [],
        'afternoon': [],
        'evening': [],
      };
      final sorted = [...itinerary.places]
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      for (final ip in sorted) {
        final place = await _db.getPlace(ip.placeId);
        if (place != null && map.containsKey(ip.timeSlot)) {
          map[ip.timeSlot]!.add(place);
        }
      }

      if (mounted) {
        setState(() {
          _itinerary = itinerary;
          _slotMap = map;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = AppLocalizations.of(context).savedDetailLoadFailed;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: _itinerary != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _itinerary!.name.isEmpty
                        ? _itinerary!.city
                        : _itinerary!.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    _itinerary!.city,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ],
              )
            : Text(l10n.savedDetailItinerary),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(l10n)
              : _buildContent(l10n),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: Text(l10n.savedDetailGoBack),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    final itinerary = _itinerary!;
    final locale = Localizations.localeOf(context).languageCode;
    final totalPlaces =
        _slotMap.values.fold(0, (sum, list) => sum + list.length);

    return Column(
      children: [
        // Summary banner
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.08),
          child: Text(
            '${formatDate(itinerary.date, locale: locale)} · ${l10n.nPlaces(totalPlaces)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              TimeSlotSection(
                slot: 'morning',
                places: _slotMap['morning']!,
                onPlaceTap: (p) => context.push('/place/${p.placeId}'),
              ),
              TimeSlotSection(
                slot: 'afternoon',
                places: _slotMap['afternoon']!,
                onPlaceTap: (p) => context.push('/place/${p.placeId}'),
              ),
              TimeSlotSection(
                slot: 'evening',
                places: _slotMap['evening']!,
                onPlaceTap: (p) => context.push('/place/${p.placeId}'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}
