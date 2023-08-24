import 'package:flutter_formx/src/form/formx_field.dart';

class FormX<T> {
  final Map<T, FormXField> inputMap;

  const FormX([this.inputMap = const {}]);

  V getFieldValue<V>(dynamic key) => inputMap[key]?.value as V;

  String? getFieldErrorMessage(dynamic key) => inputMap[key]?.errorMessage;

  bool get isFormValid => inputMap.values.every((element) => element.isValid);

  static Future<FormX> setupForm<T>(Map<T, FormXField> inputs) {
    return FormX(inputs).validateForm(softValidation: true);
  }

  Future<FormX> updateAndValidateField(newValue, type, {bool softValidation = false}) async {
    final inputMap = _cloneStateMap;
    inputMap[type] =
        await inputMap[type]!.updateValue(newValue).validateItem(softValidation: softValidation);

    return FormX(inputMap);
  }

  FormX<T> updateField(newValue, type) {
    final inputMap = _cloneStateMap;
    inputMap[type] = inputMap[type]!.updateValue(newValue);
    return FormX(inputMap);
  }

  Future<FormX> validateForm({bool softValidation = false}) async {
    final inputMap = _cloneStateMap;
    await Future.forEach(inputMap.keys, (type) async {
      inputMap[type] = await inputMap[type]!.validateItem(softValidation: softValidation);
    });

    return FormX(inputMap);
  }

  Map<T, FormXField> get _cloneStateMap => Map<T, FormXField>.from(inputMap);
}
