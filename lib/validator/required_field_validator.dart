import 'package:flutter_form_builder/validator/validator.dart';
import 'package:flutter_form_builder/validator/validator_result.dart';

/// A validator to ensure the field is filled with any non-null and non-empty value.
class RequiredFieldValidator extends Validator {
  RequiredFieldValidator(this.errorMessage);

  /// The error message returned if the field is not filled
  final String errorMessage;

  @override
  Future<ValidatorResult> validate(value) {
    final errorResult = result(
      isValid: false,
      errorMessage: errorMessage,
    );

    if (value == null) return errorResult;
    if (value is String && value.isEmpty) return errorResult;

    return result(
      isValid: true,
      errorMessage: null,
    );
  }
}
