## MobX Requirements

If using MobX, make sure to include both dependencies and build_runner in your project and run build_runner once everything is set:

```yml
dependencies:
  mobx: <version>
  mobx_codegen: <version>
  build_runner: <version>
```

Running build runner:
```
flutter pub run build_runner build
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

    abstract class _ExamplePageViewModelBase with Store, FormXMobX<String> {
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
