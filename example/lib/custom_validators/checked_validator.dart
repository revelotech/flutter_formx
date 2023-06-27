import 'package:flutter_formx/flutter_formx.dart';

class CheckedValidator extends Validator<bool> {
  String errorMessage;

  CheckedValidator(this.errorMessage);

  @override
  Future<ValidatorResult> validate(bool value) => result(
        isValid: value,
        errorMessage: errorMessage,
      );
}
