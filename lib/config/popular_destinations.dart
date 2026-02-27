// lib/config/popular_destinations.dart

class PopularDestination {
  final String city;
  final String country;
  final double lat;
  final double lng;
  final String imageUrl;

  const PopularDestination({
    required this.city,
    required this.country,
    required this.lat,
    required this.lng,
    required this.imageUrl,
  });
}

const List<PopularDestination> popularDestinations = [
  PopularDestination(
    city: 'Paris',
    country: 'France',
    lat: 48.8566,
    lng: 2.3522,
    imageUrl:
        'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400&h=300&fit=crop',
  ),
  PopularDestination(
    city: 'Tokyo',
    country: 'Japan',
    lat: 35.6762,
    lng: 139.6503,
    imageUrl:
        'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400&h=300&fit=crop',
  ),
  PopularDestination(
    city: 'New York',
    country: 'USA',
    lat: 40.7128,
    lng: -74.0060,
    imageUrl:
        'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400&h=300&fit=crop',
  ),
  PopularDestination(
    city: 'Rome',
    country: 'Italy',
    lat: 41.9028,
    lng: 12.4964,
    imageUrl:
        'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=400&h=300&fit=crop',
  ),
  PopularDestination(
    city: 'London',
    country: 'UK',
    lat: 51.5074,
    lng: -0.1278,
    imageUrl:
        'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400&h=300&fit=crop',
  ),
  PopularDestination(
    city: 'Dubai',
    country: 'UAE',
    lat: 25.2048,
    lng: 55.2708,
    imageUrl:
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=400&h=300&fit=crop',
  ),
];
