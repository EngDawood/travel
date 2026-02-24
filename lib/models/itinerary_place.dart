// lib/models/itinerary_place.dart
import 'package:json_annotation/json_annotation.dart';

part 'itinerary_place.g.dart';

@JsonSerializable()
class ItineraryPlace {
  final int? id;
  final int itineraryId;
  final String placeId;
  final String timeSlot;   // "morning" | "afternoon" | "evening"
  final int orderIndex;

  const ItineraryPlace({
    this.id,
    required this.itineraryId,
    required this.placeId,
    required this.timeSlot,
    required this.orderIndex,
  });

  factory ItineraryPlace.fromJson(Map<String, dynamic> json) =>
      _$ItineraryPlaceFromJson(json);
  Map<String, dynamic> toJson() => _$ItineraryPlaceToJson(this);

  factory ItineraryPlace.fromDb(Map<String, dynamic> map) {
    return ItineraryPlace(
      id: map['id'] as int?,
      itineraryId: map['itinerary_id'] as int,
      placeId: map['place_id'] as String,
      timeSlot: map['time_slot'] as String,
      orderIndex: map['order_index'] as int,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      if (id != null) 'id': id,
      'itinerary_id': itineraryId,
      'place_id': placeId,
      'time_slot': timeSlot,
      'order_index': orderIndex,
    };
  }

  ItineraryPlace copyWith({
    int? id,
    int? itineraryId,
    String? placeId,
    String? timeSlot,
    int? orderIndex,
  }) {
    return ItineraryPlace(
      id: id ?? this.id,
      itineraryId: itineraryId ?? this.itineraryId,
      placeId: placeId ?? this.placeId,
      timeSlot: timeSlot ?? this.timeSlot,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
