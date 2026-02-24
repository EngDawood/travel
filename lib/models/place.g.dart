// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Place _$PlaceFromJson(Map<String, dynamic> json) => Place(
  placeId: json['placeId'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  priceLevel: (json['priceLevel'] as num?)?.toInt() ?? 0,
  address: json['address'] as String? ?? '',
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  description: json['description'] as String?,
  photoReference: json['photoReference'] as String?,
  openNow: json['openNow'] as bool?,
);

Map<String, dynamic> _$PlaceToJson(Place instance) => <String, dynamic>{
  'placeId': instance.placeId,
  'name': instance.name,
  'category': instance.category,
  'rating': instance.rating,
  'priceLevel': instance.priceLevel,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'description': instance.description,
  'photoReference': instance.photoReference,
  'openNow': instance.openNow,
};
