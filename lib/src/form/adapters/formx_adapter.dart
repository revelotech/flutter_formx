import 'package:flutter_formx/src/form/core/formx_field.dart';

/// Adapter for [FormX].
/// The state management implementations should implement this class
abstract class FormXAdapter<T> {
  /// Implementations of this method should setup the form with the given
  /// inputs.
  ///
  /// When applySoftValidation is true, it updates the state of the form when
  /// setting it up. This way if the form is invalid, the errors won't show up
  /// but [FormXState.isFormValid] will be false.
  void setupForm(Map<T, FormXField> inputs, {bool applySoftValidation = true});

  /// Implementations of this method should call [FormX.updateAndValidateField]
  ///
  /// When applySoftValidation is true, it updates the state of the form when
  /// setting it up. This way if the form is invalid, the errors won't show up
  /// but [FormXState.isFormValid] will be false.
  Future<void> updateAndValidateField(
    dynamic newValue,
    T key, {
    bool softValidation = false,
  });

  /// Implementations of this method should call [FormX.updateField]
  void updateField(dynamic newValue, T key);

  /// Implementations of this method should call [FormX.validateForm]
  ///
  /// When [softValidation] is true, it doesn't add errors messages to the
  /// fields, but updates the value of [FormXState.isFormValid] which can be
  /// used to show a submit button as enabled or disabled.
  Future<void> validateForm({bool softValidation = false});
}
