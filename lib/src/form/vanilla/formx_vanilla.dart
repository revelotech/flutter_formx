import 'package:flutter_formx/src/form/formx_field.dart';

class FormXVanilla<T> {
  final Map<T, FormXField> inputMap;

  const FormXVanilla([this.inputMap = const {}]);

  V getFieldValue<V>(dynamic key) => inputMap[key]?.value as V;

  String? getFieldErrorMessage(dynamic key) => inputMap[key]?.errorMessage;

  bool get isFormValid => inputMap.values.every((element) => element.isValid);

  static Future<FormXVanilla<T>> setupForm<T>(Map<T, FormXField> inputs) {
    return FormXVanilla<T>(inputs).validateForm(softValidation: true);
  }

  Future<FormXVanilla<T>> updateAndValidateField(newValue, type, {bool softValidation = false}) async {
    final inputMap = _cloneStateMap;
    inputMap[type] =
        await inputMap[type]!.updateValue(newValue).validateItem(softValidation: softValidation);

    return FormXVanilla(inputMap);
  }

  FormXVanilla<T> updateField(newValue, type) {
    final inputMap = _cloneStateMap;
    inputMap[type] = inputMap[type]!.updateValue(newValue);
    return FormXVanilla(inputMap);
  }

  Future<FormXVanilla<T>> validateForm({bool softValidation = false}) async {
    final inputMap = _cloneStateMap;
    await Future.forEach(inputMap.keys, (type) async {
      inputMap[type] = await inputMap[type]!.validateItem(softValidation: softValidation);
    });

    return FormXVanilla(inputMap);
  }

  Map<T, FormXField> get _cloneStateMap => Map<T, FormXField>.from(inputMap);
}
