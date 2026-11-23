import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_app/services/demo_properties.dart';

void main() {
  test('eight varied fixtures cover rent sale and four governorates', () {
    expect(DemoProperties.fixtures, hasLength(8));
    expect(DemoProperties.fixtures.map((f) => f['mode']).toSet(), {
      'rent',
      'sale',
    });
    expect(DemoProperties.fixtures.map((f) => f['governorate']).toSet(), {
      'القاهرة',
      'الجيزة',
      'الإسكندرية',
      'الأقصر',
    });
    expect(
      DemoProperties.fixtures.map((f) => f['price']).toSet().length,
      greaterThan(5),
    );
  });
  test('fixture IDs are distinct stable and owner scoped', () {
    final ids = DemoProperties.fixtures
        .map((f) => DemoProperties.fixtureId('owner', f))
        .toSet();
    expect(ids, hasLength(8));
    expect(
      ids.intersection(
        DemoProperties.fixtures
            .map((f) => DemoProperties.fixtureId('other', f))
            .toSet(),
      ),
      isEmpty,
    );
  });
  test('demo cleanup excludes real listings and another owners fixtures', () {
    expect(
      DemoProperties.canRemove({'ownerId': 'owner', 'isDemo': true}, 'owner'),
      isTrue,
    );
    expect(DemoProperties.canRemove({'ownerId': 'owner'}, 'owner'), isFalse);
    expect(
      DemoProperties.canRemove({'ownerId': 'owner', 'isDemo': false}, 'owner'),
      isFalse,
    );
    expect(
      DemoProperties.canRemove({'ownerId': 'other', 'isDemo': true}, 'owner'),
      isFalse,
    );
  });
}
