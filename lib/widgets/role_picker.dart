import 'package:flutter/material.dart';

import '../models/account_role.dart';

class RolePicker extends StatelessWidget {
  const RolePicker({super.key, required this.value, required this.onChanged});
  final AccountRole? value;
  final ValueChanged<AccountRole> onChanged;

  @override
  Widget build(BuildContext context) => FormField<AccountRole>(
    initialValue: value,
    validator: (_) => value == null ? 'اختر نوع الحساب' : null,
    builder: (field) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('نوع الحساب', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: AccountRole.values
              .map(
                (role) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      avatar: Icon(
                        role == AccountRole.owner
                            ? Icons.home_work_outlined
                            : Icons.search,
                      ),
                      label: Text(role.label),
                      selected: value == role,
                      onSelected: (_) {
                        field.didChange(role);
                        onChanged(role);
                      },
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 6),
        Text(
          value == AccountRole.owner
              ? 'انشر عقاراتك وتابع تجديد إعلاناتك'
              : value == AccountRole.consumer
              ? 'تصفّح العقارات واطلب معاينة'
              : 'مالك لنشر العقارات، أو مستهلك للبحث عن عقار',
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        if (field.hasError)
          Text(
            field.errorText!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
  );
}
