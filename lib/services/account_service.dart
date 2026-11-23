import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/account_role.dart';

class AccountService {
  static Stream<AccountRole?> watchRole(String uid) => FirebaseFirestore
      .instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => AccountRole.parse(doc.data()?['role']));

  static Future<void> createProfile({
    required String name,
    required String phone,
    required AccountRole role,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in first');
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final existing = await tx.get(ref);
      if (existing.exists) return;
      tx.set(ref, {
        'name': name.trim(),
        'phone': phone.trim(),
        'role': role.value,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
    await user.updateDisplayName(name.trim());
  }

  static Future<void> requireRole(AccountRole expected) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in first');
    final profile = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get(const GetOptions(source: Source.server));
    if (AccountRole.parse(profile.data()?['role']) != expected) {
      throw StateError('Account type not permitted');
    }
  }
}
