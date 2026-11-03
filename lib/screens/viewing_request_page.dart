import 'package:flutter/material.dart';

import '../models/property.dart';

class ViewingRequestPage extends StatefulWidget {
  const ViewingRequestPage({super.key, required this.property});

  final Property property;

  @override
  State<ViewingRequestPage> createState() => _ViewingRequestPageState();
}

class _ViewingRequestPageState extends State<ViewingRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool requestSent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> chooseDate() async {
    final today = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 1),
      helpText: 'اختر تاريخ المعاينة',
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> chooseTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'اختر وقت المعاينة',
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void submitRequest() {
    final formIsValid = _formKey.currentState!.validate();

    if (!formIsValid) return;

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر تاريخ ووقت المعاينة أولًا')),
      );
      return;
    }

    setState(() {
      requestSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تسجيل طلب المعاينة بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EF),
      appBar: AppBar(
        title: const Text('طلب معاينة'),
        backgroundColor: const Color(0xFFF6F4EF),
        foregroundColor: const Color(0xFF20302A),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'العقار المطلوب',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      property.title,
                      style: const TextStyle(
                        color: Color(0xFF20302A),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${property.location}، ${property.governorate}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'بيانات التواصل',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20302A),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'الاسم',
                  icon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'اكتب اسمك';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(
                  label: 'رقم الهاتف',
                  icon: Icons.phone_outlined,
                ),
                validator: (value) {
                  final phone = value?.trim() ?? '';

                  if (phone.isEmpty) {
                    return 'اكتب رقم الهاتف';
                  }

                  if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(phone)) {
                    return 'اكتب رقم هاتف مصري صحيحًا، مثل 01012345678';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'موعد المعاينة',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20302A),
                ),
              ),
              const SizedBox(height: 14),
              _PickerTile(
                icon: Icons.calendar_month_outlined,
                title: selectedDate == null
                    ? 'اختر اليوم'
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                onTap: chooseDate,
              ),
              const SizedBox(height: 12),
              _PickerTile(
                icon: Icons.access_time_rounded,
                title: selectedTime == null
                    ? 'اختر الوقت'
                    : selectedTime!.format(context),
                onTap: chooseTime,
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: requestSent ? null : submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF174C3C),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF268064),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    requestSent ? 'تم إرسال الطلب' : 'إرسال طلب المعاينة',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE7E4DC)),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF268064)),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
              const Icon(Icons.chevron_left, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}
