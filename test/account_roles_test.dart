import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/models/account_role.dart';
import 'package:real_estate_app/screens/account_gate.dart';
import 'package:real_estate_app/screens/owner_home_page.dart';

import 'renewal_test.dart' show listing;

void main() {
  test('only known roles are accepted and Egyptian phone is validated', () {
    expect(AccountRole.parse('owner'), AccountRole.owner);
    expect(AccountRole.parse('consumer'), AccountRole.consumer);
    expect(AccountRole.parse(null), isNull);
    expect(AccountRole.parse('admin'), isNull);
    expect(validatePhone('01012345678'), isNull);
    expect(validatePhone('01912345678'), isNotNull);
    expect(validatePhone(''), isNotNull);
  });
  for (final role in <AccountRole?>[
    AccountRole.owner,
    AccountRole.consumer,
    null,
  ]) {
    testWidgets('persisted role $role chooses the right home', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RoleGate(
            roleStream: Stream.value(role),
            owner: const Text('owner home'),
            consumer: const Text('consumer home'),
            incomplete: const Text('choose role'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          role == AccountRole.owner
              ? 'owner home'
              : role == AccountRole.consumer
              ? 'consumer home'
              : 'choose role',
        ),
        findsOneWidget,
      );
    });
  }
  testWidgets(
    'owner start screen has own listings, upload and renewal, no search or modes',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OwnerHomePage(
            ownerId: 'owner',
            stream: Stream.value([listing(), listing(owner: 'another')]),
            onSignOut: () {},
            onAdd: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('owner property'), findsOneWidget);
      expect(find.text('another property'), findsNothing);
      expect(find.text('أضف عقارك'), findsOneWidget);
      expect(find.textContaining('تجديد 7 أيام'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(ChoiceChip), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
