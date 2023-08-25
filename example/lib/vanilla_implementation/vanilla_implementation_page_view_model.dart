import 'package:flutter/foundation.dart';
import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_formx_example/custom_validators/checked_validator.dart';
import 'package:flutter_formx_example/custom_validators/salary_validator.dart';
import 'package:mobx/mobx.dart';

class VanillaImplementationPageViewModel {

  @alwaysNotify
  bool showSuccessInfo = false;

  String? validationError;

  String? get email => getFieldValue<String?>('email');

  String? get emailError => getFieldErrorMessage('email');

  String? get career => getFieldValue<String?>('career');

  int get salaryExpectation => getFieldValue<int>('salaryExpectation');

  String? get salaryExpectationError =>
      getFieldErrorMessage('salaryExpectation');

  bool get acceptTerms => getFieldValue<bool>('acceptTerms');

  String? get acceptTermsError => getFieldErrorMessage('acceptTerms');

  bool get isSubmitButtonEnabled => isFormValid;

  void onViewReady() {
    setupForm({
      'email': FormXField<String?>.from(
        value: null,
        validators: [
          RequiredFieldValidator('Your email is required'),
        ],
        onValidationError: _logValidationError,
      ),
      'career': FormXField<String?>.from(
        value: null,
        validators: const [],
        onValidationError: _logValidationError,
      ),
      'salaryExpectation': FormXField<int>.from(
        value: 3100,
        validators: [
          SalaryValidator('You deserve a little more 😉'),
        ],
        onValidationError: _logValidationError,
      ),
      'acceptTerms': FormXField<bool>.from(
        value: false,
        validators: [
          CheckedValidator('You must accept our Terms and Conditions'),
        ],
        onValidationError: _logValidationError,
      ),
    });
  }

  @action
  void onTextChanged({
    required String fieldName,
    String? newValue,
  }) {
    updateAndValidateField(newValue, fieldName);
  }

  @action
  void onIncomeChanged(int newValue) {
    updateAndValidateField(newValue, 'salaryExpectation');
  }

  @action
  void onAcceptTermsChanged(bool newValue) {
    updateAndValidateField(newValue, 'acceptTerms');
  }

  @action
  void submitForm() {
    validateForm();
    if (isFormValid) {
      showSuccessInfo = true;
    } else {
      validationError = 'Validation error!';
    }
  }

  void _logValidationError() {
    debugPrint('Validation error!');
  }
}
