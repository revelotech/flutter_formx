import 'package:bloc/bloc.dart';
import 'package:flutter_formx/src/form/adapters/formx_adapter.dart';
import 'package:flutter_formx/src/form/core/formx.dart';
import 'package:flutter_formx/src/form/core/formx_field.dart';
import 'package:flutter_formx/src/form/core/formx_state.dart';

/// Bloc implementation of [FormX] with [FormXAdapter]
class FormXCubit<T> extends Cubit<FormXState<T>> implements FormXAdapter<T> {
  /// When FormXCubit is instantiated, it emits the initial state of the form.
  FormXCubit() : super(const FormXState({}));

  /// Bloc implementation of [FormX.setupForm].
  @override
  Future<void> setupForm(Map<T, FormXField> inputs) {
    emit(FormXState<T>(inputs));
    return validateForm(softValidation: true);
  }

  /// Bloc implementation of [FormX.updateAndValidateField].
  @override
  Future<void> updateAndValidateField(
    dynamic newValue,
    T type, {
    bool softValidation = false,
  }) async {
    final formX = await FormX.fromState(state)
        .updateAndValidateField(newValue, type, softValidation: softValidation);
    emit(formX.state);
  }

  /// Bloc implementation of [FormX.updateField].
  @override
  void updateField(dynamic newValue, T type) {
    final formX = FormX.fromState(state).updateField(newValue, type);
    emit(formX.state);
  }

  /// Bloc implementation of [FormX.validateForm].
  @override
  Future<bool> validateForm({bool softValidation = false}) async {
    final formX = await FormX.fromState(state)
        .validateForm(softValidation: softValidation);
    emit(formX.state);
    return state.isFormValid;
  }
}
