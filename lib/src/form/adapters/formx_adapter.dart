import 'package:flutter_formx/src/form/core/formx_field.dart';

/// Adapter for [FormX].
/// The state management implementations should implement this class
abstract class FormXAdapter<T> {
  /// Implementations of this method should setup the form with the given inputs
  void setupForm(Map<T, FormXField> inputs);

  /// Implementations of this method should call [FormX.updateAndValidateField]
  Future<void> updateAndValidateField(
    dynamic newValue,
    T type, {
    bool softValidation = false,
  });

  /// Implementations of this method should call [FormX.updateField]
  void updateField(dynamic newValue, T type);

  /// Implementations of this method should call [FormX.validateForm]
  Future<void> validateForm({bool softValidation = false});
}
