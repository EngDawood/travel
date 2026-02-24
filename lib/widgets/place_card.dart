// lib/widgets/place_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:provider/provider.dart';

import '../models/place.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleSelect;

  const PlaceCard({
    super.key,
    required this.place,
    required this.isSelected,
    required this.onTap,
    required this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiService>();
    final color = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child: place.photoReference != null
                  ? CachedNetworkImage(
                      imageUrl:
                          api.getPhotoUrl(place.photoReference!, maxWidth: 600),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _imagePlaceholder(),
                      errorWidget: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: place.rating,
                              itemBuilder: (_, __) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              priceLevelToString(place.priceLevel),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _CategoryTag(category: place.category),
                            const SizedBox(width: 8),
                            if (place.openNow != null)
                              Text(
                                place.openNow! ? 'Open now' : 'Closed',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: place.openNow!
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Select toggle
                  IconButton(
                    onPressed: onToggleSelect,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.add_circle_outline,
                        key: ValueKey(isSelected),
                        color: isSelected ? color : Colors.grey,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 140,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 48, color: Colors.grey),
    );
  }
}

class _CategoryTag extends StatelessWidget {
  final String category;
  const _CategoryTag({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        capitalize(category),
        style: TextStyle(fontSize: 11, color: Colors.blue[700]),
      ),
    );
  }
}
