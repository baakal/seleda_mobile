class Money {
  const Money._(this.cents);

  final int cents;

  factory Money.fromCents(int cents) {
    return Money._(cents);
  }

  factory Money.zero() => const Money._(0);

  factory Money.fromDouble(double amount) {
    final cents = (amount * 100).round();
    return Money._(cents);
  }

  Money operator +(Money other) => Money._(cents + other.cents);

  Money operator -(Money other) => Money._(cents - other.cents);

  Money operator -() => Money._(-cents);

  bool get isNegative => cents < 0;

  bool get isPositive => cents > 0;

  Money abs() => Money._(cents.abs());

  @override
  int get hashCode => cents.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Money && other.cents == cents;

  @override
  String toString() => 'Money(${cents / 100})';
}
