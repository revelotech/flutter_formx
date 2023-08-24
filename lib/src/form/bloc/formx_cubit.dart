import 'package:bloc/bloc.dart';
import 'package:flutter_formx/src/form/formx_field.dart';
import 'package:flutter_formx/src/form/formx_interface.dart';
import 'package:flutter_formx/src/form/formx_state.dart';
import 'package:flutter_formx/src/form/vanilla/formx.dart';

/// Bloc implementation of [FormX]
class FormXCubit<T> extends Cubit<FormXState<T>> implements FormXInterface<T> {
  /// When FormXCubit is instantiated, it emits the initial state of the form.
  FormXCubit() : super(const FormXState({}));

  FormX<T> _formX = FormX<T>();

  /// Bloc implementation of [FormX.setupForm].
  @override
  Future<void> setupForm(Map<T, FormXField> inputs) {
    emit(FormXState<T>(inputs));
    _formX = FormX(inputs);
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
        await _formX.updateAndValidateField(newValue, type, softValidation: softValidation);
    _formX = newState;
    emit(_formX.state);
  }

  /// Bloc implementation of [FormX.updateField].
  @override
  void updateField(dynamic newValue, T type) {
    final newState = _formX.updateField(newValue, type);
    _formX = newState;
    emit(_formX.state);
  }

  /// Bloc implementation of [FormX.validateForm].
  @override
  Future<bool> validateForm({bool softValidation = false}) async {
    final newState = await _formX.validateForm(softValidation: softValidation);
    _formX = newState;
    emit(_formX.state);
    return state.isFormValid;
  }
}
