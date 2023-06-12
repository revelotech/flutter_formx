class ValidatorResult {
  final bool isValid;
  final String? errorMessage;

  const ValidatorResult({
    required this.isValid,
    this.errorMessage,
  });

  factory ValidatorResult.success() => const ValidatorResult(isValid: true);

  @override
  int get hashCode => Object.hash(isValid, errorMessage);

  // You should generally implement operator `==` if you
  // override `hashCode`.
  @override
  bool operator ==(Object other) {
    return other is ValidatorResult &&
        other.isValid == isValid &&
        other.errorMessage == errorMessage;
  }
}
