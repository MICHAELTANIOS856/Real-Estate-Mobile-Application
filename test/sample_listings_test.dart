import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/config/app_flags.dart';
import 'package:real_estate_app/main.dart';
import 'package:real_estate_app/models/property.dart';
import 'package:real_estate_app/services/sample_listings.dart';

void main() {
  test('samples are marked, distinct, varied and not Firestore ids', () {
    final all = SampleListings.all;
    expect(all, hasLength(8));
    expect(all.every((p) => p.isSample), isTrue);
    expect(all.every((p) => p.title.startsWith('تجريبي فقط')), isTrue);
    expect(all.map((p) => p.id).toSet(), hasLength(8));
    expect(all.every((p) => p.id.startsWith(SampleListings.idPrefix)), isTrue);
    expect(all.map((p) => p.mode).toSet(), {
      ListingMode.rent,
      ListingMode.sale,
    });
    expect(all.every((p) => p.imageUrl.startsWith('data:image/jpeg')), isTrue);
  });
  test('samples filter like real listings and real ones are not samples', () {
    final res = filterAvailableProperties(
      SampleListings.all,
      selectedMode: ListingMode.sale,
      selectedGovernorate: 'الأقصر',
      searchText: '',
    );
    expect(res, hasLength(1));
    expect(
      const Property(
        id: 'x',
        title: 't',
        type: 'شقة',
        location: 'l',
        governorate: 'g',
        mode: ListingMode.rent,
        price: 1,
        bedrooms: 1,
        bathrooms: 1,
        area: 1,
        imageUrl: '',
        lastConfirmed: '',
      ).isSample,
      isFalse,
    );
  });
  test('test-build flags are on', () {
    expect(kAlwaysStartSignedOut, isTrue);
    expect(kShowSampleListings, isTrue);
  });
}
