import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../models/property.dart';
import 'demo_properties.dart';

/// Built-in sample listings for consumers. Not stored in Firebase, so no
/// project access is needed. Marked as samples and never mixed into real data.
class SampleListings {
  static const idPrefix = 'sample_';
  static List<Property>? _cache;

  static List<Property> get all => _cache ??= _build();

  static List<Property> _build() {
    final colors = [
      img.ColorRgb8(23, 76, 60),
      img.ColorRgb8(38, 128, 100),
      img.ColorRgb8(180, 140, 70),
      img.ColorRgb8(60, 100, 130),
    ];
    var i = 0;
    return [
      for (final f in DemoProperties.fixtures)
        () {
          final image = img.Image(width: 120, height: 80);
          img.fill(image, color: colors[i++ % colors.length]);
          final photo =
              'data:image/jpeg;base64,${base64Encode(Uint8List.fromList(img.encodeJpg(image, quality: 65)))}';
          return Property(
            id: '$idPrefix${f['key']}',
            title: 'تجريبي فقط: ${f['title']}',
            type: f['type'] as String,
            location: f['location'] as String,
            governorate: f['governorate'] as String,
            mode: f['mode'] == 'sale' ? ListingMode.sale : ListingMode.rent,
            price: f['price'] as int,
            bedrooms: f['bedrooms'] as int,
            bathrooms: f['bathrooms'] as int,
            area: f['area'] as int,
            imageUrl: photo,
            imageUrls: [photo],
            lastConfirmed: 'عرض تجريبي',
            description: 'عقار تجريبي مدمج في التطبيق للعرض فقط، وليس إعلانًا حقيقيًا ولا يمكن طلب معاينته.',
            isSample: true,
          );
        }(),
    ];
  }
}
