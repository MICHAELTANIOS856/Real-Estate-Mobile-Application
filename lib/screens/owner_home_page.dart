import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../services/demo_properties.dart';

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
      title: const Text('عقاراتي'),
      actions: [
        if (kDebugMode)
          PopupMenuButton<String>(
            tooltip: 'بيانات تجريبية',
            onSelected: (action) async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    action == 'create'
                        ? 'إضافة عقارين وهميين؟'
                        : 'حذف عقاراتك التجريبية؟',
                  ),
                  content: const Text(
                    'للاختبار فقط. لا يتم تغيير العقارات الحقيقية. طلبات المعاينة التجريبية تبقى كسجل اختبار.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('تأكيد'),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              try {
                if (action == 'create') {
                  await DemoProperties.create();
                } else {
                  await DemoProperties.remove();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديث العقارات التجريبية فقط'),
                    ),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تعذر تحديث التجربة. تأكد من قواعد Firestore والاتصال',
                      ),
                    ),
                  );
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'create',
                child: Text('إضافة عقارات تجريبية'),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Text('حذف عقاراتي التجريبية'),
              ),
            ],
          ),
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
