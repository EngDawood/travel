// lib/services/mock_api_service.dart
import '../models/place.dart';
import 'api_service.dart';

/// A drop-in replacement for ApiService that returns hardcoded data.
/// Use this when no Google API key is available.
class MockApiService extends ApiService {
  MockApiService() : super(apiKey: 'MOCK_KEY');

  static final List<Place> _mockPlaces = [
    const Place(
      placeId: 'ChIJmock001',
      name: 'Grand Mosque',
      category: 'attraction',
      rating: 4.8,
      priceLevel: 0,
      address: 'Al Fateh Highway, Manama',
      latitude: 26.2285,
      longitude: 50.5860,
      description: 'One of the largest mosques in the world, a stunning landmark.',
      openNow: true,
    ),
    const Place(
      placeId: 'ChIJmock002',
      name: 'Bahrain National Museum',
      category: 'attraction',
      rating: 4.5,
      priceLevel: 1,
      address: 'Al Fateh Highway, Manama',
      latitude: 26.2265,
      longitude: 50.5900,
      description: 'Explore thousands of years of Bahraini history and culture.',
      openNow: true,
    ),
    const Place(
      placeId: 'ChIJmock003',
      name: 'The Caffe',
      category: 'cafe',
      rating: 4.3,
      priceLevel: 2,
      address: 'Block 338, Adliya, Manama',
      latitude: 26.2150,
      longitude: 50.5800,
      openNow: true,
    ),
    const Place(
      placeId: 'ChIJmock004',
      name: 'Bushido Restaurant',
      category: 'restaurant',
      rating: 4.6,
      priceLevel: 3,
      address: 'Four Seasons Hotel, Manama',
      latitude: 26.2100,
      longitude: 50.5750,
      description: 'Award-winning Japanese restaurant with stunning sea views.',
      openNow: false,
    ),
    const Place(
      placeId: 'ChIJmock005',
      name: 'City Centre Bahrain',
      category: 'shopping',
      rating: 4.2,
      priceLevel: 2,
      address: 'King Fahad Causeway Road, Manama',
      latitude: 26.2400,
      longitude: 50.5500,
      openNow: true,
    ),
    const Place(
      placeId: 'ChIJmock006',
      name: 'Copper Chimney',
      category: 'restaurant',
      rating: 4.1,
      priceLevel: 2,
      address: 'Adliya, Manama',
      latitude: 26.2120,
      longitude: 50.5820,
      openNow: true,
    ),
    const Place(
      placeId: 'ChIJmock007',
      name: 'Qal\'at al-Bahrain',
      category: 'attraction',
      rating: 4.4,
      priceLevel: 0,
      address: 'Bahrain Fort, Northern Governorate',
      latitude: 26.2350,
      longitude: 50.5100,
      description: 'UNESCO World Heritage Site — ancient port and capital of Dilmun.',
      openNow: true,
    ),
    const Place(
      placeId: 'ChIJmock008',
      name: 'Zinc Bar & Lounge',
      category: 'nightlife',
      rating: 4.0,
      priceLevel: 3,
      address: 'Crowne Plaza, Manama',
      latitude: 26.2200,
      longitude: 50.5900,
      openNow: false,
    ),
    const Place(
      placeId: 'ChIJmock009',
      name: 'Costa Coffee',
      category: 'cafe',
      rating: 4.0,
      priceLevel: 2,
      address: 'Seef Mall, Manama',
      latitude: 26.2450,
      longitude: 50.5600,
      openNow: true,
    ),
    const Place(
      placeId: 'ChIJmock010',
      name: 'Moda Mall',
      category: 'shopping',
      rating: 4.3,
      priceLevel: 3,
      address: 'Bahrain World Trade Center, Manama',
      latitude: 26.2180,
      longitude: 50.5870,
      openNow: true,
    ),
  ];

  @override
  Future<List<Place>> searchNearby({
    required double lat,
    required double lng,
    required String type,
    required String category,
    int radius = 5000,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600)); // simulate network
    return _mockPlaces.where((p) => p.category == category).toList();
  }

  @override
  Future<List<Place>> searchNearbyMultiple({
    required double lat,
    required double lng,
    required List categories,
    int radius = 5000,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final labels = categories.map((c) => c.label as String).toSet();
    return _mockPlaces.where((p) => labels.contains(p.category)).toList();
  }

  @override
  Future<Place> getPlaceDetails(String placeId, String category) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockPlaces.firstWhere(
      (p) => p.placeId == placeId,
      orElse: () => _mockPlaces.first,
    );
  }

  @override
  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    // Return a placeholder image from picsum
    return 'https://picsum.photos/seed/$photoReference/$maxWidth/300';
  }

  @override
  Future<List<Map<String, dynamic>>> autocompleteCity(String input) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final cities = [
      {'description': 'Manama, Bahrain', 'place_id': 'mock_city_manama'},
      {'description': 'Dubai, UAE', 'place_id': 'mock_city_dubai'},
      {'description': 'Riyadh, Saudi Arabia', 'place_id': 'mock_city_riyadh'},
      {'description': 'Muscat, Oman', 'place_id': 'mock_city_muscat'},
      {'description': 'Kuwait City, Kuwait', 'place_id': 'mock_city_kuwait'},
    ];
    return cities
        .where((c) => (c['description'] as String)
            .toLowerCase()
            .contains(input.toLowerCase()))
        .toList();
  }

  @override
  Future<Map<String, double>> getCityLatLng(String placeId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    const coords = {
      'mock_city_manama': {'lat': 26.2285, 'lng': 50.5860},
      'mock_city_dubai': {'lat': 25.2048, 'lng': 55.2708},
      'mock_city_riyadh': {'lat': 24.7136, 'lng': 46.6753},
      'mock_city_muscat': {'lat': 23.5880, 'lng': 58.3829},
      'mock_city_kuwait': {'lat': 29.3759, 'lng': 47.9774},
    };
    return coords[placeId] ?? {'lat': 26.2285, 'lng': 50.5860};
  }
}
