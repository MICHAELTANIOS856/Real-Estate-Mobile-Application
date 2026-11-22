import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Email/password sign-in and registration.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoginMode = true;
  bool isSubmitting = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (isSubmitting) return;
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
        await credential.user?.updateDisplayName(_nameController.text.trim());
      }

      if (!mounted) return;
      Navigator.pop(context, true);
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
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
                    ? 'سجّل الدخول لنشر عقارك وطلب المعاينة'
                    : 'أنشئ حسابك لنشر عقاراتك',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 26),
              if (!isLoginMode) ...[
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
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
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
