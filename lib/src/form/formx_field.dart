import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_formx/src/validator/validator.dart';
import 'package:flutter_formx/src/validator/validator_result.dart';

/// [FormXField] is an immutable class used by FormX to handle each field in the form,
/// where [V] stands for the type used as the value of the form field.
class FormXField<V> extends Equatable {
  /// The value of the field, typed V
  final V? value;

  /// The list of validators to be applied to the field
  final List<Validator> validators;

  /// The error message of the field
  final String? errorMessage;

  /// The function to call when the field is invalid
  final VoidCallback? onValidationError;

  /// The state of the field, valid or invalid - it will always start
  /// as invalid until the first validation happens
  final bool isValid;

  const FormXField._({
    required this.value,
    required this.validators,
    this.isValid = false,
    this.errorMessage,
    this.onValidationError,
  });

  /// Constructor - Notice you can't set isValid from the start,
  /// it will always start as invalid until the first validation happens
  factory FormXField.from({
    required V? value,
    required List<Validator> validators,
    VoidCallback? onValidationError,
  }) {
    return FormXField._(
      value: value,
      validators: validators,
      onValidationError: onValidationError,
    );
  }

  /// Updates the value of the field, maintaining all other properties
  FormXField<V> updateValue(V newValue) => FormXField._(
        value: newValue,
        validators: validators,
        errorMessage: errorMessage,
        isValid: isValid,
        onValidationError: onValidationError,
      );

  /// Validates the field.
  ///
  /// It will iterate through all validators in order and
  /// return a new FormXField<V> applying the validation result's isValid and
  /// errorMessage properties
  Future<FormXField<V>> validateItem({
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

  FormXField<V> _applyValidationResult(String? errorMessage, bool isValid) =>
      FormXField._(
        value: value,
        validators: validators,
        errorMessage: errorMessage,
        isValid: isValid,
        onValidationError: onValidationError,
      );

  @override
  List<Object?> get props => [
        value,
        validators,
        errorMessage,
        isValid,
        onValidationError,
      ];
}
