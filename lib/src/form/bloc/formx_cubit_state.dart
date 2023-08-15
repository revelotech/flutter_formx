import 'package:flutter_formx/src/form/formx_field.dart';
import 'package:flutter_formx/src/form/formx_state.dart';

/// Bloc state implementation of [FormXState]
class FormXCubitState<T> implements FormXState<T> {
  /// Bloc implementation of [FormX.inputMap].
  /// This is an observable map of fields
  @override
  late final Map<T, FormXField> inputMap;

  /// This class should receive an input map.
  FormXCubitState([this.inputMap = const {}]);

  /// Bloc implementation of [FormX.getFieldValue].
  @override
  V getFieldValue<V>(dynamic key) => inputMap[key]?.value as V;

  /// Bloc implementation of [FormX.getFieldErrorMessage].
  @override
  String? getFieldErrorMessage(dynamic key) => inputMap[key]?.errorMessage;

  /// Bloc implementation of [FormX.isFormValid].
  @override
  bool get isFormValid => inputMap.values.every((element) => element.isValid);
}
