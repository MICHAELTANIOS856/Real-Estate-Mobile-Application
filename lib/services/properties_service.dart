import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/property.dart';

/// Firestore/Storage access for property listings.
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

  /// Uploads one listing photo and returns its download URL.
  static Future<String> uploadPropertyImage({
    required String ownerId,
    required XFile image,
    required int index,
  }) async {
    final extension = image.name.split('.').last.toLowerCase();
    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
    final ref = FirebaseStorage.instance.ref().child(
      'property_images/$ownerId/${DateTime.now().millisecondsSinceEpoch}_$index.$extension',
    );

    await ref.putData(
      await image.readAsBytes(),
      SettableMetadata(contentType: contentType),
    );
    return ref.getDownloadURL();
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
    required List<String> imageUrls,
    required String ownerId,
  }) async {
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
      'imageUrls': imageUrls,
      'ownerId': ownerId,
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
      'lastConfirmedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }
}
