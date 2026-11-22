import 'package:flutter_test/flutter_test.dart';

import 'package:real_estate_app/models/property.dart';

void main() {
  test('photos fall back to the cover image when no gallery is set', () {
    const property = Property(
      id: '1',
      title: 'شقة تجريبية',
      type: 'شقة',
      location: 'التجمع الخامس',
      governorate: 'القاهرة',
      mode: ListingMode.rent,
      price: 12000,
      bedrooms: 3,
      bathrooms: 2,
      area: 160,
      imageUrl: 'https://example.com/cover.jpg',
      lastConfirmed: 'اليوم',
    );

    expect(property.photos, ['https://example.com/cover.jpg']);
  });

  test('photos return the gallery when it is set', () {
    const property = Property(
      id: '2',
      title: 'فيلا تجريبية',
      type: 'فيلا',
      location: 'الشيخ زايد',
      governorate: 'الجيزة',
      mode: ListingMode.sale,
      price: 5000000,
      bedrooms: 4,
      bathrooms: 3,
      area: 300,
      imageUrl: 'https://example.com/cover.jpg',
      imageUrls: ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
      lastConfirmed: 'اليوم',
    );

    expect(property.photos.length, 2);
    expect(property.photos.first, 'https://example.com/1.jpg');
  });
}
