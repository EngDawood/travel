// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'itinerary_place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItineraryPlace _$ItineraryPlaceFromJson(Map<String, dynamic> json) =>
    ItineraryPlace(
      id: (json['id'] as num?)?.toInt(),
      itineraryId: (json['itineraryId'] as num).toInt(),
      placeId: json['placeId'] as String,
      timeSlot: json['timeSlot'] as String,
      orderIndex: (json['orderIndex'] as num).toInt(),
    );

Map<String, dynamic> _$ItineraryPlaceToJson(ItineraryPlace instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itineraryId': instance.itineraryId,
      'placeId': instance.placeId,
      'timeSlot': instance.timeSlot,
      'orderIndex': instance.orderIndex,
    };
