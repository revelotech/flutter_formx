import 'package:flutter_formx/src/form/formx.dart';
import 'package:flutter_formx/src/form/formx_field.dart';
import 'package:flutter_formx/src/form/vanilla/formx_vanilla.dart';
import 'package:mobx/mobx.dart';

/// MobX implementation of [FormX]
mixin FormXMobX<T> {
  @observable
  FormXVanilla<T> formX = FormXVanilla<T>();

  void setupForm(Map<T, FormXField> inputs) async {
    formX = await FormXVanilla.setupForm(inputs);
  }

  @action
  Future<void> updateAndValidateField(newValue, type, {bool softValidation = false}) async {
    formX = await formX.updateAndValidateField(newValue, type, softValidation: softValidation);
  }
}
