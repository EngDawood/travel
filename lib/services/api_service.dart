// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/place.dart';
import '../utils/app_logger.dart';

class ApiService {
  final String apiKey;
  final String baseUrl = placesBaseUrl;

  ApiService({String? apiKey}) : apiKey = apiKey ?? googleApiKey;

  // ─── NEARBY SEARCH ────────────────────────────────────────────────────────

  /// Search for places near [lat]/[lng] of a given Google [type].
  /// Returns a list of [Place] objects.
  Future<List<Place>> searchNearby({
    required double lat,
    required double lng,
    required String type,
    required String category,
    int radius = nearbySearchRadius,
  }) async {
    final uri = Uri.parse('$baseUrl/nearbysearch/json').replace(
      queryParameters: {
        'location': '$lat,$lng',
        'radius': radius.toString(),
        'type': type,
        'key': apiKey,
      },
    );

    final response = await _get(uri);
    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _checkApiStatus(body);

    final results = body['results'] as List<dynamic>? ?? [];
    return results
        .map((r) => _parsePlaceFromNearby(r as Map<String, dynamic>, category))
        .toList();
  }

  /// Fetch places for multiple categories and merge results (deduped by placeId).
  Future<List<Place>> searchNearbyMultiple({
    required double lat,
    required double lng,
    required List<PlaceCategory> categories,
    int radius = nearbySearchRadius,
  }) async {
    final Map<String, Place> seen = {};

    for (final category in categories) {
      for (final type in category.googleTypes) {
        final places = await searchNearby(
          lat: lat,
          lng: lng,
          type: type,
          category: category.label,
          radius: radius,
        );
        for (final place in places) {
          seen.putIfAbsent(place.placeId, () => place);
        }
      }
    }

    return seen.values.toList();
  }

  // ─── PLACE DETAILS ────────────────────────────────────────────────────────

  /// Fetch full details for a single place by [placeId].
  Future<Place> getPlaceDetails(String placeId, String category) async {
    final uri = Uri.parse('$baseUrl/details/json').replace(
      queryParameters: {
        'place_id': placeId,
        'fields':
            'place_id,name,rating,price_level,formatted_address,geometry,editorial_summary,photos,opening_hours,types',
        'key': apiKey,
      },
    );

    final response = await _get(uri);
    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _checkApiStatus(body);

    final result = body['result'] as Map<String, dynamic>;
    return _parsePlaceFromDetails(result, category);
  }

  // ─── PHOTO URL ────────────────────────────────────────────────────────────

  /// Construct a Places Photo URL from a [photoReference].
  /// Does NOT make an HTTP call — returns the URL string directly.
  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return '$baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$apiKey';
  }

  // ─── AUTOCOMPLETE ─────────────────────────────────────────────────────────

  /// Autocomplete city/place name for [input].
  /// Returns list of maps with 'description' and 'place_id'.
  Future<List<Map<String, dynamic>>> autocompleteCity(String input) async {
    if (input.trim().isEmpty) return [];

    final uri = Uri.parse('$baseUrl/autocomplete/json').replace(
      queryParameters: {
        'input': input,
        'types': '(cities)',
        'key': apiKey,
      },
    );

    final response = await _get(uri);
    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _checkApiStatus(body);

    final predictions = body['predictions'] as List<dynamic>? ?? [];
    return predictions.map((p) {
      final map = p as Map<String, dynamic>;
      return {
        'description': map['description'] as String? ?? '',
        'place_id': map['place_id'] as String? ?? '',
      };
    }).toList();
  }

  // ─── GEOCODE CITY ─────────────────────────────────────────────────────────

  /// Get lat/lng for a city from its [placeId].
  Future<Map<String, double>> getCityLatLng(String placeId) async {
    final uri = Uri.parse('$baseUrl/details/json').replace(
      queryParameters: {
        'place_id': placeId,
        'fields': 'geometry',
        'key': apiKey,
      },
    );

    final response = await _get(uri);
    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    _checkApiStatus(body);

    final location =
        (body['result'] as Map)['geometry']['location'] as Map<String, dynamic>;
    return {
      'lat': (location['lat'] as num).toDouble(),
      'lng': (location['lng'] as num).toDouble(),
    };
  }

  // ─── PARSERS ──────────────────────────────────────────────────────────────

  Place _parsePlaceFromNearby(Map<String, dynamic> r, String category) {
    final geometry = r['geometry']['location'] as Map<String, dynamic>;
    final photos = r['photos'] as List<dynamic>?;
    final openingHours = r['opening_hours'] as Map<String, dynamic>?;

    return Place(
      placeId: r['place_id'] as String,
      name: r['name'] as String,
      category: category,
      rating: (r['rating'] as num?)?.toDouble() ?? 0.0,
      priceLevel: (r['price_level'] as int?) ?? 0,
      address: r['vicinity'] as String? ?? '',
      latitude: (geometry['lat'] as num).toDouble(),
      longitude: (geometry['lng'] as num).toDouble(),
      photoReference: photos != null && photos.isNotEmpty
          ? photos.first['photo_reference'] as String?
          : null,
      openNow: openingHours?['open_now'] as bool?,
    );
  }

  Place _parsePlaceFromDetails(Map<String, dynamic> r, String category) {
    final geometry = r['geometry']['location'] as Map<String, dynamic>;
    final photos = r['photos'] as List<dynamic>?;
    final openingHours = r['opening_hours'] as Map<String, dynamic>?;
    final editorial = r['editorial_summary'] as Map<String, dynamic>?;

    return Place(
      placeId: r['place_id'] as String,
      name: r['name'] as String,
      category: category,
      rating: (r['rating'] as num?)?.toDouble() ?? 0.0,
      priceLevel: (r['price_level'] as int?) ?? 0,
      address: r['formatted_address'] as String? ?? '',
      latitude: (geometry['lat'] as num).toDouble(),
      longitude: (geometry['lng'] as num).toDouble(),
      description: editorial?['overview'] as String?,
      photoReference: photos != null && photos.isNotEmpty
          ? photos.first['photo_reference'] as String?
          : null,
      openNow: openingHours?['open_now'] as bool?,
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  /// Performs a GET request with a 10-second timeout and logs the call.
  Future<http.Response> _get(Uri uri) async {
    AppLogger.info('[API] GET ${uri.path}${uri.query.isNotEmpty ? "?${uri.query.replaceAll(RegExp(r'key=[^&]+'), 'key=***')}" : ""}');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      AppLogger.info('[API] ${response.statusCode} ${uri.path}');
      return response;
    } on TimeoutException {
      AppLogger.error('[API] Request timed out: ${uri.path}');
      rethrow;
    } catch (e, stack) {
      AppLogger.error('[API] Request failed: ${uri.path}', error: e, stack: stack);
      rethrow;
    }
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  void _checkApiStatus(Map<String, dynamic> body) {
    final status = body['status'] as String?;
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      final message = body['error_message'] as String? ?? status ?? 'Unknown error';
      throw ApiException('Google Places API error: $message (status: $status)');
    }
  }
}

/// Custom exception for API errors.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
