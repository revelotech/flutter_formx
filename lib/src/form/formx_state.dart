import 'package:equatable/equatable.dart';
import 'package:flutter_formx/src/form/formx_field.dart';

/// [FormXState] is an abstract class that should be implemented by a class that
/// will hold the form state.
///
/// You can present the fields' values on screen by using either the helper functions such as
/// [FormXState.getFieldValue] or [FormXState.getFieldErrorMessage] or by
/// accessing the inputMap directly.
///
/// You can also use the computed value [FormXState.isFormValid] to show a submit button as
/// enabled or disabled and verify the status of the form.
class FormXState<T> extends Equatable {
  final Map<T, FormXField> _inputMap;

  const FormXState([this._inputMap = const {}]);

  Map<T, FormXField> get inputMap => Map.unmodifiable(_inputMap);

  V getFieldValue<V>(T key) => _inputMap[key]?.value as V;

  String? getFieldErrorMessage(T key) => _inputMap[key]?.errorMessage;

  bool get isFormValid => _inputMap.values.every((element) => element.isValid);

  @override
  List<Object?> get props => [_inputMap];
}
