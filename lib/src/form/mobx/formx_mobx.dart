import 'package:flutter_formx/src/form/core/formx.dart';
import 'package:flutter_formx/src/form/core/formx_field.dart';
import 'package:flutter_formx/src/form/core/formx_interface.dart';
import 'package:flutter_formx/src/form/core/formx_state.dart';
import 'package:mobx/mobx.dart';

/// MobX implementation of [FormX]
mixin FormXMobX<T> implements FormXInterface<T> {
  final Observable<FormX<T>> _formX = Observable(FormX.empty());

  FormXState<T> get state => _formX.value.state;

  bool get isFormValid => state.isFormValid;

  @override
  Future<void> setupForm(Map<T, FormXField> inputs) async {
    Action(() {
      _formX.value = FormX.setupForm(inputs);
    })();
    final validatedForm = await _formX.value.validateForm(softValidation: true);
    Action(() {
      _formX.value = validatedForm;
    })();
  }

  @override
  Future<void> updateAndValidateField(newValue, type, {bool softValidation = false}) async {
    final validatedField =
        await _formX.value.updateAndValidateField(newValue, type, softValidation: softValidation);
    Action(() async {
      _formX.value = validatedField;
    })();
  }

  @override
  void updateField(newValue, type) {
    Action(() {
      _formX.value = _formX.value.updateField(newValue, type);
    })();
  }

  @override
  Future<bool> validateForm({bool softValidation = false}) async {
    final validatedForm = await _formX.value.validateForm(softValidation: softValidation);
    Action(() async {
      _formX.value = validatedForm;
    })();
    return state.isFormValid;
  }

  V getFieldValue<V>(T key) => state.getFieldValue(key);

  String? getFieldErrorMessage(T key) => state.getFieldErrorMessage(key);
}
