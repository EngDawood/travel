// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Itinerary _$ItineraryFromJson(Map<String, dynamic> json) => Itinerary(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num).toInt(),
  city: json['city'] as String,
  name: json['name'] as String,
  date: DateTime.parse(json['date'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  places:
      (json['places'] as List<dynamic>?)
          ?.map((e) => ItineraryPlace.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ItineraryToJson(Itinerary instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'city': instance.city,
  'name': instance.name,
  'date': instance.date.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'places': instance.places.map((e) => e.toJson()).toList(),
};
