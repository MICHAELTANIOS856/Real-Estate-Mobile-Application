import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:real_estate_app/models/property.dart';
import 'package:real_estate_app/services/property_photos.dart';
import 'package:real_estate_app/widgets/property_image.dart';

void main() {
  test(
    'large noisy photo becomes a bounded JPEG with preserved aspect ratio',
    () {
      final random = Random(12);
      final input = img.Image(width: 1700, height: 1100);
      for (final pixel in input) {
        pixel.setRgb(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
        );
      }
      final bytes = PropertyPhotos.compressSync(img.encodePng(input));
      expect(bytes.length, lessThanOrEqualTo(PropertyPhotos.maxBytes));
      final output = img.decodeJpg(bytes)!;
      expect(output.width, lessThanOrEqualTo(960));
      expect(output.height, lessThanOrEqualTo(960));
      expect(output.width / output.height, closeTo(1700 / 1100, 0.01));
    },
  );
  test('small image is not upscaled and unsupported data is rejected', () {
    final bytes = img.encodePng(img.Image(width: 100, height: 70));
    final output = img.decodeJpg(PropertyPhotos.compressSync(bytes))!;
    expect(output.width, 100);
    expect(output.height, 70);
    expect(
      () => PropertyPhotos.compressSync(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
    expect(
      () => PropertyPhotos.compressSync(
        Uint8List(PropertyPhotos.maxInputBytes + 1),
      ),
      throwsFormatException,
    );
  });
  test('count and byte caps hold below half the document limit', () {
    final maxPhoto = Uint8List(PropertyPhotos.maxBytes);
    PropertyPhotos.validate(List.filled(4, maxPhoto));
    expect(4 * maxPhoto.length, lessThan(512 * 1024));
    expect(() => PropertyPhotos.validate([]), throwsArgumentError);
    expect(
      () => PropertyPhotos.validate(List.filled(5, maxPhoto)),
      throwsArgumentError,
    );
    expect(
      () => PropertyPhotos.validate([Uint8List(122881)]),
      throwsArgumentError,
    );
    expect(() => PropertyPhotos.validate([Uint8List(0)]), throwsArgumentError);
  });
  test(
    'Firestore blobs become memory image sources and legacy URLs still work',
    () {
      final jpeg = img.encodeJpg(img.Image(width: 12, height: 8));
      final property = Property.fromData('new', {
        'photoBytes': [Blob(jpeg)],
      });
      expect(
        property.photos.single,
        'data:image/jpeg;base64,${base64Encode(jpeg)}',
      );
      final old = Property.fromData('old', {
        'imageUrls': ['https://example.com/a.jpg'],
      });
      expect(old.photos.single, 'https://example.com/a.jpg');
    },
  );
  testWidgets('Firestore JPEG renders without a network image', (tester) async {
    final jpeg = img.encodeJpg(img.Image(width: 12, height: 8));
    await tester.pumpWidget(
      MaterialApp(
        home: PropertyImage('data:image/jpeg;base64,${base64Encode(jpeg)}'),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<Image>(find.byType(Image)).image, isA<MemoryImage>());
    expect(tester.takeException(), isNull);
  });
}
