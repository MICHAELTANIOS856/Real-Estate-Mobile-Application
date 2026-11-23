import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/main.dart';
import 'package:real_estate_app/models/property.dart';

import 'renewal_test.dart' show listing;

void main() {
  for (final byText in [true, false]) {
    testWidgets(
      'unmatched ${byText ? 'search text' : 'location filter'} shows clear empty message',
      (tester) async {
        final results = filterAvailableProperties(
          [listing()],
          selectedMode: ListingMode.rent,
          selectedGovernorate: byText ? 'الكل' : 'القاهرة',
          searchText: byText ? 'fgg' : '',
        );
        expect(results, isEmpty);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: results.isEmpty
                  ? const AvailablePropertiesEmptyState()
                  : const Text('listings'),
            ),
          ),
        );
        expect(find.text('لا يوجد عقارات متاحة'), findsOneWidget);
        final message = tester.widget<Text>(find.text('لا يوجد عقارات متاحة'));
        expect(message.style!.fontSize, greaterThanOrEqualTo(24));
        expect(tester.takeException(), isNull);
      },
    );
  }
  test('matching location and text retain a listing', () {
    expect(
      filterAvailableProperties(
        [listing()],
        selectedMode: ListingMode.rent,
        selectedGovernorate: 'الأقصر',
        searchText: 'owner',
      ),
      hasLength(1),
    );
  });
}
