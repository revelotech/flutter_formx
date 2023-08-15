import 'package:flutter_formx/src/form/formx_field.dart';

/// [FormXState] is an abstract class that should be implemented by a class that
/// will hold the form state.
abstract class FormXState<T> {

  /// The map of fields, along with all of their properties
  final Map<T, FormXField> inputMap = {};

  /// The computed value of the form's validation, true if all fields are valid, false otherwise
  bool get isFormValid => inputMap.values.every((element) => element.isValid);

  /// Returns the value of the field
  V getFieldValue<V>(dynamic key) => inputMap[key]?.value as V;

  /// Returns the error message of the field
  String? getFieldErrorMessage(dynamic key) => inputMap[key]?.errorMessage;
}
