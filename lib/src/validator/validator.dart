import 'package:flutter_formx/src/validator/validator_result.dart';

/// [Validator] is an abstract class that will allow you to create whatever
/// validation you need, always returning the same [ValidatorResult] object.
/// [T] stands for the type used to identify the fields such as a custom
/// object or a string.
abstract class Validator<T> {
  /// Called by the FormX to validate each field.
  ///
  /// This should be overridden by each validator that extends this class.
  Future<ValidatorResult> validate(T value);

  /// Returns a validation result as a Future to avoid verbosity
  Future<ValidatorResult> result({
    required bool isValid,
    required String? errorMessage,
  }) {
    return Future.value(
      ValidatorResult(
        isValid: isValid,
        errorMessage: isValid ? null : errorMessage,
      ),
    );
  }
}
