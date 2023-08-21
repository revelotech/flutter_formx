# Flutter FormX

[![pub package](https://img.shields.io/pub/v/flutter_formx?style=plastic&logo=flutter)](https://pub.dev/packages/flutter_formx)

![Flutter FormX Logo](https://raw.githubusercontent.com/revelojobs/flutter_formx/main/doc/static/FormX_Symbol96.png)

Flutter FormX is a package to make it easy to build, react to and validate forms using [MobX](https://pub.dev/packages/mobx) and [Bloc](https://pub.dev/packages/bloc).

- [Features](#features)
- [MobX Requirements](#mobx-requirements)
- [Bloc Requirements](#bloc-requirements)
- [MobX usage](#mobx-usage)
- [Bloc usage](#bloc-usage)
- [Validators](#validators)
- [Testing](#testing)

## Features

![Working form gif](https://raw.githubusercontent.com/revelojobs/flutter_formx/main/doc/static/FormX_example.gif)

- Responsive state and form answer caching on current instance.
- Form validation.
- Abstract ValidationResult and Validator classes to help you integrate with form builder and make your own validations.

## MobX Requirements

This library is designed to work with both [MobX](https://pub.dev/packages/mobx)/[MobX Code generation](https://pub.dev/packages/mobx_codegen) and [Bloc](https://pub.dev/packages/bloc) as its state management solutions. It does not support Riverpod, Provider or GetX as of yet.

If using MobX, make sure to include both dependencies in your project and run build runner once everything is set:

```yml
dependencies:
  mobx: <version>
  mobx_codegen: <version>

```

Running build runner:
```
flutter pub run build_runner build
```

## Bloc Requirements

If using Bloc, make sure to include its dependency in your project:

```yml
dependencies:
  bloc: <version>
```

## MobX usage

1. Add the `flutter_formx` package to your [pubspec dependencies](https://pub.dev/packages/flutter_formx/install).

2. Import `flutter_formx`.
    ```dart
    import 'package:flutter_formx/flutter_formx.dart';
    ```

3. Apply the mixin to your mobx store, specifying the type of the keys that will be used to retrieve each form field.
    ```dart
    class ExamplePageViewModel extends _ExamplePageViewModelBase with _$ExamplePageViewModel {
      ExamplePageViewModel();
    }

    abstract class _ExamplePageViewModelBase with Store, FormX<String> {
      _ExamplePageViewModelBase();
    }
    ```

4. As soon as the view is ready, make sure to call `setupForm` with a map of FormXFields (an entry for each of the inputs):
   - The keys of this map will be used to access each specific field and must be of the same type used on `FormX<Type>` such as String, enum, int etc.
   - Create FormXFields with the type of the input inside the `<>` and use the `FormXField.from` constructor.
   - When creating FormXFields you should pass its initial value, its validators and `onValidationError` (if needed) to log any errors when validating.

   Example:
   ```dart
   setupForm({
     'firstName': FormXField<String?>.from(
       value: null,
       validators: [
         RequiredFieldValidator(...),
       ],
       onValidationError: _logValidationError,
     ),
     'lastName': FormXField<String?>.from(
       value: null,
       validators: [
         RequiredFieldValidator(...),
       ],
       onValidationError: _logValidationError,
     ),
     'email': FormXField<String?>.from(
       value: null,
       validators: const [],
     ),
   });
   ```

5. Access the fields values and errors in the UI using `getFieldValue<T>(key)` and `getFieldErrorMessage<T>(key)`, either with computed mobx getters or using the FormX's getters directly in the UI.

    ```dart
    /// using computed mobx getters on the store
    @computed
    String? get firstName => getFieldValue<String?>('firstName');

    @computed
    String? get firstNameError => getFieldErrorMessage('firstName');

    /// using directly in your Widget (make sure to wrap it in an Observer if you want to observe to the changes)
    Text(
      'First Name: ${getFieldValue<String?>('email')}',
    ),
    ```

6. Update any field in the form using the inbuilt `updateAndValidateField` and `updateField` methods when the input is updated on your Widget.
    ```dart
    Future<void> updateFirstName(String? newValue) async {
      await updateAndValidateField(newValue, 'firstName');
    }
    ```

7. Quick tip: always validate your entire form before submitting information to the server.
    ```dart
    @action
    Future<void> submitForm() async {
      if (await validateForm()) {
        // submit form
      }
    }
    ```

## Bloc usage

1. Add the `flutter_formx` package to your [pubspec dependencies](https://pub.dev/packages/flutter_formx/install). In this example, we will also use `flutter_bloc` to help manage the state of the form.
    ```yml
    dependencies:
      flutter_bloc: <version>
      flutter_formx: <version>
    ```

2. Import `flutter_formx` and `flutter_bloc`.
    ```dart
    import 'package:flutter_formx/flutter_formx.dart';
    import 'package:flutter_bloc/flutter_bloc.dart';
    ```

3. Add `FormXCubit` in your tree with `BlocProvider`, passing the type of the keys that will be used to retrieve each form field.
    ```dart
    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (context) => FormXCubit<String>(),
        child: const Container(),
      );
    }
    ```

4. When creating the `FormXCubit`, make sure to call `setupForm` with a map of FormXFields (an entry for each of the inputs):
   - The keys of this map will be used to access each specific field and must be of the same type used on `FormX<Type>` such as String, enum, int etc.
   - Create FormXFields with the type of the input inside the `<>` and use the `FormXField.from` constructor.
   - When creating FormXFields you should pass its initial value, its validators and `onValidationError` (if needed) to log any errors when validating.

   Example:
   ```dart
    BlocProvider(
      create: (context) => FormXCubit<String>()
        ..setupForm(
          {
            'email': FormXField.from(
              value: '',
              validators: [
                RequiredFieldValidator('Your email is required'),
              ],
            ),
            'career': FormXField.from(
              value: '',
              validators: [],
            ),
            'salaryExpectation': FormXField<int>.from(
              value: 3100,
              validators: [
                SalaryValidator('You deserve a little more 😉'),
              ],
              onValidationError: _logValidationError,
            ),
            'acceptTerms': FormXField<bool>.from(
              value: false,
              validators: [
                CheckedValidator('You must accept our Terms and Conditions'),
              ],
              onValidationError: _logValidationError,
            ),
          },
        ),
      child: Container(),
   );
   ```

5. Use BlocBuilder to react to state changes and access fields' values and error messages in the UI directly from `FormXCubitState` using `getFieldValue<T>(key)` and `getFieldErrorMessage<T>(key)`.

    ```dart
    /// using getFieldValue in the UI
    @override
    Widget build(BuildContext context) {
      return BlocBuilder<FormXCubit<String>, FormXState<String>>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Form results',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text('Email: ${state.getFieldValue('email')}'),
              const SizedBox(height: 14),
              Text('Career: ${state.getFieldValue('career')}'),
              const SizedBox(height: 14),
              Text(
                'Salary expectation: ${state.getFieldValue('salaryExpectation')}',
              ),
              const SizedBox(height: 14),
              Text(
                  'Accepted terms: ${state.getFieldValue('acceptTerms')}'),
              const SizedBox(height: 14),
            ],
          );
        },
      );
    }

    /// using getFieldErrorMessage in the UI
    @override
    Widget build(BuildContext context) {
      return BlocBuilder<FormXCubit<String>, FormXState<String>>(
        builder: (context, state) {
          return Text(
            'Error message: ${state.getFieldErrorMessage<String?>('email')}',
          );
        },
      );
    }
    ```

6. Update any field in the form using FormXCubit's inbuilt `updateAndValidateField` and `updateField` methods when the input is updated on your Widget.
    ```dart
      TextField(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Your email*',
          errorText: state.getFieldErrorMessage('email'),
          errorStyle: const TextStyle(
            color: Colors.red,
          ),
        ),
        onChanged: (value) => context
            .read<FormXCubit<String>>()
            .updateAndValidateField(
              value,
              'email',
            ),
      ),
    ```

6. Enable or disable submit buttons based on the form's validity, available directlyfrom `FormXCubitState`.
    ```dart
    @override
    Widget build(BuildContext context) {
      return BlocBuilder<FormXCubit<String>, FormXState<String>>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state.isFormValid ? _submitForm : null,
            child: const Text('Submit'),
          );
        },
      );
    }
    ```

7. Quick tip: always validate your entire form before submitting information to the server.
    ```dart
    @action
    Future<void> _submitForm(BuildContext context) async {
      if (await context.read<FormXCubit<String>>().validateForm()) {
        // submit form
      }
    }
    ```

## Validators
You can create any kind of validator needed specifically for your needs and according to the field type you have. We've included the `RequiredFieldValidator`, but feel free to create more in your project as you need.

### Create your own validators
You can do that by creating a class that extends the `Validator` class. See example below:

Example:

```dart
class EmailValidator extends Validator<String?> {
  final String errorMessage;

  EmailValidator(
    this.errorMessage,
  );

  @override
  Future<ValidatorResult> validate(value) {
    if (value == null || value.isEmpty) {
      return result(isValid: true);
    }

    final isEmailValid = _validateEmail(value);

    return result(
      isValid: isEmailValid,
      errorMessage: errorMessage,
    );
  }

  bool _validateEmail(String email) {
    final regex = RegExp(r'^[^@,\s]+@[^@,\s]+\.[^@,.\s]+$');

    return regex.hasMatch(email);
  }
}

```

> **Note**<br/>
> We recommend that you avoid implementing more than one validation in each validator. If the field must be required and a valid email, add two validators, such as [RequiredValidator(), EmailValidator()]. This way you can reuse the email validator if this field ever becomes optional.

## Expanding the library

Feel free to expand the library and make it compatible with other state management solutions like Riverpod, Provider, GetX, etc. When doing that, keep in mind you'll need to implement both `formx.dart` and `formx_state.dart` and still use `formx_field.dart` in your implementation. Also, know you can count on us to help you with that! Just open an issue or PR and we'll be happy to help.

## Testing

See [example/test](https://github.com/revelojobs/flutter_formx/tree/main/test/form) for testing examples.
