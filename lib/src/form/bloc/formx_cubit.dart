import 'package:bloc/bloc.dart';
import 'package:flutter_formx/src/form/bloc/formx_cubit_state.dart';
import 'package:flutter_formx/src/form/formx.dart';
import 'package:flutter_formx/src/form/formx_field.dart';
import 'package:flutter_formx/src/form/formx_state.dart';

/// Bloc implementation of [FormX]
class FormXCubit<T> extends Cubit<FormXState<T>> implements FormX<T> {
  /// When FormXCubit is instantiated, it emits the initial state of the form.
  FormXCubit() : super(const FormXState());

  /// Bloc implementation of [FormX.setupForm].
  @override
  Future<void> setupForm(Map<T, FormXField> inputs) {
    emit(FormXState<T>(inputs));
    return validateForm(softValidation: true);
  }

  Map<T, FormXField> get _cloneStateMap =>
      Map<T, FormXField>.from(state.inputMap);

  /// Bloc implementation of [FormX.updateAndValidateField].
  @override
  Future<void> updateAndValidateField(
    dynamic newValue,
    T type, {
    bool softValidation = false,
  }) async {
    final inputMap = _cloneStateMap;
    inputMap[type] = await inputMap[type]!
        .updateValue(newValue)
        .validateItem(softValidation: softValidation);
    emit(FormXState(inputMap));
  }

  /// Bloc implementation of [FormX.updateField].
  @override
  void updateField(dynamic newValue, T type) {
    final inputMap = _cloneStateMap;
    inputMap[type] = inputMap[type]!.updateValue(newValue);
    emit(FormXState(inputMap));
  }

  /// Bloc implementation of [FormX.validateForm].
  @override
  Future<bool> validateForm({bool softValidation = false}) async {
    final inputMap = _cloneStateMap;
    await Future.forEach(inputMap.keys, (type) async {
      inputMap[type] =
          await inputMap[type]!.validateItem(softValidation: softValidation);
    });
    emit(FormXState<T>(inputMap));
    return state.isFormValid;
  }
}
