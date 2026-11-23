enum AccountRole {
  owner('owner', 'مالك'),
  consumer('consumer', 'مستهلك');

  const AccountRole(this.value, this.label);
  final String value;
  final String label;

  static AccountRole? parse(Object? value) {
    for (final role in values) {
      if (role.value == value) return role;
    }
    return null;
  }
}

String? validatePhone(String? value) {
  if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value?.trim() ?? '')) {
    return 'اكتب رقم موبايل مصري صحيحًا من 11 رقمًا';
  }
  return null;
}
