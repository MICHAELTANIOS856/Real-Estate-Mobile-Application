import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Small, bounded Firestore photos for the Spark demo, not original storage.
class PropertyPhotos {
  PropertyPhotos._();
  static const maxCount = 4;
  static const maxBytes = 120 * 1024;
  static const maxDimension = 960;
  static const maxInputBytes = 10 * 1024 * 1024;
  static const maxInputPixels = 24000000;

  static void validate(List<Uint8List> photos) {
    if (photos.isEmpty || photos.length > maxCount) {
      throw ArgumentError('Choose one to four photos');
    }
    for (final photo in photos) {
      if (photo.isEmpty || photo.length > maxBytes) {
        throw ArgumentError('Photo exceeds the Firestore demo limit');
      }
    }
  }

  static Future<Uint8List> compress(Uint8List bytes) =>
      compute(compressSync, bytes);

  static Uint8List compressSync(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > maxInputBytes) {
      throw const FormatException('اختر صورة أصغر من 10 ميجابايت');
    }
    final decoder = img.findDecoderForData(bytes);
    final info = decoder?.startDecode(bytes);
    if (info == null ||
        info.width <= 0 ||
        info.height <= 0 ||
        info.width * info.height > maxInputPixels) {
      throw const FormatException(
        'الصورة غير مدعومة أو أبعادها كبيرة جدًا. اختر JPEG أو PNG',
      );
    }
    final decoded = decoder!.decodeFrame(0);
    if (decoded == null) {
      throw const FormatException('تعذر قراءة الصورة، اختر JPEG أو PNG');
    }
    var image = img.bakeOrientation(decoded);
    if (image.width > maxDimension || image.height > maxDimension) {
      image = img.copyResize(
        image,
        width: image.width >= image.height ? maxDimension : null,
        height: image.height > image.width ? maxDimension : null,
      );
    }
    while (true) {
      for (final quality in [75, 60, 45, 30]) {
        final result = img.encodeJpg(image, quality: quality);
        if (result.length <= maxBytes) return result;
      }
      if (image.width <= 320 && image.height <= 320) {
        throw const FormatException('تعذر تصغير الصورة للحجم المسموح');
      }
      image = img.copyResize(
        image,
        width: (image.width * 0.75).round(),
        height: (image.height * 0.75).round(),
      );
    }
  }
}
