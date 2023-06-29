import 'package:flutter_formx/flutter_formx.dart';

class SalaryValidator extends Validator<int> {
  String errorMessage;

  SalaryValidator(this.errorMessage);

  @override
  Future<ValidatorResult> validate(int value) => result(
        isValid: value >= 3000,
        errorMessage: errorMessage,
      );
}
