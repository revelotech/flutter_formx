import 'package:bloc/bloc.dart';
import 'package:flutter_formx/src/form/cubit/formx_cubit_state.dart';
import 'package:flutter_formx/src/form/form_x_field.dart';
import 'package:flutter_formx/src/form/formx.dart';

/// Bloc implementation of [FormX]
class FormXCubit<T> extends Cubit<FormXCubitState> implements FormX<T> {

  /// When FormXCubit is instantiated, it emits the initial state of the form.
  FormXCubit() : super(FormXInitial());

  /// Bloc implementation of [FormX.inputMap].
  /// This is an observable map of fields
  @override
  Map<T, FormXField> inputMap = <T, FormXField>{};

  /// Bloc implementation of [FormX.setupForm].
  @override
  Future<void> setupForm(Map<T, FormXField> inputs) async {
    inputMap = inputs;
    emit(FormXBuilt());
  }

  /// Bloc implementation of [FormX.updateAndValidateField].
  @override
  Future<void> updateAndValidateField(
    dynamic newValue,
    T type, {
    bool softValidation = false,
  }) async {
    emit(FormXUpdating());
    inputMap[type] = await inputMap[type]!
        .updateValue(newValue)
        .validateItem(softValidation: softValidation);
    emit(FormXBuilt());
  }

  /// Bloc implementation of [FormX.updateField].
  @override
  void updateField(dynamic newValue, T type) {
    emit(FormXUpdating());
    inputMap[type] = inputMap[type]!.updateValue(newValue);
    emit(FormXBuilt());
  }

  /// Bloc implementation of [FormX.validateForm].
  @override
  Future<bool> validateForm({bool softValidation = false}) async {
    emit(FormXValidating());
    await Future.forEach(inputMap.keys, (type) async {
      inputMap[type] =
          await inputMap[type]!.validateItem(softValidation: softValidation);
    });
    emit(FormXBuilt());

    return isFormValid;
  }

  /// Bloc implementation of [FormX.getFieldValue].
  // V getFieldValue<V>(dynamic key) => inputMap[key]?.value as V;
  @override
  V getFieldValue<V>(dynamic key) => inputMap[key]?.value as V;

  /// Bloc implementation of [FormX.getFieldErrorMessage].
  @override
  String? getFieldErrorMessage(dynamic key) => inputMap[key]?.errorMessage;

  /// Bloc implementation of [FormX.isFormValid].
  @override
  bool get isFormValid => inputMap.values.every((element) => element.isValid);
}
