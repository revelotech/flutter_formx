## Bloc Requirements

If using Bloc, make sure to include its dependency in your project:

```yml
dependencies:
  bloc: <version>
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
      return BlocBuilder<FormXCubit<String>, FormXCubitState<String>>(
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
      return BlocBuilder<FormXCubit<String>, FormXCubitState<String>>(
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

7. Enable or disable submit buttons based on the form's validity, available directlyfrom `FormXCubitState`.
    ```dart
    @override
    Widget build(BuildContext context) {
      return BlocBuilder<FormXCubit<String>, FormXCubitState<String>>(
        builder: (context, state) {
          return ElevatedButton(
            onPressed: state.isFormValid ? _submitForm : null,
            child: const Text('Submit'),
          );
        },
      );
    }
    ```

8. Quick tip: always validate your entire form before submitting information to the server.
    ```dart
    @action
    Future<void> _submitForm(BuildContext context) async {
      if (await context.read<FormXCubit<String>>().validateForm()) {
        // submit form
      }
    }
    ```
