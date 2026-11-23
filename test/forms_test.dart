import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/screens/auth_page.dart';
import 'package:real_estate_app/screens/add_property_page.dart';

Widget host(Widget page) => MaterialApp(
  builder: (context, child) =>
      Directionality(textDirection: TextDirection.rtl, child: child!),
  home: page,
);

void main() {
  testWidgets('forgot password requires a valid email without a password', (
    tester,
  ) async {
    await tester.pumpWidget(host(const AuthPage()));
    await tester.tap(find.text('نسيت كلمة المرور؟'));
    await tester.pumpAndSettle();
    expect(
      find.text('اكتب بريدًا إلكترونيًا صحيحًا في خانة البريد أولًا'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('sign-in validates missing email and password locally', (
    tester,
  ) async {
    await tester.pumpWidget(host(const AuthPage()));
    await tester.tap(find.widgetWithText(ElevatedButton, 'تسجيل الدخول'));
    await tester.pumpAndSettle();
    expect(find.text('اكتب بريدك الإلكتروني'), findsOneWidget);
    expect(find.text('اكتب كلمة المرور'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('registration validates name, email and password strength', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(host(const AuthPage()));
    await tester.tap(find.text('ليس لديك حساب؟ أنشئ حسابًا جديدًا'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(5));
    await tester.enterText(fields.at(1), 'invalid');
    await tester.enterText(fields.at(2), '123');
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'إنشاء الحساب'),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'إنشاء الحساب'));
    await tester.pumpAndSettle();
    expect(find.text('اختر نوع الحساب'), findsOneWidget);
    expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
    expect(
      find.text('اكتب رقم موبايل مصري صحيحًا من 11 رقمًا'),
      findsOneWidget,
    );
    expect(find.text('اكتب اسمك'), findsOneWidget);
    expect(find.text('اكتب بريدًا إلكترونيًا صحيحًا'), findsOneWidget);
    expect(find.text('كلمة المرور يجب ألا تقل عن 6 أحرف'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('owner form keeps all field labels readable at phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(const AddPropertyPage()));
    await tester.pumpAndSettle();
    expect(find.text('أضف عقارك'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView).first, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, 'نشر العقار'),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'نشر العقار'));
    await tester.pumpAndSettle();
    expect(find.text('اكتب سعرًا صحيحًا'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
