import 'package:flutter_formx/src/form/form_x_field.dart';

import 'formx.dart';

/// Bloc implementation of [FormX]
mixin FormXBloc<T> implements FormX<T> {
  /// Bloc implementation of [FormX.inputMap].
  /// This is an observable map of fields
  @override
  @observable
  final Map<T, FormXField> inputMap = <T, FormXField>{}.asObservable();

  /// Bloc implementation of [FormX.isFormValid].
  @override
  @computed
  bool get isFormValid => inputMap.values.every((element) => element.isValid);

  /// Bloc implementation of [FormX.setupForm].
  @override
  Future<void> setupForm(Map<T, FormXField> inputs) {
    inputMap.addAll(inputs);
    return validateForm(softValidation: true);
  }

  /// Bloc implementation of [FormX.updateAndValidateField].
  @override
  @action
  Future<void> updateAndValidateField(
    dynamic newValue,
    T type, {
    bool softValidation = false,
  }) async {
    inputMap[type] = await inputMap[type]!
        .updateValue(newValue)
        .validateItem(softValidation: softValidation);
  }

  /// Bloc implementation of [FormX.updateField].
  @override
  @action
  void updateField(dynamic newValue, T type) {
    inputMap[type] = inputMap[type]!.updateValue(newValue);
  }

  /// Bloc implementation of [FormX.validateForm].
  @override
  @action
  Future<bool> validateForm({bool softValidation = false}) async {
    await Future.forEach(inputMap.keys, (type) async {
      inputMap[type] =
          await inputMap[type]!.validateItem(softValidation: softValidation);
    });
    return isFormValid;
  }

  /// Bloc implementation of [FormX.getFieldValue].
  @override
  V getFieldValue<V>(dynamic key) => inputMap[key]?.value as V;

  /// Bloc implementation of [FormX.getFieldErrorMessage].
  @override
  String? getFieldErrorMessage(dynamic key) => inputMap[key]?.errorMessage;
}
