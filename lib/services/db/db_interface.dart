// lib/services/db/db_interface.dart
import '../../models/user.dart';
import '../../models/place.dart';
import '../../models/itinerary.dart';
import '../../models/itinerary_place.dart';

abstract class DbInterface {
  Future<int> insertUser(User user);
  Future<User?> getUserByEmail(String email);
  Future<User?> getUserById(int id);
  Future<int> updateUserCategories(int userId, List<String> categories);
  Future<int> updateUser(User user);
  Future<int> deleteUser(int id);

  Future<void> upsertPlace(Place place);
  Future<void> upsertPlaces(List<Place> places);
  Future<Place?> getPlace(String placeId);
  Future<List<Place>> getPlacesByCategory(String category);
  Future<int> deletePlace(String placeId);

  Future<int> insertItinerary(Itinerary itinerary);
  Future<List<Itinerary>> getItinerariesForUser(int userId);
  Future<Itinerary?> getItinerary(int id);
  Future<int> updateItineraryName(int id, String name);
  Future<int> deleteItinerary(int id);
  Future<void> replaceItineraryPlaces(
      int itineraryId, List<ItineraryPlace> places);
}
