import 'package:equatable/equatable.dart';
import 'package:flutter_formx/src/form/core/formx_field.dart';

/// [FormXState] is a class that holds the state of a form.
///
/// You can present the fields' values on screen by using either the helper
/// functions such as [FormXState.getFieldValue] or
/// [FormXState.getFieldErrorMessage] or by accessing the inputMap directly.
///
/// You can also use the computed value [FormXState.isFormValid] to show a
/// submit button as enabled or disabled and verify the status of the form.
class FormXState<T> extends Equatable {
  final Map<T, FormXField> _inputMap;

  /// Creates a [FormXState] instance
  const FormXState([this._inputMap = const {}]);

  /// Gets an unmodifiable instance of the inputMap
  Map<T, FormXField> get inputMap => Map.unmodifiable(_inputMap);

  /// Gets a field value by its key
  V getFieldValue<V>(T key) => _inputMap[key]?.value as V;

  /// Gets a field error message by its key. It will return null if the field is valid
  String? getFieldErrorMessage(T key) => _inputMap[key]?.errorMessage;

  /// Returns true if all fields are valid
  bool get isFormValid => _inputMap.values.every((element) => element.isValid);

  @override
  List<Object?> get props => [_inputMap];
}
