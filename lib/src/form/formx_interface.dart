import 'package:flutter_formx/src/form/formx_field.dart';
import 'package:flutter_formx/src/form/formx_state.dart';

/// [FormX] is a helper class to handle forms. [T] stands for the type used to identify the fields
/// such as an enum or a string to later access each of its fields.
///
/// The first step is to call [setupForm] with a map of the fields, their initial values and
/// validators.
///
/// The second step is to call [updateAndValidateField] or [updateField] to update the value of
/// each field once it's changed on the UI.
///
/// The third and last step is to call [validateForm] to validate all fields.
abstract class FormXInterface<T> {
  /// Sets up the form with the given inputs
  ///
  /// This method should be called when starting the viewModel and it already validates the form
  /// without applying any error messages.
  void setupForm(Map<T, FormXField> inputs);

  /// Updates the value of the field and validates it, updating the value of [FormXState.isFormValid].
  /// When [softValidation] is true, it doesn't add errors messages to the fields, but updates the
  /// value of [FormXState.isFormValid] which can be used to show a submit button as enabled or disabled
  Future<void> updateAndValidateField(
    dynamic newValue,
    T type, {
    bool softValidation = false,
  });

  /// Updates the value of the field without validating it, this does not update the
  /// value of [FormXState.isFormValid]
  void updateField(dynamic newValue, T type);

  /// Validates all fields in the form
  ///
  /// Returns bool indicating if the form is valid and when [softValidation] is true,
  /// it doesn't add errors messages to the fields, but updates the value of [FormXState.isFormValid]
  /// which can be used to show a submit button as enabled or disabled
  Future<void> validateForm({bool softValidation = false});
}
