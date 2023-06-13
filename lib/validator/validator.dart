import 'package:flutter_form_builder/validator/validator_result.dart';

///[Validator] is an abstract class that will allow you to create whatever
/// validation you need, always returning the same [ValidatorResult] object.
/// [T] stands for the type used to identify the fields such as a custom
/// object or a string.
abstract class Validator<T> {
  /// This is the method that will be called when validating the
  /// field, it should be overridden by every validator
  Future<ValidatorResult> validate(T value);

  /// This is a helper method to return a validation result as a Future,
  /// considering you might need asynchronous validations
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
