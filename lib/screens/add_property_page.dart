import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/property.dart';
import '../services/properties_service.dart';

/// Owner form for publishing a new property listing.
class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  static const List<String> governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'الشرقية',
    'الغربية',
    'المنوفية',
    'القليوبية',
    'البحيرة',
    'كفر الشيخ',
    'دمياط',
    'بورسعيد',
    'الإسماعيلية',
    'السويس',
    'الفيوم',
    'بني سويف',
    'المنيا',
    'أسيوط',
    'سوهاج',
    'قنا',
    'الأقصر',
    'أسوان',
    'البحر الأحمر',
    'مطروح',
    'شمال سيناء',
    'جنوب سيناء',
    'الوادي الجديد',
  ];

  static const List<String> propertyTypes = [
    'شقة',
    'فيلا',
    'دوبلكس',
    'محل',
    'مكتب',
    'أرض',
  ];

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  final Map<String, String> _uploadedUrls = {};

  ListingMode selectedMode = ListingMode.rent;
  String selectedType = AddPropertyPage.propertyTypes.first;
  String selectedGovernorate = AddPropertyPage.governorates.first;
  bool isSubmitting = false;
  String? uploadProgress;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(
        maxWidth: 1600,
        imageQuality: 70,
      );
      if (!mounted || picked.isEmpty) return;
      if (_images.length + picked.length > 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الحد الأقصى 10 صور للعقار')),
        );
        return;
      }
      for (final image in picked) {
        if (await image.length() >= 10 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('اختر صورًا أصغر من 10 ميجابايت')),
          );
          return;
        }
      }
      if (!mounted) return;

      setState(() {
        _images.addAll(picked);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر اختيار الصور، حاول مرة أخرى')),
      );
    }
  }

  void removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  int? _parsePositiveInt(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0 || parsed > 1000000000000) return null;
    return parsed;
  }

  Future<void> submit() async {
    if (isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف صورة واحدة على الأقل للعقار')),
      );
      return;
    }

    final owner = FirebaseAuth.instance.currentUser;
    if (owner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سجّل الدخول أولًا قبل نشر العقار')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
      uploadProgress = 'جاري رفع الصور...';
    });

    try {
      final imageUrls = <String>[];
      for (var i = 0; i < _images.length; i++) {
        if (mounted) {
          setState(() {
            uploadProgress = 'جاري رفع الصور... ${i + 1}/${_images.length}';
          });
        }
        final url =
            _uploadedUrls[_images[i].path] ??
            await PropertiesService.uploadPropertyImage(
              ownerId: owner.uid,
              image: _images[i],
              index: i,
            );
        _uploadedUrls[_images[i].path] = url;
        imageUrls.add(url);
      }

      if (mounted) {
        setState(() {
          uploadProgress = 'جاري حفظ العقار...';
        });
      }

      await PropertiesService.addProperty(
        title: _titleController.text.trim(),
        type: selectedType,
        governorate: selectedGovernorate,
        location: _locationController.text.trim(),
        mode: selectedMode,
        price: _parsePositiveInt(_priceController.text)!,
        bedrooms: int.parse(_bedroomsController.text.trim()),
        bathrooms: int.parse(_bathroomsController.text.trim()),
        area: _parsePositiveInt(_areaController.text)!,
        description: _descriptionController.text.trim(),
        imageUrls: imageUrls,
        ownerId: owner.uid,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseException catch (error) {
      debugPrint('Firebase error while publishing: ${error.code}');
      if (!mounted) return;
      final message =
          error.code == 'permission-denied' || error.code == 'unauthorized'
          ? 'قواعد قاعدة البيانات لا تسمح بالنشر بعد، راجع إعدادات Firebase'
          : 'تعذر نشر العقار. تأكد من اتصال الإنترنت وحاول مرة أخرى';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ غير متوقع أثناء نشر العقار')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
          uploadProgress = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EF),
      appBar: AppBar(
        title: const Text('أضف عقارك'),
        backgroundColor: const Color(0xFFF6F4EF),
        foregroundColor: const Color(0xFF20302A),
      ),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: isSubmitting,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionTitle('صور العقار'),
                const SizedBox(height: 12),
                _buildImagePicker(),
                const SizedBox(height: 24),
                _buildSectionTitle('نوع الإعلان'),
                const SizedBox(height: 12),
                _buildModeSelector(),
                const SizedBox(height: 24),
                _buildSectionTitle('بيانات العقار'),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'عنوان الإعلان',
                    icon: Icons.title_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اكتب عنوان الإعلان';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  isExpanded: true,
                  decoration: _inputDecoration(
                    label: 'نوع العقار',
                    icon: Icons.apartment_outlined,
                  ),
                  items: AddPropertyPage.propertyTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedGovernorate,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          label: 'المحافظة',
                          icon: Icons.map_outlined,
                        ),
                        items: AddPropertyPage.governorates
                            .map(
                              (governorate) => DropdownMenuItem(
                                value: governorate,
                                child: Text(governorate),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            selectedGovernorate = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: TextFormField(
                        controller: _locationController,
                        maxLength: 200,
                        decoration: _inputDecoration(
                          label: 'المنطقة / الحي',
                          icon: Icons.location_on_outlined,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'اكتب المنطقة';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textDirection: TextDirection.ltr,
                  decoration: _inputDecoration(
                    label: selectedMode == ListingMode.rent
                        ? 'السعر الشهري (ج.م)'
                        : 'السعر (ج.م)',
                    icon: Icons.payments_outlined,
                  ),
                  validator: (value) {
                    if (value == null || _parsePositiveInt(value) == null) {
                      return 'اكتب سعرًا صحيحًا';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: _buildNumberField(
                        controller: _bedroomsController,
                        label: 'غرف النوم',
                        icon: Icons.king_bed_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: _buildNumberField(
                        controller: _bathroomsController,
                        label: 'الحمامات',
                        icon: Icons.bathtub_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: _buildNumberField(
                        controller: _areaController,
                        label: 'المساحة م²',
                        icon: Icons.square_foot,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  maxLength: 5000,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    label: 'وصف العقار (اختياري)',
                    icon: Icons.notes_rounded,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF174C3C),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF268064),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 21,
                                height: 21,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(uploadProgress ?? 'جاري النشر...'),
                            ],
                          )
                        : const Text(
                            'نشر العقار',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Color(0xFF20302A),
      ),
    );
  }

  Widget _buildImagePicker() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: isSubmitting ? null : pickImages,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE7E4DC)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Color(0xFF268064),
                        size: 30,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'أضف صورًا',
                        style: TextStyle(
                          color: Color(0xFF268064),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FutureBuilder(
                  future: _images[index].readAsBytes(),
                  builder: (context, snapshot) => snapshot.hasData
                      ? Image.memory(
                          snapshot.data!,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(width: 110, height: 110),
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: isSubmitting ? null : () => removeImage(index),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
        onTap: isSubmitting
            ? null
            : () {
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

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textDirection: TextDirection.ltr,
      decoration: _inputDecoration(label: label, icon: icon),
      validator: (value) {
        final number = int.tryParse(value?.trim() ?? '');
        final isArea = controller == _areaController;
        if (number == null ||
            number < (isArea ? 1 : 0) ||
            number > (isArea ? 1000000000 : 100)) {
          return isArea ? 'اكتب مساحة صحيحة' : 'اكتب رقمًا من 0 إلى 100';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF268064)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE7E4DC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF268064), width: 1.5),
      ),
    );
  }
}
