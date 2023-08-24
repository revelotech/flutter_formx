import 'package:flutter_formx/src/form/formx_field.dart';
import 'package:flutter_formx/src/form/formx_interface.dart';
import 'package:flutter_formx/src/form/vanilla/formx.dart';
import 'package:mobx/mobx.dart';

/// MobX implementation of [FormX]
mixin FormXMobX<T> implements FormXInterface<T> {
  @observable
  FormX<T> formX = FormX<T>();

  @override
  void setupForm(Map<T, FormXField> inputs) async {
    formX = await FormX.setupForm(inputs);
  }

  @override
  @action
  Future<void> updateAndValidateField(newValue, type, {bool softValidation = false}) async {
    formX = await formX.updateAndValidateField(newValue, type, softValidation: softValidation);
  }

  @override
  @action
  void updateField(newValue, type) {
    formX = formX.updateField(newValue, type);
  }

  @override
  @action
  Future<void> validateForm({bool softValidation = false}) async {
    formX = await formX.validateForm(softValidation: softValidation);
  }
}
