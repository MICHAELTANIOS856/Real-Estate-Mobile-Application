import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/property.dart';
import 'my_properties_page.dart';
import 'add_property_page.dart';

class OwnerHomePage extends StatelessWidget {
  const OwnerHomePage({
    super.key,
    required this.ownerId,
    this.stream,
    this.onSignOut,
    this.onAdd,
  });
  final String ownerId;
  final Stream<List<Property>>? stream;
  final VoidCallback? onSignOut, onAdd;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('عقاراتي'),
          Text(
            'حساب مالك • عقاراتك المرفوعة فقط',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'تسجيل الخروج',
          icon: const Icon(Icons.logout),
          onPressed:
              onSignOut ??
              () async {
                await FirebaseAuth.instance.signOut();
              },
        ),
      ],
    ),
    body: OwnerPropertiesList(ownerId: ownerId, stream: stream),
    floatingActionButton: FloatingActionButton.extended(
      backgroundColor: const Color(0xFF174C3C),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_home_work_outlined),
      label: const Text('أضف عقارك'),
      onPressed:
          onAdd ??
          () async {
            final added = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const AddPropertyPage()),
            );
            if (added == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نشر عقارك بنجاح')),
              );
            }
          },
    ),
  );
}
