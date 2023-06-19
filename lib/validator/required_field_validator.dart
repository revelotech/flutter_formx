import 'package:flutter_formx/validator/validator.dart';
import 'package:flutter_formx/validator/validator_result.dart';

/// A validator to ensure the field is filled with any non-null and non-empty value.
class RequiredFieldValidator extends Validator {
  /// Constructor receives the error message to be returned if the field is not filled
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
