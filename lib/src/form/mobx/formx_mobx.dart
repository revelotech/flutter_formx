import 'package:flutter_formx/src/form/formx.dart';
import 'package:flutter_formx/src/form/formx_field.dart';
import 'package:flutter_formx/src/form/formx_state.dart';
import 'package:mobx/mobx.dart';

/// MobX implementation of [FormX]
mixin FormXMobX<T> implements FormX<T>, FormXState<T> {
  /// MobX implementation of [FormX.inputMap].
  /// This is an observable map of fields
  @override
  @observable
  final Map<T, FormXField> inputMap = <T, FormXField>{}.asObservable();

  /// MobX implementation of [FormX.isFormValid].
  @override
  @computed
  bool get isFormValid => inputMap.values.every((element) => element.isValid);

  /// MobX implementation of [FormX.setupForm].
  @override
  Future<void> setupForm(Map<T, FormXField> inputs) {
    inputMap.addAll(inputs);
    return validateForm(softValidation: true);
  }

  /// MobX implementation of [FormX.updateAndValidateField].
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

  /// MobX implementation of [FormX.updateField].
  @override
  @action
  void updateField(dynamic newValue, T type) {
    inputMap[type] = inputMap[type]!.updateValue(newValue);
  }

  /// MobX implementation of [FormX.validateForm].
  @override
  @action
  Future<bool> validateForm({bool softValidation = false}) async {
    await Future.forEach(inputMap.keys, (type) async {
      inputMap[type] =
          await inputMap[type]!.validateItem(softValidation: softValidation);
    });
    return isFormValid;
  }

  /// MobX implementation of [FormX.getFieldValue].
  @override
  V getFieldValue<V>(dynamic key) => inputMap[key]?.value as V;

  /// MobX implementation of [FormX.getFieldErrorMessage].
  @override
  String? getFieldErrorMessage(dynamic key) => inputMap[key]?.errorMessage;
}
