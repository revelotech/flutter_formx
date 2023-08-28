import 'package:flutter_formx/src/form/core/formx_field.dart';
import 'package:flutter_formx/src/form/core/formx_state.dart';

/// Vanilla implementation of [FormXInterface].
/// The state management implementations should hold one instance of this class
class FormX<T> {

  /// This field holds the current FormXState
  late FormXState<T> state;

  /// Creates an empty FormX instance
  factory FormX.empty() => FormX<T>._();

  /// This method is used to setup the form with the provided initial values
  factory FormX.setupForm(Map<T, FormXField> inputs) => FormX<T>._(inputs);

  /// This method is used to create a FormX instance from a FormXState.
  /// The inputMap used will be the one inside the state
  factory FormX.fromState(FormXState<T> state) => FormX<T>._(state.inputMap);

  /// The FormX constructor.
  /// You should not use it directly, but instead use one of the factory constructors
  FormX._([Map<T, FormXField<dynamic>>? inputMap]) {
    state = FormXState<T>(inputMap ?? {});
  }

  /// Vanilla implementation of [FormXInterface.updateAndValidateField].
  Future<FormX<T>> updateAndValidateField(newValue, type, {bool softValidation = false}) async {
    final inputMap = _cloneStateMap;
    inputMap[type] =
        await inputMap[type]!.updateValue(newValue).validateItem(softValidation: softValidation);

    return FormX<T>._(inputMap);
  }

  /// Vanilla implementation of [FormXInterface.updateField].
  FormX<T> updateField(newValue, type) {
    final inputMap = _cloneStateMap;
    inputMap[type] = inputMap[type]!.updateValue(newValue);
    return FormX<T>._(inputMap);
  }

  /// Vanilla implementation of [FormXInterface.validateForm].
  Future<FormX<T>> validateForm({bool softValidation = false}) async {
    final inputMap = _cloneStateMap;
    await Future.forEach(inputMap.keys, (type) async {
      inputMap[type] = await inputMap[type]!.validateItem(softValidation: softValidation);
    });

    return FormX<T>._(inputMap);
  }

  Map<T, FormXField> get _cloneStateMap => Map<T, FormXField>.from(state.inputMap);
}
