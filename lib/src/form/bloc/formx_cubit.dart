import 'package:bloc/bloc.dart';
import 'package:flutter_formx/src/form/formx_field.dart';
import 'package:flutter_formx/src/form/formx_interface.dart';
import 'package:flutter_formx/src/form/vanilla/formx.dart';

/// Bloc implementation of [FormX]
class FormXCubit<T> extends Cubit<FormX<T>> implements FormXInterface<T> {
  /// When FormXCubit is instantiated, it emits the initial state of the form.
  FormXCubit() : super(const FormX());

  /// Bloc implementation of [FormX.setupForm].
  @override
  Future<void> setupForm(Map<T, FormXField> inputs) {
    emit(FormX<T>(inputs));
    return validateForm(softValidation: true);
  }

  /// Bloc implementation of [FormX.updateAndValidateField].
  @override
  Future<void> updateAndValidateField(
    dynamic newValue,
    T type, {
    bool softValidation = false,
  }) async {
    final newState =
        await state.updateAndValidateField(newValue, type, softValidation: softValidation);
    emit(newState);
  }

  /// Bloc implementation of [FormX.updateField].
  @override
  void updateField(dynamic newValue, T type) {
    final newState = state.updateField(newValue, type);
    emit(newState);
  }

  /// Bloc implementation of [FormX.validateForm].
  @override
  Future<bool> validateForm({bool softValidation = false}) async {
    final newState = await state.validateForm(softValidation: softValidation);
    emit(newState);
    return state.isFormValid;
  }
}
