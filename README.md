# flutter_form_builder

[![pub package](https://img.shields.io/pub/V/flutter_form_builder?style=plastic&logo=flutter)](https://pub.dev/packages/flutter_form_builder)

A Flutter package to make it easy to build, react to and validate forms.
## Features

![Working form gif](https://github.com/revelojobs/flutter_form_builder/assets/20102814/888295d6-d45a-44db-a467-02e742845d7d)

- Responsive state and form answer caching on current instance.
- Form validation.
- Abstract ValidationResult and Validator classes to help you integrate with form builder and make your own validations.

## ⚠ Caveats and limitations

This library is designed to work with mobx as its state management provider. It does not support Bloc, Provider or GetX as of yet.

## Form Classes

### FormBuilder

[FormBuilder] is a helper class to handle forms. [T] stands for the type used to identify the fields such as an enum or a string to later access each of its fields.

This class provides the following methods:
  ```dart
    /// Sets up the form with the given inputs
    /// This method should be called when starting the viewModel and
    /// it already validates the form without applying any error messages.
  Future<void> setupForm(Map<T, FormItem> inputs) {
      inputMap.addAll(inputs);
      return validateForm(softValidation: true);
    }
  ```

  ```dart
  /// This method updates a field and simultaneously validates it.
  /// This is the recommended way to update a field.
  @action
  Future<void> updateAndValidateField(dynamic newValue, T type) async {
    inputMap[type] = await inputMap[type]!.updateValue(newValue).validateItem();
  }
  ```

  ```dart
  /// This method updates a field without validating it. Use it conciously.
  @action
  void updateField(dynamic newValue, T type) {
    inputMap[type] = inputMap[type]!.updateValue(newValue);
  }
  ```

  ```dart
  /// Validates all fields in the form
  ///
  /// Returns bool indicating if the form is valid and when [softValidation] is true,
  /// it doesn't add errors messages to the fields, but updates the computed variable [isFormValid]
  /// which can be used to show a submit button as enabled or disabled
  @action
  Future<bool> validateForm({bool softValidation = false}) async {
    await Future.forEach(inputMap.keys, (type) async {
      inputMap[type] =
          await inputMap[type]!.validateItem(softValidation: softValidation);
    });
    return isFormValid;
  }
  ```

  ```dart
  /// Returns the value of a field
  V getFieldValue<V>(dynamic key) => inputMap[key]?.value as V;

  /// Returns the error message of a field
  String? getFieldErrorMessage(dynamic key) => inputMap[key]?.errorMessage;
  ```

  ```dart
  /// This is the inputMap, which is an observable map of the fields in the form.
  /// You can access it directly if you wish.
  @observable
  final ObservableMap<T, FormItem> inputMap = <T, FormItem>{}.asObservable();

  /// This is a computed variable that returns true if all fields are valid.
  @computed
  bool get isFormValid => inputMap.values.every((element) => element.isValid);
  ```

### FormItem

[FormItem] is a class used by FormBuilder to handle each field in the form, where [V] stands for the type used as the value of the form field. It contains the following properties:

  ```dart
  /// The value of the field, typed V
  @observable
  V value;

  /// The error message of the field
  @observable
  String? errorMessage;

  /// The validators of the field
  final List<Validator> validators;

  /// The function to call when the field is invalid
  final Function? onValidationError;

  /// The state of the field, valid or invalid - it will always start as invalid until the first validation happens
  final bool isValid;
  ```

  It also contains the following methods:

  ```dart
  /// Constructor - Notice you can't set isValid from the start, it will always start as invalid until the first validation happens
   factory FormItem.from({
    required V? value,
    required List<Validator> validators,
    VoidCallback? onValidationError,
  }) {
    return FormItem._(
      value: value,
      validators: validators,
      onValidationError: onValidationError,
    );
  }
  ```

  ```dart
  /// Updates the value of the field, maintaining all other properties
  FormItem<V> updateValue(V newValue) => FormItem._(
    value: newValue,
    validators: validators,
    errorMessage: errorMessage,
    isValid: isValid,
    onValidationError: onValidationError,
  );
  ```

  ```dart
  /// Validates the field, it will iterate through all validators in order and return a new FormItem<V> applying the validation result's isValid and errorMessage properties
  Future<FormItem<V>> validateItem({
    bool softValidation = false,
  }) {
    return Future.wait(
      validators.map((validator) {
        return validator.validate(value);
      }),
    ).then((validationResults) {
      final validation = validationResults.firstWhere(
        (element) => element.isValid == false,
        orElse: () => ValidatorResult.success(),
      );
      final errorMessage = softValidation ? null : validation.errorMessage;
      return applyValidationResult(errorMessage, validation.isValid);
    }).catchError((e, stackTrace) {
      onValidationError?.call();
      return applyValidationResult(null, true);
    });
  }
  ```

## Validator Classes

### Validator
[Validator] is an abstract class that will allow you to create whatever validation you need, always returning the same [ValidatorResult] object. [T] stands for the type used to identify the fields such as a custom object or a string. It contains the following methods:

  ```dart
  /// This is the method that will be called when validating the field, it should be overridden by every validator
  Future<ValidatorResult> validate(T value);

  /// This is a helper method to return a validation result as a Future, considering you might need asynchronous validations
  Future<ValidatorResult> result({
    required bool isValid,
    required String? errorMessage,
  }) {
    return Future.value(
      ValidatorResult(
        isValid: isValid,
        errorMessage: isValid ? null : errorMessage,
      ),
    );
  }
  ```

### ValidatorResult
[ValidatorResult] is a class that will be returned by every validator, it contains the following properties:

  ```dart
  /// The error message of the field
  final String? errorMessage;

  /// The state of the field, valid or invalid
  final bool isValid;
  ```

  It also contains the following methods:

  ```dart
  /// Constructor
  const ValidatorResult({
    required this.isValid,
    required this.errorMessage,
  });

  /// This is a helper method to return a successful validation result
  factory ValidatorResult.success() {
    return ValidatorResult(
      isValid: true,
      errorMessage: null,
    );
  }
  ```


## Usage

For example, say you want to build a form to collect the first name, last name and email from your user.

1. Add the `flutter_form_builder` package to your [pubspec dependencies](https://pub.dev/packages/flutter_form_builder/install).

2. Import `flutter_form_builder`.
    ```dart
    import 'package:flutter_form_builder/flutter_form_builder.dart';
    ```

3. Apply the mixin to your view model.
    ```dart
    class ExamplePageViewModel extends _ExamplePageViewModelBase with _$ExamplePageViewModel {
      ExamplePageViewModel();
    }

    abstract class _ExamplePageViewModelBase with Store, FormBuilder<String> {
      _ExamplePageViewModelBase();
    }
    ```


3. Create your form with the fields you want to collect as soon as the view is ready - check the example app if you have any doubts on that subject. You can use the `FormItem.from` constructor to create a form item with a value and validators. You can also pass a function to `onValidationError` to react when the field is invalid.
  ```dart
  setupForm({
      'firstName': FormItem<String?>.from(
        value: null,
        validators: [
          RequiredFieldValidator(),
        ],
        onValidationError: _logValidationError,
      ),
      'lastName': FormItem<String?>.from(
        value: null,
        validators: [
          RequiredFieldValidator(),
        ],
        onValidationError: _logValidationError,
      ),
      'email': FormItem<String?>.from(
        value: null,
        validators: const [],
      ),
    });
  ```

4. Use the form in your UI, either with computed mobx getters or using the FormBuilder's getters directly in the UI.
  ```dart
  /// using computed mobx getters
  @computed
  String? get firstName => getFieldValue<String?>('firstName');

  @computed
  String? get lastName => getFieldValue<String?>('lastName');

  @computed
  String? get email => getFieldValue<String?>('email');

  @computed
  String? get firstNameError => getFieldErrorMessage('firstName');

  @computed
  String? get lastNameError => getFieldErrorMessage('lastName');

  Text(
    'First Name: ${getFieldValue<String?>('email')}',
  ),
  ```

5. Update any field in the form using the inbuilt updateAndValidateField method.
  ```dart
  /// You can use one method per field or a single method for all fields.
  @action
  Future<void> updateFirstName(String? newValue) async {
    await updateAndValidateField(newValue, 'firstName');
  }

  @action
  Future<void> updateLastName(String? newValue) async {
    await updateAndValidateField(newValue, 'lastName');
  }

  @action
  Future<void> updateEmail(String? newValue) async {
    await updateAndValidateField(newValue, 'email');
  }

  @action
  void onValueChanged({
    required String fieldName,
    String? newValue,
  }) {
    updateAndValidateField(newValue, fieldName);
  }
  ```

6. Quick tip: always validate your entire form before submitting information to the server.
  ```dart
  @action
  Future<void> submitForm() async {
    if (await validateForm()) {
      // submit form
    }
  }
  ```

## Testing

See [example/test](https://github.com/revelojobs/flutter_form_builder/tree/main/test/form) for testing examples.
