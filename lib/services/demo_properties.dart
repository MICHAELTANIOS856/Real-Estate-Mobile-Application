import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../models/account_role.dart';
import 'account_service.dart';

/// Manual debug-only fixtures. Never runs at startup or in release builds.
class DemoProperties {
  static const fixtures = <Map<String, Object>>[
    {
      'key': 'rent',
      'title': 'شقة عصرية بإطلالة مميزة',
      'type': 'شقة',
      'governorate': 'القاهرة',
      'location': 'التجمع الخامس',
      'mode': 'rent',
      'price': 12000,
      'bedrooms': 3,
      'bathrooms': 2,
      'area': 160,
    },
    {
      'key': 'giza-rent',
      'title': 'شقة واسعة بالقرب من الخدمات',
      'type': 'شقة',
      'governorate': 'الجيزة',
      'location': 'الشيخ زايد',
      'mode': 'rent',
      'price': 18000,
      'bedrooms': 3,
      'bathrooms': 2,
      'area': 190,
    },
    {
      'key': 'alex-rent',
      'title': 'فيلا مميزة بحديقة خاصة',
      'type': 'فيلا',
      'governorate': 'الإسكندرية',
      'location': 'العجمي',
      'mode': 'rent',
      'price': 25000,
      'bedrooms': 4,
      'bathrooms': 3,
      'area': 280,
    },
    {
      'key': 'cairo-sale',
      'title': 'شقة للبيع بتصميم أنيق',
      'type': 'شقة',
      'governorate': 'القاهرة',
      'location': 'مدينة نصر',
      'mode': 'sale',
      'price': 2400000,
      'bedrooms': 3,
      'bathrooms': 2,
      'area': 155,
    },
    {
      'key': 'sale',
      'title': 'شقة عائلية للبيع',
      'type': 'شقة',
      'governorate': 'الأقصر',
      'location': 'وسط الأقصر',
      'mode': 'sale',
      'price': 1000000,
      'bedrooms': 2,
      'bathrooms': 1,
      'area': 100,
    },
    {
      'key': 'luxor-rent',
      'title': 'شقة مريحة للإيجار',
      'type': 'شقة',
      'governorate': 'الأقصر',
      'location': 'الكرنك',
      'mode': 'rent',
      'price': 5000,
      'bedrooms': 2,
      'bathrooms': 1,
      'area': 95,
    },
    {
      'key': 'giza-sale',
      'title': 'دوبلكس واسع للبيع',
      'type': 'دوبلكس',
      'governorate': 'الجيزة',
      'location': 'السادس من أكتوبر',
      'mode': 'sale',
      'price': 3500000,
      'bedrooms': 4,
      'bathrooms': 3,
      'area': 230,
    },
    {
      'key': 'alex-sale',
      'title': 'شقة قريبة من البحر',
      'type': 'شقة',
      'governorate': 'الإسكندرية',
      'location': 'ميامي',
      'mode': 'sale',
      'price': 1900000,
      'bedrooms': 2,
      'bathrooms': 1,
      'area': 120,
    },
  ];

  static String fixtureId(String uid, Map<String, Object> fixture) =>
      'demo_${uid}_${fixture['key']}';

  static bool canRemove(Map<String, dynamic> data, String uid) =>
      data['ownerId'] == uid && data['isDemo'] == true;

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
    final byId = {for (final doc in existing.docs) doc.id: doc};
    for (final fixture in fixtures) {
      final id = fixtureId(uid, fixture);
      final previous = byId[id];
      if (previous != null) {
        // Keep repeated taps idempotent. Only our own marked fixture can renew.
        if (canRemove(previous.data(), uid)) {
          await previous.reference.update({
            'lastConfirmedAt': FieldValue.serverTimestamp(),
          });
        }
        continue;
      }
      await db.collection('properties').doc(id).set({
        for (final entry in fixture.entries)
          if (entry.key != 'key') entry.key: entry.value,
        'title': 'تجريبي فقط: ${fixture['title']}',
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
    for (final doc in docs.docs.where((doc) => canRemove(doc.data(), uid))) {
      await doc.reference.delete();
    }
  }
}
