import 'package:flutter_form_builder/validator/validator_result.dart';

abstract class Validator<T> {
  Future<ValidatorResult> validate(T value);

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
