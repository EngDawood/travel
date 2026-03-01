import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @navFavourites.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get navFavourites;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navProfile;

  /// No description provided for @citySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get citySearchTitle;

  /// No description provided for @citySearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search for a city to start planning.'**
  String get citySearchSubtitle;

  /// No description provided for @citySearchHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Paris, Tokyo, New York'**
  String get citySearchHint;

  /// No description provided for @citySearchRecentSearches.
  ///
  /// In en, this message translates to:
  /// **'RECENT SEARCHES'**
  String get citySearchRecentSearches;

  /// No description provided for @citySearchPopularDestinations.
  ///
  /// In en, this message translates to:
  /// **'POPULAR DESTINATIONS'**
  String get citySearchPopularDestinations;

  /// No description provided for @citySearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Check your connection.'**
  String get citySearchFailed;

  /// No description provided for @citySearchCityFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load city. Try again.'**
  String get citySearchCityFailed;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authWelcome;

  /// No description provided for @authLoginTab.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginTab;

  /// No description provided for @authRegisterTab.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegisterTab;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginButton;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authCreateAccount;

  /// No description provided for @authContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get authContinueAsGuest;

  /// No description provided for @preferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you like?'**
  String get preferencesTitle;

  /// No description provided for @preferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the types of places you want to visit in {city}.'**
  String preferencesSubtitle(String city);

  /// No description provided for @preferencesFindPlaces.
  ///
  /// In en, this message translates to:
  /// **'Find Places'**
  String get preferencesFindPlaces;

  /// No description provided for @preferencesSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one category.'**
  String get preferencesSelectAtLeastOne;

  /// No description provided for @categoryRestaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get categoryRestaurants;

  /// No description provided for @categoryCafes.
  ///
  /// In en, this message translates to:
  /// **'Cafes'**
  String get categoryCafes;

  /// No description provided for @categoryAttractions.
  ///
  /// In en, this message translates to:
  /// **'Attractions'**
  String get categoryAttractions;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryNightlife.
  ///
  /// In en, this message translates to:
  /// **'Nightlife'**
  String get categoryNightlife;

  /// No description provided for @catRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get catRestaurant;

  /// No description provided for @catCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get catCafe;

  /// No description provided for @catAttraction.
  ///
  /// In en, this message translates to:
  /// **'Attraction'**
  String get catAttraction;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catNightlife.
  ///
  /// In en, this message translates to:
  /// **'Nightlife'**
  String get catNightlife;

  /// No description provided for @placesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Places'**
  String get placesListTitle;

  /// No description provided for @placesListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose at least 3 places to visit.'**
  String get placesListSubtitle;

  /// No description provided for @placesListLoading.
  ///
  /// In en, this message translates to:
  /// **'Finding great places...'**
  String get placesListLoading;

  /// No description provided for @placesListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No places found. Try different categories or a broader area.'**
  String get placesListEmpty;

  /// No description provided for @placesListGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get placesListGenerate;

  /// No description provided for @placesListViewMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get placesListViewMap;

  /// No description provided for @placesListGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get placesListGoBack;

  /// No description provided for @placesListSelectMore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Select 1 more place} other{Select {count} more places}}'**
  String placesListSelectMore(int count);

  /// No description provided for @placesListSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} places selected'**
  String placesListSelectedCount(int count);

  /// No description provided for @placeDetailGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get placeDetailGoBack;

  /// No description provided for @placeDetailOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get placeDetailOpen;

  /// No description provided for @placeDetailClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get placeDetailClosed;

  /// No description provided for @placeDetailAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get placeDetailAbout;

  /// No description provided for @placeDetailViewMap.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get placeDetailViewMap;

  /// No description provided for @placeDetailAddItinerary.
  ///
  /// In en, this message translates to:
  /// **'Add to Itinerary'**
  String get placeDetailAddItinerary;

  /// No description provided for @placeDetailAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get placeDetailAdded;

  /// No description provided for @placeDetailRemovedSnack.
  ///
  /// In en, this message translates to:
  /// **'Removed from itinerary'**
  String get placeDetailRemovedSnack;

  /// No description provided for @placeDetailAddedSnack.
  ///
  /// In en, this message translates to:
  /// **'Added to itinerary'**
  String get placeDetailAddedSnack;

  /// No description provided for @placeDetailFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get placeDetailFree;

  /// No description provided for @itineraryYourItinerary.
  ///
  /// In en, this message translates to:
  /// **'Your Itinerary'**
  String get itineraryYourItinerary;

  /// No description provided for @itineraryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get itineraryEdit;

  /// No description provided for @itineraryDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get itineraryDone;

  /// No description provided for @itineraryNoItinerary.
  ///
  /// In en, this message translates to:
  /// **'No itinerary generated yet.'**
  String get itineraryNoItinerary;

  /// No description provided for @itinerarySaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Itinerary'**
  String get itinerarySaveButton;

  /// No description provided for @itinerarySaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Itinerary'**
  String get itinerarySaveDialogTitle;

  /// No description provided for @itinerarySaveHint.
  ///
  /// In en, this message translates to:
  /// **'Give your plan a name'**
  String get itinerarySaveHint;

  /// No description provided for @itineraryCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get itineraryCancel;

  /// No description provided for @itinerarySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get itinerarySave;

  /// No description provided for @itinerarySavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Itinerary saved!'**
  String get itinerarySavedSuccess;

  /// No description provided for @itinerarySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save. Try again.'**
  String get itinerarySaveFailed;

  /// No description provided for @itineraryDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Trip to {city}'**
  String itineraryDefaultName(String city);

  /// No description provided for @nPlaces.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 place} other{{count} places}}'**
  String nPlaces(int count);

  /// No description provided for @savedItinerariesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Itineraries'**
  String get savedItinerariesTitle;

  /// No description provided for @savedItinerariesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved itineraries yet.'**
  String get savedItinerariesEmpty;

  /// No description provided for @savedPlanFirstTrip.
  ///
  /// In en, this message translates to:
  /// **'Plan Your First Trip'**
  String get savedPlanFirstTrip;

  /// No description provided for @savedDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Itinerary'**
  String get savedDeleteTitle;

  /// No description provided for @savedDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String savedDeleteContent(String name);

  /// No description provided for @savedCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get savedCancel;

  /// No description provided for @savedDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get savedDelete;

  /// No description provided for @savedDetailItinerary.
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get savedDetailItinerary;

  /// No description provided for @savedDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Itinerary not found.'**
  String get savedDetailNotFound;

  /// No description provided for @savedDetailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load itinerary.'**
  String get savedDetailLoadFailed;

  /// No description provided for @savedDetailGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get savedDetailGoBack;

  /// No description provided for @favTitle.
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favTitle;

  /// No description provided for @favEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favourites yet. Tap ♥ on a place to save it.'**
  String get favEmpty;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileTitle;

  /// No description provided for @profileAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get profileAccountSettings;

  /// No description provided for @profileFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileFavorites;

  /// No description provided for @profileHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get profileHistory;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettingsTitle;

  /// No description provided for @accountSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account details and preferences.'**
  String get accountSettingsSubtitle;

  /// No description provided for @accountProfileInfo.
  ///
  /// In en, this message translates to:
  /// **'PROFILE INFORMATION'**
  String get accountProfileInfo;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accountName;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmail;

  /// No description provided for @accountSecurityPrefs.
  ///
  /// In en, this message translates to:
  /// **'SECURITY & PREFERENCES'**
  String get accountSecurityPrefs;

  /// No description provided for @accountChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get accountChangePassword;

  /// No description provided for @accountNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get accountNotifications;

  /// No description provided for @accountLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get accountLanguage;

  /// No description provided for @accountLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get accountLogOut;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic (العربية)'**
  String get languageArabic;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No trips yet.'**
  String get historyEmpty;

  /// No description provided for @historyPlanFirstTrip.
  ///
  /// In en, this message translates to:
  /// **'Plan Your First Trip'**
  String get historyPlanFirstTrip;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapTitle;

  /// No description provided for @mapNoPlaces.
  ///
  /// In en, this message translates to:
  /// **'No places selected yet.'**
  String get mapNoPlaces;

  /// No description provided for @mapGoToPlaces.
  ///
  /// In en, this message translates to:
  /// **'Go to Places'**
  String get mapGoToPlaces;

  /// No description provided for @mapWebFallback.
  ///
  /// In en, this message translates to:
  /// **'Interactive map is available on Android & iOS. Showing place list with coordinates.'**
  String get mapWebFallback;

  /// No description provided for @mapDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get mapDetails;

  /// No description provided for @slotMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get slotMorning;

  /// No description provided for @slotAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get slotAfternoon;

  /// No description provided for @slotEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get slotEvening;

  /// No description provided for @slotMorningTime.
  ///
  /// In en, this message translates to:
  /// **'8:00 AM – 12:00 PM'**
  String get slotMorningTime;

  /// No description provided for @slotAfternoonTime.
  ///
  /// In en, this message translates to:
  /// **'12:00 PM – 5:00 PM'**
  String get slotAfternoonTime;

  /// No description provided for @slotEveningTime.
  ///
  /// In en, this message translates to:
  /// **'5:00 PM – 10:00 PM'**
  String get slotEveningTime;

  /// No description provided for @slotNoPlaces.
  ///
  /// In en, this message translates to:
  /// **'No places assigned to this slot.'**
  String get slotNoPlaces;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
