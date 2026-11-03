import 'package:flutter/material.dart';

import 'models/property.dart';
import 'screens/property_details_page.dart';

void main() {
  runApp(const RealEstateApp());
}

class RealEstateApp extends StatelessWidget {
  const RealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'عقارك',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F4EF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF174C3C)),
      ),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ListingMode selectedMode = ListingMode.rent;
  String selectedGovernorate = 'الكل';
  String searchText = '';

  final Set<String> favoriteIds = {};

  final List<String> governorates = const [
    'الكل',
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'المنصورة',
    'أسيوط',
  ];

  final List<Property> properties = const [
    Property(
      id: '1',
      title: 'شقة عصرية بإطلالة مميزة',
      type: 'شقة',
      location: 'التجمع الخامس',
      governorate: 'القاهرة',
      mode: ListingMode.rent,
      price: 12000,
      bedrooms: 3,
      bathrooms: 2,
      area: 160,
      imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=1200&q=85',
      lastConfirmed: 'اليوم',
    ),
    Property(
      id: '2',
      title: 'شقة واسعة بالقرب من الخدمات',
      type: 'شقة',
      location: 'الشيخ زايد',
      governorate: 'الجيزة',
      mode: ListingMode.rent,
      price: 18000,
      bedrooms: 3,
      bathrooms: 2,
      area: 190,
      imageUrl: 'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?auto=format&fit=crop&w=1200&q=85',
      lastConfirmed: 'منذ يومين',
    ),
    Property(
      id: '3',
      title: 'فيلا مميزة بحديقة خاصة',
      type: 'فيلا',
      location: 'الساحل الشمالي',
      governorate: 'الإسكندرية',
      mode: ListingMode.rent,
      price: 25000,
      bedrooms: 4,
      bathrooms: 3,
      area: 280,
      imageUrl: 'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?auto=format&fit=crop&w=1200&q=85',
      lastConfirmed: 'اليوم',
    ),
    Property(
      id: '4',
      title: 'شقة للبيع بتصميم أنيق',
      type: 'شقة',
      location: 'مدينة نصر',
      governorate: 'القاهرة',
      mode: ListingMode.sale,
      price: 2400000,
      bedrooms: 3,
      bathrooms: 2,
      area: 155,
      imageUrl: 'https://images.unsplash.com/photo-1600607687644-c7171b42498f?auto=format&fit=crop&w=1200&q=85',
      lastConfirmed: 'منذ يوم',
    ),
  ];

  List<Property> get filteredProperties {
    return properties.where((property) {
      final matchesMode = property.mode == selectedMode;

      final matchesGovernorate =
          selectedGovernorate == 'الكل' ||
          property.governorate == selectedGovernorate;

      final normalizedSearch = searchText.trim().toLowerCase();
      final matchesSearch =
          normalizedSearch.isEmpty ||
          property.title.toLowerCase().contains(normalizedSearch) ||
          property.location.toLowerCase().contains(normalizedSearch) ||
          property.governorate.toLowerCase().contains(normalizedSearch) ||
          property.type.toLowerCase().contains(normalizedSearch);

      return matchesMode && matchesGovernorate && matchesSearch;
    }).toList();
  }

  String formatPrice(int price) {
    final digits = price.toString().split('').reversed.toList();
    final groups = <String>[];

    for (var i = 0; i < digits.length; i += 3) {
      final end = (i + 3 < digits.length) ? i + 3 : digits.length;
      groups.add(digits.sublist(i, end).reversed.join());
    }

    return groups.reversed.join(',');
  }

  void toggleFavorite(String propertyId) {
    setState(() {
      if (favoriteIds.contains(propertyId)) {
        favoriteIds.remove(propertyId);
      } else {
        favoriteIds.add(propertyId);
      }
    });
  }

  void openPropertyDetails(Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(property: property),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleProperties = filteredProperties;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: _buildHeader(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: _buildHeroBanner(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildSearchField(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: _buildModeSelector(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: _buildSectionHeader(visibleProperties.length),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 42,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: governorates.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final governorate = governorates[index];
                    final isSelected = governorate == selectedGovernorate;

                    return ChoiceChip(
                      label: Text(governorate),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: const Color(0xFF174C3C),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF174C3C)
                            : const Color(0xFFE7E4DC),
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedGovernorate = governorate;
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            if (visibleProperties.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final property = visibleProperties[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _buildPropertyCard(property),
                    );
                  }, childCount: visibleProperties.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF174C3C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.home_work_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'عقارك',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20302A),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'بيتك القادم يبدأ من هنا',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('الإشعارات ستتوفر قريبًا')),
            );
          },
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF174C3C),
            size: 27,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 180,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF174C3C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -35,
            top: -55,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            left: 65,
            bottom: -95,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF0A45D).withValues(alpha: 0.18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ابحث بسهولة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                const Text(
                  'المكان المناسب\nلحياتك الجديدة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اكتشف عقارات في محافظات مصر',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 22,
            bottom: 20,
            child: Icon(
              Icons.apartment_rounded,
              color: Color(0xFFF0A45D),
              size: 75,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      textDirection: TextDirection.rtl,
      onChanged: (value) {
        setState(() {
          searchText = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'ابحث عن منطقة أو نوع العقار',
        hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF268064)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 17),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFFECE9E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xFF268064), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE8E1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildModeButton(
            label: 'للإيجار',
            mode: ListingMode.rent,
            icon: Icons.key_outlined,
          ),
          _buildModeButton(
            label: 'للبيع',
            mode: ListingMode.sale,
            icon: Icons.sell_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required ListingMode mode,
    required IconData icon,
  }) {
    final isSelected = selectedMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMode = mode;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF174C3C) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: isSelected ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(int resultCount) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'عقارات تناسبك',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF20302A),
            ),
          ),
        ),
        Text(
          '$resultCount عقار',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(Property property) {
    final isForRent = property.mode == ListingMode.rent;
    final isFavorite = favoriteIds.contains(property.id);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openPropertyDetails(property),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 205,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    property.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE5E1D8),
                        child: const Icon(
                          Icons.home_work_outlined,
                          size: 60,
                          color: Color(0xFF174C3C),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 13,
                    right: 13,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isForRent ? 'للإيجار' : 'للبيع',
                        style: const TextStyle(
                          color: Color(0xFF174C3C),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 9,
                    left: 9,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => toggleFavorite(property.id),
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? Colors.redAccent
                              : const Color(0xFF20302A),
                          size: 21,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 13,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF174C3C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'متاح',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20302A),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 17,
                        color: Color(0xFF268064),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.location}، ${property.governorate}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _PropertyFeature(
                        icon: Icons.king_bed_outlined,
                        label: '${property.bedrooms}',
                      ),
                      const SizedBox(width: 14),
                      _PropertyFeature(
                        icon: Icons.bathtub_outlined,
                        label: '${property.bathrooms}',
                      ),
                      const SizedBox(width: 14),
                      _PropertyFeature(
                        icon: Icons.square_foot,
                        label: '${property.area} م²',
                      ),
                      const Spacer(),
                      Text(
                        '${formatPrice(property.price)} ج.م'
                        '${isForRent ? ' / شهر' : ''}',
                        style: const TextStyle(
                          color: Color(0xFF174C3C),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyFeature extends StatelessWidget {
  const _PropertyFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF268064)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: const BoxDecoration(
                color: Color(0xFFE5EEE9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 40,
                color: Color(0xFF174C3C),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد عقارات مطابقة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF20302A),
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'جرّب تغيير نوع البحث أو المنطقة',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
