import 'package:flutter/material.dart';

import '../models/property.dart';
import 'viewing_request_page.dart';

class PropertyDetailsPage extends StatefulWidget {
  const PropertyDetailsPage({super.key, required this.property});

  final Property property;

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  bool isFavorite = false;

  String formatPrice(int price) {
    final digits = price.toString().split('').reversed.toList();
    final groups = <String>[];

    for (var i = 0; i < digits.length; i += 3) {
      final end = (i + 3 < digits.length) ? i + 3 : digits.length;
      groups.add(digits.sublist(i, end).reversed.join());
    }

    return groups.reversed.join(',');
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final isForRent = property.mode == ListingMode.rent;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF174C3C),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                property.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE5E1D8),
                    child: const Icon(
                      Icons.home_work_outlined,
                      size: 80,
                      color: Color(0xFF174C3C),
                    ),
                  );
                },
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'إضافة للمفضلة',
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent : Colors.white,
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20302A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF268064),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${property.location}، ${property.governorate}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${formatPrice(property.price)} جنيه'
                          '${isForRent ? ' / شهريًا' : ''}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF174C3C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isForRent ? 'للإيجار' : 'للبيع',
                          style: const TextStyle(
                            color: Color(0xFF268064),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تفاصيل العقار',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20302A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _DetailChip(
                        icon: Icons.king_bed_outlined,
                        label: '${property.bedrooms} غرف نوم',
                      ),
                      _DetailChip(
                        icon: Icons.bathtub_outlined,
                        label: '${property.bathrooms} حمام',
                      ),
                      _DetailChip(
                        icon: Icons.square_foot,
                        label: '${property.area} متر مربع',
                      ),
                      _DetailChip(
                        icon: Icons.apartment_outlined,
                        label: property.type,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'آخر تأكيد للتوفر',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20302A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    property.lastConfirmed,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewingRequestPage(property: property),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF174C3C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text(
              'طلب معاينة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: const Color(0xFF268064)),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF20302A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
