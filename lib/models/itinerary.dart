// lib/models/itinerary.dart
import 'package:json_annotation/json_annotation.dart';
import 'itinerary_place.dart';

part 'itinerary.g.dart';

@JsonSerializable(explicitToJson: true)
class Itinerary {
  final int? id;
  final int userId;
  final String city;
  final String name;
  final DateTime date;
  final DateTime createdAt;
  final List<ItineraryPlace> places; // populated via join

  const Itinerary({
    this.id,
    required this.userId,
    required this.city,
    required this.name,
    required this.date,
    required this.createdAt,
    this.places = const [],
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) =>
      _$ItineraryFromJson(json);
  Map<String, dynamic> toJson() => _$ItineraryToJson(this);

  factory Itinerary.fromDb(Map<String, dynamic> map,
      {List<ItineraryPlace> places = const []}) {
    return Itinerary(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      city: map['city'] as String,
      name: map['name'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      places: places,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'city': city,
      'name': name,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Itinerary copyWith({
    int? id,
    int? userId,
    String? city,
    String? name,
    DateTime? date,
    DateTime? createdAt,
    List<ItineraryPlace>? places,
  }) {
    return Itinerary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      city: city ?? this.city,
      name: name ?? this.name,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      places: places ?? this.places,
    );
  }
}
