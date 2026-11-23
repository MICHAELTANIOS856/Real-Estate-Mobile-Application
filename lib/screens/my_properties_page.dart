import 'dart:async';

import 'package:flutter/material.dart';

import '../models/property.dart';
import '../services/properties_service.dart';
import 'property_details_page.dart';

class OwnerPropertiesList extends StatefulWidget {
  const OwnerPropertiesList({super.key, required this.ownerId, this.stream});
  final Stream<List<Property>>? stream;
  final String ownerId;
  @override
  State<OwnerPropertiesList> createState() => _OwnerPropertiesState();
}

class _OwnerPropertiesState extends State<OwnerPropertiesList> {
  late Stream<List<Property>> properties;
  Timer? refresh;
  @override
  void initState() {
    super.initState();
    refresh = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
    properties =
        widget.stream ?? PropertiesService.watchOwnerProperties(widget.ownerId);
  }

  @override
  void didUpdateWidget(covariant OwnerPropertiesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId ||
        oldWidget.stream != widget.stream) {
      properties =
          widget.stream ??
          PropertiesService.watchOwnerProperties(widget.ownerId);
    }
  }

  @override
  void dispose() {
    refresh?.cancel();
    super.dispose();
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
        final listings = snapshot.data!
            .where((property) => property.ownerId == widget.ownerId)
            .toList();
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
                          builder: (_) => PropertyDetailsPage(
                            property: property,
                            allowViewingRequest: false,
                          ),
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
