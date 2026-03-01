// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navSaved => 'Saved';

  @override
  String get navFavourites => 'Favourites';

  @override
  String get navProfile => 'Settings';

  @override
  String get citySearchTitle => 'Where are you going?';

  @override
  String get citySearchSubtitle => 'Search for a city to start planning.';

  @override
  String get citySearchHint => 'e.g. Paris, Tokyo, New York';

  @override
  String get citySearchRecentSearches => 'RECENT SEARCHES';

  @override
  String get citySearchPopularDestinations => 'POPULAR DESTINATIONS';

  @override
  String get citySearchFailed => 'Search failed. Check your connection.';

  @override
  String get citySearchCityFailed => 'Could not load city. Try again.';

  @override
  String get authWelcome => 'Welcome';

  @override
  String get authLoginTab => 'Login';

  @override
  String get authRegisterTab => 'Register';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authUsername => 'Username';

  @override
  String get authLoginButton => 'Login';

  @override
  String get authCreateAccount => 'Create Account';

  @override
  String get authContinueAsGuest => 'Continue as Guest';

  @override
  String get preferencesTitle => 'What do you like?';

  @override
  String preferencesSubtitle(String city) {
    return 'Select the types of places you want to visit in $city.';
  }

  @override
  String get preferencesFindPlaces => 'Find Places';

  @override
  String get preferencesSelectAtLeastOne =>
      'Please select at least one category.';

  @override
  String get categoryRestaurants => 'Restaurants';

  @override
  String get categoryCafes => 'Cafes';

  @override
  String get categoryAttractions => 'Attractions';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryNightlife => 'Nightlife';

  @override
  String get catRestaurant => 'Restaurant';

  @override
  String get catCafe => 'Cafe';

  @override
  String get catAttraction => 'Attraction';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catNightlife => 'Nightlife';

  @override
  String get placesListTitle => 'Select Places';

  @override
  String get placesListSubtitle => 'Choose at least 3 places to visit.';

  @override
  String get placesListLoading => 'Finding great places...';

  @override
  String get placesListEmpty =>
      'No places found. Try different categories or a broader area.';

  @override
  String get placesListGenerate => 'Generate';

  @override
  String get placesListViewMap => 'View on Map';

  @override
  String get placesListGoBack => 'Go Back';

  @override
  String placesListSelectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Select $count more places',
      one: 'Select 1 more place',
    );
    return '$_temp0';
  }

  @override
  String placesListSelectedCount(int count) {
    return '$count places selected';
  }

  @override
  String get placeDetailGoBack => 'Go Back';

  @override
  String get placeDetailOpen => 'Open';

  @override
  String get placeDetailClosed => 'Closed';

  @override
  String get placeDetailAbout => 'About';

  @override
  String get placeDetailViewMap => 'View on Map';

  @override
  String get placeDetailAddItinerary => 'Add to Itinerary';

  @override
  String get placeDetailAdded => 'Added';

  @override
  String get placeDetailRemovedSnack => 'Removed from itinerary';

  @override
  String get placeDetailAddedSnack => 'Added to itinerary';

  @override
  String get placeDetailFree => 'Free';

  @override
  String get itineraryYourItinerary => 'Your Itinerary';

  @override
  String get itineraryEdit => 'Edit';

  @override
  String get itineraryDone => 'Done';

  @override
  String get itineraryNoItinerary => 'No itinerary generated yet.';

  @override
  String get itinerarySaveButton => 'Save Itinerary';

  @override
  String get itinerarySaveDialogTitle => 'Save Itinerary';

  @override
  String get itinerarySaveHint => 'Give your plan a name';

  @override
  String get itineraryCancel => 'Cancel';

  @override
  String get itinerarySave => 'Save';

  @override
  String get itinerarySavedSuccess => 'Itinerary saved!';

  @override
  String get itinerarySaveFailed => 'Failed to save. Try again.';

  @override
  String itineraryDefaultName(String city) {
    return 'Trip to $city';
  }

  @override
  String nPlaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0';
  }

  @override
  String get savedItinerariesTitle => 'Saved Itineraries';

  @override
  String get savedItinerariesEmpty => 'No saved itineraries yet.';

  @override
  String get savedPlanFirstTrip => 'Plan Your First Trip';

  @override
  String get savedDeleteTitle => 'Delete Itinerary';

  @override
  String savedDeleteContent(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get savedCancel => 'Cancel';

  @override
  String get savedDelete => 'Delete';

  @override
  String get savedDetailItinerary => 'Itinerary';

  @override
  String get savedDetailNotFound => 'Itinerary not found.';

  @override
  String get savedDetailLoadFailed => 'Failed to load itinerary.';

  @override
  String get savedDetailGoBack => 'Go Back';

  @override
  String get favTitle => 'Favourites';

  @override
  String get favEmpty => 'No favourites yet. Tap ♥ on a place to save it.';

  @override
  String get profileTitle => 'Settings';

  @override
  String get profileAccountSettings => 'Account Settings';

  @override
  String get profileFavorites => 'Favorites';

  @override
  String get profileHistory => 'History';

  @override
  String get accountSettingsTitle => 'Account Settings';

  @override
  String get accountSettingsSubtitle =>
      'Manage your account details and preferences.';

  @override
  String get accountProfileInfo => 'PROFILE INFORMATION';

  @override
  String get accountName => 'Name';

  @override
  String get accountEmail => 'Email';

  @override
  String get accountSecurityPrefs => 'SECURITY & PREFERENCES';

  @override
  String get accountChangePassword => 'Change Password';

  @override
  String get accountNotifications => 'Notifications';

  @override
  String get accountLanguage => 'Language';

  @override
  String get accountLogOut => 'Log Out';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic (العربية)';

  @override
  String get historyTitle => 'Trip History';

  @override
  String get historyEmpty => 'No trips yet.';

  @override
  String get historyPlanFirstTrip => 'Plan Your First Trip';

  @override
  String get mapTitle => 'Map';

  @override
  String get mapNoPlaces => 'No places selected yet.';

  @override
  String get mapGoToPlaces => 'Go to Places';

  @override
  String get mapWebFallback =>
      'Interactive map is available on Android & iOS. Showing place list with coordinates.';

  @override
  String get mapDetails => 'Details';

  @override
  String get slotMorning => 'Morning';

  @override
  String get slotAfternoon => 'Afternoon';

  @override
  String get slotEvening => 'Evening';

  @override
  String get slotMorningTime => '8:00 AM – 12:00 PM';

  @override
  String get slotAfternoonTime => '12:00 PM – 5:00 PM';

  @override
  String get slotEveningTime => '5:00 PM – 10:00 PM';

  @override
  String get slotNoPlaces => 'No places assigned to this slot.';
}
