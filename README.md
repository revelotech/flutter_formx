# mobx_form_builder

[![pub package](https://img.shields.io/pub/v/mobx_form_builder?style=plastic&logo=flutter)](https://pub.dev/packages/mobx_form_builder)

A Flutter package to make it easy to build, react to and validate forms using MobX.

## Features

![Working form gif](https://github.com/revelojobs/flutter_form_builder/assets/20102814/888295d6-d45a-44db-a467-02e742845d7d)

- Responsive state and form answer caching on current instance.
- Form validation.
- Abstract ValidationResult and Validator classes to help you integrate with form builder and make your own validations.

## ⚠ Caveats and limitations

This library is designed to work with mobx as its state management provider. It does not support Bloc, Provider or GetX as of yet.

## Usage

For example, say you want to build a form to collect the first name, last name and email from your user.

1. Add the `flutter_form_builder` package to your [pubspec dependencies](https://pub.dev/packages/flutter_form_builder/install).

2. Import `flutter_form_builder`.
    ```dart
    import 'package:flutter_form_builder/flutter_form_builder.dart';
    ```

3. Apply the mixin to your view model, specifying the type.
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
