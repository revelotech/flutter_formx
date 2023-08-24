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
  final Map<T, FormXField> inputMap;

  const FormXState([this.inputMap = const {}]);

  V getFieldValue<V>(dynamic key) => inputMap[key]?.value as V;

  String? getFieldErrorMessage(dynamic key) => inputMap[key]?.errorMessage;

  bool get isFormValid => inputMap.values.every((element) => element.isValid);

  @override
  List<Object?> get props => [inputMap];
}
