// lib/models/place.dart
import 'package:json_annotation/json_annotation.dart';

part 'place.g.dart';

@JsonSerializable()
class Place {
  final String placeId;       // Google Place ID (string, e.g. ChIJ...)
  final String name;
  final String category;      // restaurant | cafe | attraction | shopping | nightlife
  final double rating;
  final int priceLevel;       // 0–4 from Google
  final String address;
  final double latitude;
  final double longitude;
  final String? description;
  final String? photoReference; // Google photo reference, NOT a URL
  final bool? openNow;

  const Place({
    required this.placeId,
    required this.name,
    required this.category,
    this.rating = 0.0,
    this.priceLevel = 0,
    this.address = '',
    required this.latitude,
    required this.longitude,
    this.description,
    this.photoReference,
    this.openNow,
  });

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
  Map<String, dynamic> toJson() => _$PlaceToJson(this);

  /// SQLite stores openNow as INTEGER (0 or 1)
  factory Place.fromDb(Map<String, dynamic> map) {
    return Place(
      placeId: map['place_id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      priceLevel: (map['price_level'] as int?) ?? 0,
      address: map['address'] as String? ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      description: map['description'] as String?,
      photoReference: map['photo_reference'] as String?,
      openNow: map['open_now'] != null ? (map['open_now'] as int) == 1 : null,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'place_id': placeId,
      'name': name,
      'category': category,
      'rating': rating,
      'price_level': priceLevel,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'photo_reference': photoReference,
      'open_now': openNow != null ? (openNow! ? 1 : 0) : null,
    };
  }

  /// Returns the price level as dollar signs (e.g. $$)
  String get priceLevelDisplay {
    if (priceLevel == 0) return 'Free';
    return '\$' * priceLevel;
  }

  Place copyWith({
    String? placeId,
    String? name,
    String? category,
    double? rating,
    int? priceLevel,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? photoReference,
    bool? openNow,
  }) {
    return Place(
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      priceLevel: priceLevel ?? this.priceLevel,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      photoReference: photoReference ?? this.photoReference,
      openNow: openNow ?? this.openNow,
    );
  }
}
