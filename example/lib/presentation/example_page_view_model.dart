import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:mobx_form_builder/mobx_form_builder.dart';

part 'example_page_view_model.g.dart';

class ExamplePageViewModel extends _ExamplePageViewModelBase
    with _$ExamplePageViewModel {
  ExamplePageViewModel();
}

abstract class _ExamplePageViewModelBase with Store, FormBuilder<String> {
  _ExamplePageViewModelBase();

  @alwaysNotify
  bool showSuccessInfo = false;

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
        validators: [RequiredFieldValidator('First name is required')],
        onValidationError: _logValidationError,
      ),
      'lastName': FormItem<String?>.from(
        value: null,
        validators: [RequiredFieldValidator('Last name is required')],
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
