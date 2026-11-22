import 'package:cloud_firestore/cloud_firestore.dart';

enum ListingMode { rent, sale }

class Property {
  const Property({
    required this.id,
    required this.title,
    required this.type,
    required this.location,
    required this.governorate,
    required this.mode,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.imageUrl,
    required this.lastConfirmed,
    this.description = '',
    this.imageUrls = const [],
    this.ownerId,
    this.createdAt,
    this.lastConfirmedAt,
    this.expiresAt,
  });

  final String id;
  final String title;
  final String type;
  final String location;
  final String governorate;
  final ListingMode mode;
  final int price;
  final int bedrooms;
  final int bathrooms;
  final int area;
  final String imageUrl;
  final String lastConfirmed;
  final String description;
  final List<String> imageUrls;
  final String? ownerId;
  final DateTime? createdAt;
  final DateTime? lastConfirmedAt;
  final DateTime? expiresAt;
  bool get isExpired =>
      expiresAt == null || !expiresAt!.isAfter(DateTime.now());
  String? get renewalNotice {
    if (isExpired) return 'انتهت صلاحية الإعلان. جدّد التأكيد لإظهاره من جديد';
    if (lastConfirmedAt == null) return 'أكد توفر عقارك لتحديث صلاحية الإعلان';
    final days = DateTime.now().difference(lastConfirmedAt!).inDays;
    if (days >= 6) {
      return 'تنبيه أخير: يتبقى يوم أو أقل على انتهاء صلاحية الإعلان';
    }
    if (days >= 3) return 'مرّت 3 أيام. هل العقار ما زال متاحًا؟ جدّد التأكيد';
    return null;
  }

  String get publishedDate {
    if (createdAt == null) return 'جاري التحديث';
    final date = createdAt!.toLocal();
    return '${date.day}/${date.month}/${date.year}';
  }

  /// All photos of the property, falling back to the single cover image.
  List<String> get photos => imageUrls.isNotEmpty ? imageUrls : [imageUrl];

  factory Property.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};

    final photos =
        (data['imageUrls'] as List<dynamic>?)?.whereType<String>().toList() ??
        const <String>[];

    final createdAtTimestamp = data['createdAt'] as Timestamp?;

    return Property(
      id: doc.id,
      title: data['title'] as String? ?? '',
      type: data['type'] as String? ?? '',
      location: data['location'] as String? ?? '',
      governorate: data['governorate'] as String? ?? '',
      mode: data['mode'] == 'sale' ? ListingMode.sale : ListingMode.rent,
      price: (data['price'] as num?)?.toInt() ?? 0,
      bedrooms: (data['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (data['bathrooms'] as num?)?.toInt() ?? 0,
      area: (data['area'] as num?)?.toInt() ?? 0,
      imageUrl: photos.isNotEmpty ? photos.first : '',
      imageUrls: photos,
      lastConfirmed: formatLastConfirmed(
        (data['lastConfirmedAt'] ?? data['lastConfirmed']) as Timestamp?,
      ),
      description: data['description'] as String? ?? '',
      ownerId: data['ownerId'] as String?,
      createdAt: createdAtTimestamp?.toDate(),
      lastConfirmedAt: (data['lastConfirmedAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['lastConfirmedAt'] as Timestamp?)?.toDate().add(
        const Duration(days: 7),
      ),
    );
  }

  /// Renders a confirmation timestamp as short Arabic relative text.
  static String formatLastConfirmed(Timestamp? timestamp) {
    if (timestamp == null) return '';

    final difference = DateTime.now().difference(timestamp.toDate());
    if (difference.inHours < 24) return 'اليوم';

    final days = difference.inDays;
    if (days == 1) return 'منذ يوم';
    if (days == 2) return 'منذ يومين';
    if (days < 7) return 'منذ $days أيام';

    final weeks = days ~/ 7;
    if (weeks == 1) return 'منذ أسبوع';
    if (weeks < 5) return 'منذ $weeks أسابيع';

    final months = days ~/ 30;
    if (months <= 1) return 'منذ شهر';
    return 'منذ $months أشهر';
  }
}
