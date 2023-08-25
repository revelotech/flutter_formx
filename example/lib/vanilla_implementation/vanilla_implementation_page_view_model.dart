import 'package:flutter/foundation.dart';
import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_formx_example/custom_validators/checked_validator.dart';
import 'package:flutter_formx_example/custom_validators/salary_validator.dart';

class VanillaImplementationPageViewModel {
  final ValueNotifier<FormX<String>> formX = ValueNotifier(FormX());

  ValueNotifier<bool> showSuccessInfo = ValueNotifier(false);

  ValueNotifier<String?> validationError = ValueNotifier(null);

  late ValueNotifier<FormXState<String>> state;

  VanillaImplementationPageViewModel() {
    state = ValueNotifier(formX.value.state);
    formX.addListener(() {
      state.value = formX.value.state;
    });
  }

  void onViewReady() {
    formX.value = FormX.setupForm({
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

  void onTextChanged({
    required String fieldName,
    String? newValue,
  }) async {
    formX.value = await formX.value.updateAndValidateField(newValue, fieldName);
  }

  void onIncomeChanged(int newValue) async {
    formX.value = await formX.value.updateAndValidateField(newValue, 'salaryExpectation');
  }

  void onAcceptTermsChanged(bool newValue) async {
    formX.value = await formX.value.updateAndValidateField(newValue, 'acceptTerms');
  }

  Future<void> submitForm() async {
    validationError.value = null;

    formX.value = await formX.value.validateForm();
    if (formX.value.state.isFormValid) {
      showSuccessInfo.value = true;
    } else {
      validationError.value = 'Validation error!';
    }
  }

  void _logValidationError() {
    debugPrint('Validation error!');
  }
}
