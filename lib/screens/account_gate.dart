import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/account_role.dart';
import '../services/account_service.dart';
import '../widgets/role_picker.dart';
import 'owner_home_page.dart';
import 'auth_page.dart';

/// Re-evaluates both sign-in and persisted role, including after app restart.
class AccountGate extends StatelessWidget {
  const AccountGate({super.key, this.authStream});
  final Stream<User?>? authStream;
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: authStream ?? FirebaseAuth.instance.authStateChanges(),
    initialData: authStream == null ? FirebaseAuth.instance.currentUser : null,
    builder: (context, auth) {
      if (auth.data == null) return const AuthPage(closeOnSuccess: false);
      final user = auth.data!;
      return RoleGate(
        key: ValueKey(user.uid),
        roleStream: AccountService.watchRole(user.uid),
        owner: OwnerHomePage(ownerId: user.uid),
        consumer: const HomePage(),
        incomplete: const CompleteProfilePage(),
      );
    },
  );
}

/// Separate from Firebase for deterministic role-routing tests.
class RoleGate extends StatelessWidget {
  const RoleGate({
    super.key,
    required this.roleStream,
    required this.owner,
    required this.consumer,
    required this.incomplete,
  });
  final Stream<AccountRole?> roleStream;
  final Widget owner, consumer, incomplete;
  @override
  Widget build(BuildContext context) => StreamBuilder<AccountRole?>(
    stream: roleStream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'تعذر تحميل نوع الحساب. تحقق من الاتصال وقواعد Firestore ثم حاول مرة أخرى.',
                    ),
                  ),
                  TextButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text('تسجيل الخروج'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return switch (snapshot.data) {
        AccountRole.owner => owner,
        AccountRole.consumer => consumer,
        null => incomplete,
      };
    },
  );
}

/// Accounts made before roles existed choose once, never default to owner.
class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});
  @override
  State<CompleteProfilePage> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfilePage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(
    text: FirebaseAuth.instance.currentUser?.displayName ?? '',
  );
  final phone = TextEditingController();
  AccountRole? role;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('أكمل بيانات حسابك'),
      actions: [
        IconButton(
          onPressed: () => FirebaseAuth.instance.signOut(),
          icon: const Icon(Icons.logout),
          tooltip: 'تسجيل الخروج',
        ),
      ],
    ),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'اختر نوع حسابك مرة واحدة للمتابعة. لن يتم تغيير عقاراتك القديمة.',
          ),
          const SizedBox(height: 24),
          RolePicker(
            value: role,
            onChanged: (value) => setState(() => role = value),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: name,
            maxLength: 100,
            decoration: const InputDecoration(labelText: 'الاسم'),
            validator: (v) => (v?.trim().isEmpty ?? true) ? 'اكتب اسمك' : null,
          ),
          TextFormField(
            controller: phone,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(labelText: 'رقم الموبايل'),
            validator: validatePhone,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: saving
                ? null
                : () async {
                    if (!form.currentState!.validate()) return;
                    setState(() => saving = true);
                    try {
                      await AccountService.createProfile(
                        name: name.text,
                        phone: phone.text,
                        role: role!,
                      );
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تعذر حفظ الحساب. تحقق من الاتصال وقواعد Firestore وحاول مرة أخرى',
                            ),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => saving = false);
                    }
                  },
            child: Text(saving ? 'جاري الحفظ...' : 'حفظ ومتابعة'),
          ),
        ],
      ),
    ),
  );
}
