import 'package:bloc/bloc.dart';
import 'package:flutter_formx/src/form/adapters/formx_adapter.dart';
import 'package:flutter_formx/src/form/core/formx.dart';
import 'package:flutter_formx/src/form/core/formx_field.dart';
import 'package:flutter_formx/src/form/core/formx_state.dart';

/// Bloc implementation of [FormX] with [FormXAdapter]
class FormXCubit<T> extends Cubit<FormXState<T>> implements FormXAdapter<T> {
  /// When FormXCubit is instantiated, it emits the initial state of the form.
  FormXCubit() : super(const FormXState({}));

  @override
  Future<void> setupForm(
    Map<T, FormXField> inputs, {
    bool applySoftValidation = true,
  }) async {
    emit(FormXState<T>(inputs));
    if (applySoftValidation) await validateForm(softValidation: true);
  }

  @override
  Future<void> updateAndValidateField(
    dynamic newValue,
    T key, {
    bool softValidation = false,
  }) async {
    final formX = await FormX.fromState(state)
        .updateAndValidateField(newValue, key, softValidation: softValidation);
    emit(formX.state);
  }

  @override
  void updateField(dynamic newValue, T key) {
    final formX = FormX.fromState(state).updateField(newValue, key);
    emit(formX.state);
  }

  @override
  Future<bool> validateForm({bool softValidation = false}) async {
    final formX = await FormX.fromState(state)
        .validateForm(softValidation: softValidation);
    emit(formX.state);
    return state.isFormValid;
  }
}
