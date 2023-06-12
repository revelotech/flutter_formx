import 'package:flutter/foundation.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_form_builder_example/validator/required_field_validator.dart';
import 'package:mobx/mobx.dart';

part 'example_page_view_model.g.dart';

class ExamplePageViewModel extends _ExamplePageViewModelBase
    with _$ExamplePageViewModel {
  ExamplePageViewModel();
}

abstract class _ExamplePageViewModelBase with Store, FormBuilder<String> {
  _ExamplePageViewModelBase();

  @alwaysNotify
  bool showSuccessDialog = false;

  @observable
  String? validationError;

  @computed
  String? get firstName => getFieldValue<String?>('firstName');

  @computed
  String? get lastName => getFieldValue<String?>('lastName');

  @computed
  String? get email => getFieldValue<String?>('email');

  @computed
  String? get firstNameError => getFieldErrorMessage('firstName');

  @computed
  String? get lastNameError => getFieldErrorMessage('lastName');

  @computed
  bool get isSubmitButtonEnabled => isFormValid;

  void onViewReady() {
    setupForm({
      'firstName': FormItem<String?>.from(
        value: null,
        validators: [
          RequiredFieldValidator(),
        ],
        onValidationError: _logValidationError,
      ),
      'lastName': FormItem<String?>.from(
        value: null,
        validators: [
          RequiredFieldValidator(),
        ],
        onValidationError: _logValidationError,
      ),
      'email': FormItem<String?>.from(
        value: null,
        validators: const [],
      ),
    });
  }

  @action
  void onValueChanged({
    required String fieldName,
    String? newValue,
  }) {
    updateAndValidateField(newValue, fieldName);
  }

  @action
  void submitForm() {
    validateForm();
    if (isFormValid) {
      showSuccessDialog = true;
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
