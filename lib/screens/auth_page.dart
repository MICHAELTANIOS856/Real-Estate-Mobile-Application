import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/account_role.dart';
import '../services/account_service.dart';
import '../widgets/role_picker.dart';

/// Email/password sign-in and registration.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.closeOnSuccess = true});

  final bool closeOnSuccess;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmController = TextEditingController();
  AccountRole? selectedRole;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoginMode = true;
  bool isSubmitting = false;
  bool obscurePassword = true;
  bool isResettingPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _confirmController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (isSubmitting || isResettingPassword) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      if (isLoginMode) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
        try {
          await AccountService.createProfile(
            name: _nameController.text,
            phone: _phoneController.text,
            role: selectedRole!,
          );
        } catch (_) {
          // Auth and Firestore are separate services. Keep the signed-in user;
          // the start screen resumes profile setup instead of creating twice.
          if (!mounted) return;
          if (widget.closeOnSuccess) Navigator.pop(context, true);
          return;
        }
        if (credential.user == null) throw StateError('Missing user');
      }

      if (!mounted) return;
      if (widget.closeOnSuccess) Navigator.pop(context, true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_messageForCode(error.code))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ غير متوقع، حاول مرة أخرى')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> resetPassword() async {
    if (isSubmitting || isResettingPassword) return;
    final email = _emailController.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اكتب بريدًا إلكترونيًا صحيحًا في خانة البريد أولًا'),
        ),
      );
      return;
    }
    setState(() => isResettingPassword = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لو البريد مسجل، هيوصلك رابط لإعادة تعيين كلمة المرور. راجع البريد والرسائل غير المرغوب فيها',
          ),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      // Avoid disclosing which emails have an account (enumeration protection).
      final message = error.code == 'user-not-found'
          ? 'لو البريد مسجل، هيوصلك رابط لإعادة تعيين كلمة المرور. راجع البريد والرسائل غير المرغوب فيها'
          : _messageForCode(error.code);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر إرسال رابط إعادة التعيين، حاول مرة أخرى'),
        ),
      );
    } finally {
      if (mounted) setState(() => isResettingPassword = false);
    }
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد مسجل بالفعل، جرّب تسجيل الدخول';
      case 'weak-password':
        return 'كلمة المرور ضعيفة، استخدم 6 أحرف على الأقل';
      case 'invalid-email':
        return 'اكتب بريدًا إلكترونيًا صحيحًا';
      case 'network-request-failed':
        return 'تعذر الاتصال. تأكد من اتصال الإنترنت وحاول مرة أخرى';
      case 'too-many-requests':
        return 'محاولات كثيرة، انتظر قليلًا ثم حاول مرة أخرى';
      default:
        return 'تعذر إتمام العملية، حاول مرة أخرى';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EF),
      appBar: AppBar(
        title: Text(isLoginMode ? 'تسجيل الدخول' : 'إنشاء حساب'),
        backgroundColor: const Color(0xFFF6F4EF),
        foregroundColor: const Color(0xFF20302A),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFF174C3C),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.home_work_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isLoginMode ? 'أهلًا بعودتك' : 'انضم إلى عقارك',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF20302A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isLoginMode
                      ? 'سجّل الدخول إلى حسابك'
                      : 'اختر نوع حسابك وأكمل بياناتك',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 26),
                if (!isLoginMode) ...[
                  RolePicker(
                    value: selectedRole,
                    onChanged: (role) => setState(() => selectedRole = role),
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
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  textDirection: TextDirection.ltr,
                  decoration: _inputDecoration(
                    label: 'البريد الإلكتروني',
                    icon: Icons.mail_outline,
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) {
                      return 'اكتب بريدك الإلكتروني';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email)) {
                      return 'اكتب بريدًا إلكترونيًا صحيحًا';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: obscurePassword,
                  textDirection: TextDirection.ltr,
                  decoration:
                      _inputDecoration(
                        label: 'كلمة المرور',
                        icon: Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                  validator: (value) {
                    final password = value ?? '';
                    if (password.isEmpty) {
                      return 'اكتب كلمة المرور';
                    }
                    if (!isLoginMode && password.length < 6) {
                      return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
                    }
                    return null;
                  },
                ),
                if (isLoginMode)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: isSubmitting || isResettingPassword
                          ? null
                          : resetPassword,
                      child: Text(
                        isResettingPassword
                            ? 'جاري إرسال الرابط...'
                            : 'نسيت كلمة المرور؟',
                      ),
                    ),
                  ),
                if (!isLoginMode) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: obscurePassword,
                    textDirection: TextDirection.ltr,
                    decoration: _inputDecoration(
                      label: 'تأكيد كلمة المرور',
                      icon: Icons.lock_outline,
                    ),
                    validator: (value) =>
                        value == _passwordController.text &&
                            (value?.isNotEmpty ?? false)
                        ? null
                        : 'كلمتا المرور غير متطابقتين',
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    decoration: _inputDecoration(
                      label: 'رقم الموبايل',
                      icon: Icons.phone_outlined,
                    ),
                    validator: validatePhone,
                  ),
                ],
                const SizedBox(height: 26),
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
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isLoginMode ? 'تسجيل الدخول' : 'إنشاء الحساب',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          setState(() {
                            isLoginMode = !isLoginMode;
                          });
                        },
                  child: Text(
                    isLoginMode
                        ? 'ليس لديك حساب؟ أنشئ حسابًا جديدًا'
                        : 'لديك حساب بالفعل؟ سجّل الدخول',
                    style: const TextStyle(
                      color: Color(0xFF268064),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
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
