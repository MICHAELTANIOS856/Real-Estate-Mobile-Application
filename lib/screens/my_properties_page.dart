import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/property.dart';
import '../services/properties_service.dart';
import 'property_details_page.dart';

/// Owner-only list. Public discovery uses a separate available-listings query.
class MyPropertiesPage extends StatelessWidget {
  const MyPropertiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, auth) {
        final owner = auth.data;
        return Scaffold(
          appBar: AppBar(title: const Text('عقاراتي')),
          body: owner == null
              ? const Center(child: Text('سجّل الدخول لعرض عقاراتك'))
              : _OwnerProperties(ownerId: owner.uid),
        );
      },
    );
  }
}

class _OwnerProperties extends StatefulWidget {
  const _OwnerProperties({required this.ownerId});
  final String ownerId;
  @override
  State<_OwnerProperties> createState() => _OwnerPropertiesState();
}

class _OwnerPropertiesState extends State<_OwnerProperties> {
  late Stream<List<Property>> properties;
  @override
  void initState() {
    super.initState();
    properties = PropertiesService.watchOwnerProperties(widget.ownerId);
  }

  @override
  void didUpdateWidget(covariant _OwnerProperties oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId) {
      properties = PropertiesService.watchOwnerProperties(widget.ownerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Property>>(
      stream: properties,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('تعذر تحميل عقاراتك، حاول مرة أخرى'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final listings = snapshot.data!;
        if (listings.isEmpty) {
          return const Center(child: Text('لم تضف أي عقارات بعد'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: listings.length,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final property = listings[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home_work_outlined),
                      title: Text(property.title),
                      subtitle: Text(
                        '${property.location}، ${property.governorate}\nتاريخ النشر: ${property.publishedDate}',
                      ),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PropertyDetailsPage(property: property),
                        ),
                      ),
                    ),
                    if (property.renewalNotice != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          property.renewalNotice!,
                          style: TextStyle(
                            color: property.isExpired
                                ? Colors.red.shade800
                                : Colors.orange.shade900,
                          ),
                        ),
                      ),
                    TextButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('العقار ما زال متاحًا، تجديد 7 أيام'),
                      onPressed: () async {
                        try {
                          await PropertiesService.renewProperty(property);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم تجديد الإعلان لمدة 7 أيام'),
                            ),
                          );
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تعذر التجديد، حاول مرة أخرى'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
