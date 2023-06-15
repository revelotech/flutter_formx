import 'dart:ui';

import 'package:mobx_form_builder/validator/validator.dart';
import 'package:mobx_form_builder/validator/validator_result.dart';

/// [FormItem] is an immutable class used by FormBuilder to handle each field in the form,
/// where [V] stands for the type used as the value of the form field.
class FormItem<V> {
  const FormItem._({
    required this.value,
    required this.validators,
    this.isValid = false,
    this.errorMessage,
    this.onValidationError,
  });

  /// Constructor - Notice you can't set isValid from the start,
  /// it will always start as invalid until the first validation happens
  factory FormItem.from({
    required V? value,
    required List<Validator> validators,
    VoidCallback? onValidationError,
  }) {
    return FormItem._(
      value: value,
      validators: validators,
      onValidationError: onValidationError,
    );
  }

  /// The value of the field, typed V
  final V? value;

  /// The list of validators applied to the field
  final List<Validator> validators;

  /// The error message returned by the first validator that fails
  final String? errorMessage;

  /// The function callback when the field validation throws an exception
  final VoidCallback? onValidationError;

  /// The state of the field, valid or invalid. It will always start
  /// as invalid until the first validation happens
  final bool isValid;

  /// Updates the value of the field, maintaining all other properties
  FormItem<V> updateValue(V newValue) => FormItem._(
        value: newValue,
        validators: validators,
        errorMessage: errorMessage,
        isValid: isValid,
        onValidationError: onValidationError,
      );

  /// Validates the field.
  ///
  /// It will iterate through all validators in order and
  /// return a new FormItem<V> applying the validation result's isValid and
  /// errorMessage properties
  Future<FormItem<V>> validateItem({
    bool softValidation = false,
  }) {
    return Future.wait(
      validators.map((validator) {
        return validator.validate(value);
      }),
    ).then((validationResults) {
      final validation = validationResults.firstWhere(
        (element) => element.isValid == false,
        orElse: () => ValidatorResult.success(),
      );
      final errorMessage = softValidation ? null : validation.errorMessage;
      return _applyValidationResult(errorMessage, validation.isValid);
    }).catchError((e, stackTrace) {
      onValidationError?.call();
      return _applyValidationResult(null, true);
    });
  }

  FormItem<V> _applyValidationResult(String? errorMessage, bool isValid) =>
      FormItem._(
        value: value,
        validators: validators,
        errorMessage: errorMessage,
        isValid: isValid,
        onValidationError: onValidationError,
      );

  @override
  int get hashCode => Object.hash(
        value,
        validators,
        errorMessage,
        isValid,
        onValidationError,
      );

  @override
  bool operator ==(Object other) {
    return other is FormItem &&
        other.value == value &&
        other.validators == validators &&
        other.errorMessage == errorMessage &&
        other.isValid == isValid &&
        other.onValidationError == onValidationError;
  }
}
