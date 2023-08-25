import 'package:flutter_formx/src/form/formx_field.dart';
import 'package:flutter_formx/src/form/formx_state.dart';

class FormX<T> {
  late FormXState<T> state;

  factory FormX.empty() => FormX<T>();
  factory FormX.setupForm(Map<T, FormXField> inputs) => FormX<T>(inputs);
  factory FormX.fromState(FormXState<T> state) => FormX<T>(state.inputMap);

  FormX([Map<T, FormXField<dynamic>>? inputMap]) {
    state = FormXState<T>(inputMap ?? {});
  }

  Future<FormX<T>> updateAndValidateField(newValue, type, {bool softValidation = false}) async {
    final inputMap = _cloneStateMap;
    inputMap[type] =
        await inputMap[type]!.updateValue(newValue).validateItem(softValidation: softValidation);

    return FormX<T>(inputMap);
  }

  FormX<T> updateField(newValue, type) {
    final inputMap = _cloneStateMap;
    inputMap[type] = inputMap[type]!.updateValue(newValue);
    return FormX<T>(inputMap);
  }

  Future<FormX<T>> validateForm({bool softValidation = false}) async {
    final inputMap = _cloneStateMap;
    await Future.forEach(inputMap.keys, (type) async {
      inputMap[type] = await inputMap[type]!.validateItem(softValidation: softValidation);
    });

    return FormX<T>(inputMap);
  }

  Map<T, FormXField> get _cloneStateMap => Map<T, FormXField>.from(state.inputMap);
}
