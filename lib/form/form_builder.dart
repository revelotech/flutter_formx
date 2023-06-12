import 'package:flutter_form_builder/form/form_item.dart';
import 'package:mobx/mobx.dart';

/// [FormBuilder] is a helper class to handle forms. [T] stands for the type used to identify the fields
/// such as an enum or a string to later access each of its fields.
///
/// The first step is to call [setupForm] with a map of the fields, their initial values and
/// validators.
///
/// The second step is to call [updateAndValidateField] or [updateField] to update the value of
/// each field once it's changed on the UI and present its value on screen by using either the
/// helper functions such as [getFieldValue] or [getFieldErrorMessage] or by accessing the inputMap
/// directly.
///
/// The third and final step is to call [validateForm] to validate all fields and use the computed
/// value [isFormValid] to show a submit button as enabled or disabled and verify the status of the
/// form.
mixin FormBuilder<T> {
  @observable
  final ObservableMap<T, FormItem> inputMap = <T, FormItem>{}.asObservable();

  @computed
  bool get isFormValid => inputMap.values.every((element) => element.isValid);

  /// Sets up the form with the given inputs
  ///
  /// This method should be called when starting the viewModel and it already validates the form
  /// without applying any error messages.
  Future<void> setupForm(Map<T, FormItem> inputs) {
    inputMap.addAll(inputs);
    return validateForm(softValidation: true);
  }

  @action
  Future<void> updateAndValidateField(dynamic newValue, T type) async {
    inputMap[type] = await inputMap[type]!.updateValue(newValue).validateItem();
  }

  @action
  void updateField(dynamic newValue, T type) {
    inputMap[type] = inputMap[type]!.updateValue(newValue);
  }

  /// Validates all fields in the form
  ///
  /// Returns bool indicating if the form is valid and when [softValidation] is true,
  /// it doesn't add errors messages to the fields, but updates the computed variable [isFormValid]
  /// which can be used to show a submit button as enabled or disabled
  @action
  Future<bool> validateForm({bool softValidation = false}) async {
    await Future.forEach(inputMap.keys, (type) async {
      inputMap[type] =
          await inputMap[type]!.validateItem(softValidation: softValidation);
    });
    return isFormValid;
  }

  V getFieldValue<V>(dynamic key) => inputMap[key]?.value as V;

  String? getFieldErrorMessage(dynamic key) => inputMap[key]?.errorMessage;
}
