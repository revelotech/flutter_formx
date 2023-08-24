import 'package:flutter_formx/src/form/formx.dart';
import 'package:flutter_formx/src/form/formx_field.dart';
import 'package:flutter_formx/src/form/formx_state.dart';
import 'package:flutter_formx/src/form/vanilla/formx_vanilla.dart';
import 'package:mobx/mobx.dart';

/// MobX implementation of [FormX]
mixin FormXMobX<T> {
  @observable
  FormX<T> state = FormX<T>();
}
