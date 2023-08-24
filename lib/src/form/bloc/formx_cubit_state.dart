import 'package:equatable/equatable.dart';
import 'package:flutter_formx/src/form/formx_field.dart';
import 'package:flutter_formx/src/form/formx_state.dart';

/// Bloc state implementation of [FormXState]
class FormXCubitState<T> extends Equatable implements FormXState<T> {
  /// Bloc implementation of [FormXState.inputMap].
  /// This is an observable map of fields
  @override
  final Map<T, FormXField> inputMap;

  /// This class should receive an input map.
  const FormXCubitState([this.inputMap = const {}]);

  /// Bloc implementation of [FormXState.getFieldValue].
  @override
  V getFieldValue<V>(dynamic key) => inputMap[key]?.value as V;

  /// Bloc implementation of [FormXState.getFieldErrorMessage].
  @override
  String? getFieldErrorMessage(dynamic key) => inputMap[key]?.errorMessage;

  /// Bloc implementation of [FormXState.isFormValid].
  @override
  bool get isFormValid => inputMap.values.every((element) => element.isValid);

  @override
  List<Object> get props => [inputMap];
}