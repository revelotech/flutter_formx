import 'dart:ui';

import 'package:flutter_form_builder/validator/validator.dart';
import 'package:flutter_form_builder/validator/validator_result.dart';

class FormItem<V> {
  final V? value;
  final List<Validator> validators;
  final String? errorMessage;
  final VoidCallback? onValidationError;
  final bool isValid;

  const FormItem._({
    required this.value,
    required this.validators,
    this.isValid = false,
    this.errorMessage,
    this.onValidationError,
  });

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

  FormItem<V> updateValue(V newValue) => FormItem._(
        value: newValue,
        validators: validators,
        errorMessage: errorMessage,
        isValid: isValid,
        onValidationError: onValidationError,
      );

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
  int get hashCode =>
      Object.hash(value, validators, errorMessage, isValid, onValidationError);

  // You should generally implement operator `==` if you
  // override `hashCode`.
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
