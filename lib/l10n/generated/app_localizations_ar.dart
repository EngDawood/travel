// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navSaved => 'محفوظة';

  @override
  String get navFavourites => 'المفضلة';

  @override
  String get navProfile => 'الإعدادات';

  @override
  String get citySearchTitle => 'إلى أين تذهب؟';

  @override
  String get citySearchSubtitle => 'ابحث عن مدينة لبدء التخطيط.';

  @override
  String get citySearchHint => 'مثال: باريس، طوكيو، نيويورك';

  @override
  String get citySearchRecentSearches => 'عمليات البحث الأخيرة';

  @override
  String get citySearchPopularDestinations => 'الوجهات الشائعة';

  @override
  String get citySearchFailed => 'فشل البحث. تحقق من اتصالك.';

  @override
  String get citySearchCityFailed => 'تعذّر تحميل المدينة. حاول مرة أخرى.';

  @override
  String get authWelcome => 'مرحباً';

  @override
  String get authLoginTab => 'تسجيل الدخول';

  @override
  String get authRegisterTab => 'إنشاء حساب';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authUsername => 'اسم المستخدم';

  @override
  String get authLoginButton => 'تسجيل الدخول';

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authContinueAsGuest => 'المتابعة كضيف';

  @override
  String get preferencesTitle => 'ما الذي تفضله؟';

  @override
  String preferencesSubtitle(String city) {
    return 'اختر أنواع الأماكن التي تريد زيارتها في $city.';
  }

  @override
  String get preferencesFindPlaces => 'اكتشف الأماكن';

  @override
  String get preferencesSelectAtLeastOne => 'يرجى اختيار فئة واحدة على الأقل.';

  @override
  String get categoryRestaurants => 'مطاعم';

  @override
  String get categoryCafes => 'مقاهٍ';

  @override
  String get categoryAttractions => 'معالم سياحية';

  @override
  String get categoryShopping => 'تسوق';

  @override
  String get categoryNightlife => 'حياة ليلية';

  @override
  String get catRestaurant => 'مطعم';

  @override
  String get catCafe => 'مقهى';

  @override
  String get catAttraction => 'معلم سياحي';

  @override
  String get catShopping => 'تسوق';

  @override
  String get catNightlife => 'حياة ليلية';

  @override
  String get placesListTitle => 'اختر الأماكن';

  @override
  String get placesListSubtitle => 'اختر 3 أماكن على الأقل لزيارتها.';

  @override
  String get placesListLoading => 'جارٍ البحث عن أماكن رائعة...';

  @override
  String get placesListEmpty =>
      'لم يُعثر على أماكن. جرّب فئات مختلفة أو منطقة أوسع.';

  @override
  String get placesListGenerate => 'إنشاء';

  @override
  String get placesListViewMap => 'عرض على الخريطة';

  @override
  String get placesListGoBack => 'رجوع';

  @override
  String placesListSelectMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اختر $count مكاناً آخر',
      one: 'اختر مكاناً واحداً آخر',
    );
    return '$_temp0';
  }

  @override
  String placesListSelectedCount(int count) {
    return '$count أماكن محددة';
  }

  @override
  String get placeDetailGoBack => 'رجوع';

  @override
  String get placeDetailOpen => 'مفتوح';

  @override
  String get placeDetailClosed => 'مغلق';

  @override
  String get placeDetailAbout => 'عن المكان';

  @override
  String get placeDetailViewMap => 'عرض على الخريطة';

  @override
  String get placeDetailAddItinerary => 'أضف إلى الجدول';

  @override
  String get placeDetailAdded => 'تمت الإضافة';

  @override
  String get placeDetailRemovedSnack => 'أُزيل من الجدول';

  @override
  String get placeDetailAddedSnack => 'أُضيف إلى الجدول';

  @override
  String get placeDetailFree => 'مجاني';

  @override
  String get itineraryYourItinerary => 'جدول رحلتك';

  @override
  String get itineraryEdit => 'تعديل';

  @override
  String get itineraryDone => 'تم';

  @override
  String get itineraryNoItinerary => 'لم يُنشئ جدول بعد.';

  @override
  String get itinerarySaveButton => 'حفظ الجدول';

  @override
  String get itinerarySaveDialogTitle => 'حفظ الجدول';

  @override
  String get itinerarySaveHint => 'أعطِ خطتك اسماً';

  @override
  String get itineraryCancel => 'إلغاء';

  @override
  String get itinerarySave => 'حفظ';

  @override
  String get itinerarySavedSuccess => 'تم حفظ الجدول!';

  @override
  String get itinerarySaveFailed => 'فشل الحفظ. حاول مرة أخرى.';

  @override
  String itineraryDefaultName(String city) {
    return 'رحلة إلى $city';
  }

  @override
  String nPlaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أماكن',
      one: 'مكان واحد',
    );
    return '$_temp0';
  }

  @override
  String get savedItinerariesTitle => 'الجداول المحفوظة';

  @override
  String get savedItinerariesEmpty => 'لا توجد جداول محفوظة بعد.';

  @override
  String get savedPlanFirstTrip => 'خطط لأول رحلة';

  @override
  String get savedDeleteTitle => 'حذف الجدول';

  @override
  String savedDeleteContent(String name) {
    return 'حذف \"$name\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get savedCancel => 'إلغاء';

  @override
  String get savedDelete => 'حذف';

  @override
  String get savedDetailItinerary => 'الجدول';

  @override
  String get savedDetailNotFound => 'الجدول غير موجود.';

  @override
  String get savedDetailLoadFailed => 'فشل تحميل الجدول.';

  @override
  String get savedDetailGoBack => 'رجوع';

  @override
  String get favTitle => 'المفضلة';

  @override
  String get favEmpty => 'لا توجد مفضلات بعد. انقر ♥ على مكان لحفظه.';

  @override
  String get profileTitle => 'الإعدادات';

  @override
  String get profileAccountSettings => 'إعدادات الحساب';

  @override
  String get profileFavorites => 'المفضلة';

  @override
  String get profileHistory => 'السجل';

  @override
  String get accountSettingsTitle => 'إعدادات الحساب';

  @override
  String get accountSettingsSubtitle => 'إدارة بيانات حسابك وتفضيلاتك.';

  @override
  String get accountProfileInfo => 'معلومات الحساب';

  @override
  String get accountName => 'الاسم';

  @override
  String get accountEmail => 'البريد الإلكتروني';

  @override
  String get accountSecurityPrefs => 'الأمان والتفضيلات';

  @override
  String get accountChangePassword => 'تغيير كلمة المرور';

  @override
  String get accountNotifications => 'الإشعارات';

  @override
  String get accountLanguage => 'اللغة';

  @override
  String get accountLogOut => 'تسجيل الخروج';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get historyTitle => 'سجل الرحلات';

  @override
  String get historyEmpty => 'لا توجد رحلات بعد.';

  @override
  String get historyPlanFirstTrip => 'خطط لأول رحلة';

  @override
  String get mapTitle => 'الخريطة';

  @override
  String get mapNoPlaces => 'لم يتم اختيار أماكن بعد.';

  @override
  String get mapGoToPlaces => 'اذهب إلى الأماكن';

  @override
  String get mapWebFallback =>
      'الخريطة التفاعلية متاحة على Android وiOS. عرض قائمة الأماكن مع الإحداثيات.';

  @override
  String get mapDetails => 'التفاصيل';

  @override
  String get slotMorning => 'الصباح';

  @override
  String get slotAfternoon => 'بعد الظهر';

  @override
  String get slotEvening => 'المساء';

  @override
  String get slotMorningTime => '8:00 ص – 12:00 م';

  @override
  String get slotAfternoonTime => '12:00 م – 5:00 م';

  @override
  String get slotEveningTime => '5:00 م – 10:00 م';

  @override
  String get slotNoPlaces => 'لا توجد أماكن مخصصة لهذه الفترة.';
}
