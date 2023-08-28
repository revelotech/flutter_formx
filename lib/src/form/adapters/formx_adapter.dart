import 'package:flutter_formx/src/form/core/formx_field.dart';

/// Adapter for [FormX].
/// The state management implementations should implement this class
abstract class FormXAdapter<T> {
  /// Sets up the form with the given inputs
  ///
  /// This method should be called when starting the form.
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
