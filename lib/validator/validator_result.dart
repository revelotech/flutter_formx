/// [ValidatorResult] is a helper class designed to help [Validator] implementations always return the same object type.
class ValidatorResult {
  /// The state of the field, valid or invalid
  final bool isValid;

  /// The error message of the field
  final String? errorMessage;

  /// This is the constructor of the class
  const ValidatorResult({
    required this.isValid,
    this.errorMessage,
  });

  /// This is a helper method to return a successful validation result
  factory ValidatorResult.success() => const ValidatorResult(isValid: true);

  @override
  int get hashCode => Object.hash(isValid, errorMessage);

  @override
  bool operator ==(Object other) {
    return other is ValidatorResult &&
        other.isValid == isValid &&
        other.errorMessage == errorMessage;
  }
}
