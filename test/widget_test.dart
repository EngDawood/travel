// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:travel/app.dart';
import 'package:travel/providers/auth_provider.dart';
import 'package:travel/providers/places_provider.dart';
import 'package:travel/providers/itinerary_provider.dart';
import 'package:travel/providers/map_provider.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PlacesProvider()),
          ChangeNotifierProvider(create: (_) => ItineraryProvider()),
          ChangeNotifierProvider(create: (_) => MapProvider()),
        ],
        child: const TravelApp(),
      ),
    );
    expect(find.text('Mini Travel Assistant'), findsOneWidget);
  });
}
