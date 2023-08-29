import 'package:equatable/equatable.dart';
import 'package:flutter_formx/src/form/core/formx_field.dart';
import 'package:flutter_formx/src/form/core/formx_state.dart';

/// Vanilla implementation of [FormX].
/// The state management implementations should hold one instance of this class.
///
/// [FormX] is the core class to handle forms. [T] stands for the type used to
/// identify the fields such as an enum or a string to later access each of its
/// fields.
///
/// The first step is to call [FormX.setupForm] with a map of the fields, their
/// initial values and validators.
///
/// The second step is to call [updateAndValidateField] or [updateField] to
/// update the value of each field once it's changed on the UI.
///
/// The third and last step is to call [validateForm] to validate all fields.
///
/// This vanilla implementation doesn't handle state management, but every
/// function returns this same immutable class with a new state. Please refer
/// to the vanilla example or adapters to check how it can be managed.
class FormX<T> extends Equatable {
  /// This field holds the current FormXState
  late final FormXState<T> state;

  /// Creates an empty FormX instance
  factory FormX.empty() => FormX<T>._();

  /// This method is used to setup the form with the provided initial values
  factory FormX.setupForm(Map<T, FormXField> inputs) => FormX<T>._(inputs);

  /// This method is used to create a FormX instance from a FormXState.
  /// The inputMap used will be the one inside the state
  factory FormX.fromState(FormXState<T> state) => FormX<T>._(state.inputMap);

  /// The FormX constructor.
  /// You should not use it directly, but instead use one of the factory
  /// constructors
  FormX._([Map<T, FormXField<dynamic>>? inputMap]) {
    state = FormXState<T>(inputMap ?? {});
  }

  /// Returns a new FormX with the updated value of the field and validates it,
  /// updating the value of [FormXState.isFormValid].
  ///
  /// When [softValidation] is true, it doesn't add errors messages to the
  /// fields, but updates the value of [FormXState.isFormValid] which can be
  /// used to show a submit button as enabled or disabled.
  Future<FormX<T>> updateAndValidateField(
    newValue,
    T key, {
    bool softValidation = false,
  }) async {
    final inputMap = _cloneStateMap;
    inputMap[key] = await inputMap[key]!
        .updateValue(newValue)
        .validateItem(softValidation: softValidation);

    return FormX<T>._(inputMap);
  }

  /// Returns a new instance of FormX with the new value of the field without
  /// validating it, which means this will not update the value of
  /// [FormXState.isFormValid].
  FormX<T> updateField(newValue, T key) {
    final inputMap = _cloneStateMap;
    inputMap[key] = inputMap[key]!.updateValue(newValue);
    return FormX<T>._(inputMap);
  }

  /// Validates all fields in the form
  ///
  /// Returns a new state with all fields validated and when [softValidation] is
  /// true, it doesn't add errors messages to the fields, but updates the value
  /// of [FormXState.isFormValid]  which can be used to show a submit button as
  /// enabled or disabled
  Future<FormX<T>> validateForm({bool softValidation = false}) async {
    final inputMap = _cloneStateMap;
    await Future.forEach(inputMap.keys, (key) async {
      inputMap[key] =
          await inputMap[key]!.validateItem(softValidation: softValidation);
    });

    return FormX<T>._(inputMap);
  }

  Map<T, FormXField> get _cloneStateMap =>
      Map<T, FormXField>.from(state.inputMap);

  @override
  List<Object?> get props => [state];
}
