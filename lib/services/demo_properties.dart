import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../models/account_role.dart';
import 'account_service.dart';

/// Manual debug-only fixtures. Never runs at startup or in release builds.
class DemoProperties {
  static Future<void> create() async {
    if (!kDebugMode) throw StateError('Debug builds only');
    await AccountService.requireRole(AccountRole.owner);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseFirestore.instance;
    final image = img.Image(width: 120, height: 80);
    img.fill(image, color: img.ColorRgb8(23, 76, 60));
    final photo = Blob(Uint8List.fromList(img.encodeJpg(image, quality: 65)));
    final existing = await db
        .collection('properties')
        .where('ownerId', isEqualTo: uid)
        .get();
    final ids = existing.docs.map((doc) => doc.id).toSet();
    for (final mode in ['rent', 'sale']) {
      final ref = db.collection('properties').doc('demo_${uid}_$mode');
      if (ids.contains(ref.id)) continue;
      await ref.set({
        'title': mode == 'rent'
            ? 'تجريبي فقط: شقة للإيجار'
            : 'تجريبي فقط: شقة للبيع',
        'type': 'شقة',
        'governorate': 'الأقصر',
        'location': 'موقع افتراضي للاختبار فقط',
        'mode': mode,
        'price': mode == 'rent' ? 5000 : 1000000,
        'bedrooms': 2,
        'bathrooms': 1,
        'area': 100,
        'description': 'بيانات وهمية للاختبار فقط، ليست إعلانًا حقيقيًا ولا يوجد عقار أو موعد معاينة فعلي.',
        'photoBytes': [photo],
        'ownerId': uid,
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
        'lastConfirmedAt': FieldValue.serverTimestamp(),
        'isDemo': true,
      });
    }
  }

  static Future<void> remove() async {
    if (!kDebugMode) throw StateError('Debug builds only');
    await AccountService.requireRole(AccountRole.owner);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseFirestore.instance;
    // Query by owner only, so no composite index is needed.
    final docs = await db
        .collection('properties')
        .where('ownerId', isEqualTo: uid)
        .get();
    for (final doc in docs.docs.where((doc) => doc.data()['isDemo'] == true)) {
      await doc.reference.delete();
    }
  }
}
