import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/models/property.dart';
import 'package:real_estate_app/screens/my_properties_page.dart';

Property listing({String owner = 'owner', int days = 0}) {
  final confirmed = DateTime.now().subtract(Duration(days: days));
  return Property(
    id: '$owner-$days',
    title: '$owner property',
    type: 'شقة',
    location: 'الأقصر',
    governorate: 'الأقصر',
    mode: ListingMode.rent,
    price: 5000,
    bedrooms: 2,
    bathrooms: 1,
    area: 100,
    imageUrl: '',
    lastConfirmed: '',
    ownerId: owner,
    createdAt: DateTime(2026, 11, 1),
    lastConfirmedAt: confirmed,
    expiresAt: confirmed.add(const Duration(days: 7)),
  );
}

void main() {
  test('publication date is separate from latest renewal', () {
    expect(listing(days: 3).publishedDate, '1/11/2026');
  });
  test('renewal notices at day three and final warning at day six', () {
    expect(listing().renewalNotice, isNull);
    expect(listing(days: 3).renewalNotice, contains('3'));
    expect(listing(days: 6).renewalNotice, contains('تنبيه أخير'));
  });
  test('day seven expires and a renewed listing is active again', () {
    expect(listing(days: 7).isExpired, isTrue);
    expect(listing(days: 8).renewalNotice, contains('انتهت'));
    expect(listing().isExpired, isFalse);
  });
  testWidgets('owner list excludes another owners properties', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OwnerPropertiesList(
            ownerId: 'owner',
            stream: Stream.value([
              listing(days: 6),
              listing(owner: 'another', days: 3),
            ]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('owner property'), findsOneWidget);
    expect(find.text('another property'), findsNothing);
    expect(find.textContaining('تنبيه أخير'), findsOneWidget);
    expect(find.textContaining('تاريخ النشر:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
