import 'package:flutter_form_builder/flutter_form_builder.dart';

class RequiredFieldValidator extends Validator<String?> {
  RequiredFieldValidator();

  @override
  Future<ValidatorResult> validate(value) {
    if (value == null || value.isEmpty) {
      return result(
        isValid: false,
        errorMessage: 'This field is required.',
      );
    }

    return result(
      isValid: true,
      errorMessage: null,
    );
  }
}
