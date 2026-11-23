import '../models/account_role.dart';
import 'account_service.dart';

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'dart:typed_data';

import 'property_photos.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/property.dart';

/// Firestore access for property listings.
class PropertiesService {
  PropertiesService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Streams all currently available properties, newest first.
  static Stream<List<Property>> watchAvailableProperties() {
    return Stream.multi((controller) {
      List<Property> latest = [];
      void emit() {
        final visible = latest.where((p) => !p.isExpired).toList();
        visible.sort(
          (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
            a.createdAt ?? DateTime(1970),
          ),
        );
        controller.add(visible);
      }

      final subscription = _firestore
          .collection('properties')
          .where('status', isEqualTo: 'available')
          .snapshots()
          .listen((snapshot) {
            latest = snapshot.docs.map(Property.fromFirestore).toList();
            emit();
          }, onError: controller.addError);
      final timer = Timer.periodic(const Duration(minutes: 1), (_) => emit());
      controller.onCancel = () {
        timer.cancel();
        subscription.cancel();
      };
    });
  }

  static Future<void> renewProperty(Property property) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid != property.ownerId) {
      throw StateError('Not the owner');
    }
    await AccountService.requireRole(AccountRole.owner);
    await _firestore.collection('properties').doc(property.id).update({
      'lastConfirmedAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<Property>> watchOwnerProperties(String ownerId) {
    return _firestore
        .collection('properties')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map(Property.fromFirestore).toList();
          items.sort(
            (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
              a.createdAt ?? DateTime(1970),
            ),
          );
          return items;
        });
  }

  /// Saves a new property listing for the signed-in owner.
  static Future<String> addProperty({
    required String title,
    required String type,
    required String governorate,
    required String location,
    required ListingMode mode,
    required int price,
    required int bedrooms,
    required int bathrooms,
    required int area,
    required String description,
    required List<Uint8List> photos,
    required String ownerId,
  }) async {
    if (FirebaseAuth.instance.currentUser?.uid != ownerId) {
      throw StateError('Not the signed-in owner');
    }
    await AccountService.requireRole(AccountRole.owner);
    PropertyPhotos.validate(photos);
    final doc = await _firestore.collection('properties').add({
      'title': title,
      'type': type,
      'governorate': governorate,
      'location': location,
      'mode': mode == ListingMode.sale ? 'sale' : 'rent',
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'description': description,
      'photoBytes': photos.map((bytes) => Blob(bytes)).toList(),
      'ownerId': ownerId,
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
      'lastConfirmedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }
}
