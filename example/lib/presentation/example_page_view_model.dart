import 'package:flutter/foundation.dart';
import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_formx_example/custom_validators/checked_validator.dart';
import 'package:flutter_formx_example/custom_validators/salary_validator.dart';
import 'package:mobx/mobx.dart';

part 'example_page_view_model.g.dart';

class ExamplePageViewModel extends _ExamplePageViewModelBase
    with _$ExamplePageViewModel {
  ExamplePageViewModel();
}

abstract class _ExamplePageViewModelBase with Store, FormX<String> {
  _ExamplePageViewModelBase();

  @alwaysNotify
  bool showSuccessInfo = false;

  @observable
  String? validationError;

  @computed
  String? get email => getFieldValue<String?>('email');

  @computed
  String? get emailError => getFieldErrorMessage('email');

  @computed
  String? get career => getFieldValue<String?>('career');

  @computed
  int get salaryExpectation => getFieldValue<int>('salaryExpectation');

  @computed
  String? get salaryExpectationError =>
      getFieldErrorMessage('salaryExpectation');

  @computed
  bool get acceptTerms => getFieldValue<bool>('acceptTerms');

  @computed
  String? get acceptTermsError => getFieldErrorMessage('acceptTerms');

  @computed
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
    if (kDebugMode) {
      print('Validation error!');
    }
  }
}
