import 'package:flutter_formx/src/form/adapters/formx_adapter.dart';
import 'package:flutter_formx/src/form/core/formx.dart';
import 'package:flutter_formx/src/form/core/formx_field.dart';
import 'package:flutter_formx/src/form/core/formx_state.dart';
import 'package:mobx/mobx.dart';

/// MobX implementation of [FormX]
mixin FormXMobX<T> implements FormXAdapter<T> {
  final Observable<FormX<T>> _formX = Observable(FormX.empty());

  /// Returns the current FormXState from this instance
  FormXState<T> get state => _formX.value.state;

  /// Returns the current validation status of the form from this instance's state
  bool get isFormValid => state.isFormValid;

  /// Gets a field value from the state by its key
  V getFieldValue<V>(T key) => state.getFieldValue(key);

  /// Gets a field error message from the state by its key.
  /// It will return null if the field is valid
  String? getFieldErrorMessage(T key) => state.getFieldErrorMessage(key);

  @override
  Future<void> setupForm(
    Map<T, FormXField> inputs, {
    bool applySoftValidation = true,
  }) async {
    Action(() {
      _formX.value = FormX.setupForm(inputs);
    })();
    if (applySoftValidation) {
      final validatedForm =
          await _formX.value.validateForm(softValidation: true);
      Action(() {
        _formX.value = validatedForm;
      })();
    }
  }

  @override
  Future<void> updateAndValidateField(
    newValue,
    key, {
    bool softValidation = false,
  }) async {
    final validatedField = await _formX.value
        .updateAndValidateField(newValue, key, softValidation: softValidation);
    Action(() {
      _formX.value = validatedField;
    })();
  }

  @override
  void updateField(newValue, key) {
    Action(() {
      _formX.value = _formX.value.updateField(newValue, key);
    })();
  }

  @override
  Future<bool> validateForm({bool softValidation = false}) async {
    final validatedForm =
        await _formX.value.validateForm(softValidation: softValidation);
    Action(() {
      _formX.value = validatedForm;
    })();
    return state.isFormValid;
  }
}
