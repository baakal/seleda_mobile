import 'package:flutter_test/flutter_test.dart';

import 'package:seleda_finance/features/transactions/domain/value_objects/money.dart';

void main() {
  group('Money', () {
    test('adds values correctly', () {
      final first = Money.fromCents(500);
      final second = Money.fromCents(250);

      expect((first + second).cents, 750);
    });

    test('subtracts values correctly', () {
      final first = Money.fromCents(1000);
      final second = Money.fromCents(400);

      expect((first - second).cents, 600);
    });

    test('negation works', () {
      final money = Money.fromCents(200);

      expect((-money).cents, -200);
    });
  });
}
