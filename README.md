# Flutter FormX

[![pub package](https://img.shields.io/pub/v/flutter_formx?style=plastic&logo=flutter)](https://pub.dev/packages/flutter_formx)

![Flutter FormX Logo](https://raw.githubusercontent.com/revelojobs/flutter_formx/main/doc/static/FormX_Symbol96.png)

Flutter FormX is an extensible package to make it easy to build, react to and validate forms
using [MobX](https://pub.dev/packages/mobx) and [Bloc](https://pub.dev/packages/bloc).

- [Features](#features)
- [Supported state management solutions](#supported-state-management-solutions)
- **[MobX usage](https://github.com/revelotech/flutter_formx/tree/main/lib/src/form/adapters/mobx)**
- **[Bloc usage](https://github.com/revelotech/flutter_formx/tree/main/lib/src/form/adapters/bloc)**
- [Validators](#validators)
- [Testing](#testing)

## Features

![Working form gif](https://raw.githubusercontent.com/revelojobs/flutter_formx/main/doc/static/FormX_example.gif)

- Responsive state and form answer caching on current instance.
- Form validation.
- Abstract ValidationResult and Validator classes to help you integrate with form builder and make
  your own validations.

## Supported state management solutions

This library has built-in adapters for both
[MobX](https://pub.dev/packages/mobx)
and [Bloc](https://pub.dev/packages/bloc) as its state management solutions.
However, you can use the vanilla implementation to adapt FormX to your favorite state management
solution.

- [MobX usage](https://github.com/revelotech/flutter_formx/tree/main/lib/src/form/adapters/mobx)
- [Bloc usage](https://github.com/revelotech/flutter_formx/tree/main/lib/src/form/adapters/bloc)

## Validators

You can create any kind of validator specifically for your needs and according to the field
type you have. We've included the `RequiredFieldValidator`, but feel free to create more in your
project as you need.

### Create your own validators

You can do that by creating a class that extends the `Validator` class. See example below:

Example:

```dart
class EmailValidator extends Validator<String?> {
  final String errorMessage;

  EmailValidator(this.errorMessage,);

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
> We recommend that you avoid implementing more than one validation in each validator. If the field
> must be required and a valid email, add two validators, such as
> [RequiredValidator(), EmailValidator()]. This way you can reuse the email validator if this field
> ever becomes optional.

## Expanding the library

Feel free to expand the library and make it compatible with other state management solutions. When
doing that, keep in mind you'll need to implement both `formx.dart` and `formx_state.dart` and still
use `formx_field.dart` in your implementation. Also, know you can count on us to help you with that!
Just open an issue or PR and we'll be happy to help.

## Testing

See [example/test](https://github.com/revelojobs/flutter_formx/tree/main/test/form) for testing
examples.
