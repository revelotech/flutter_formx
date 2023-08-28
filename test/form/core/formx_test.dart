import 'package:fake_async/fake_async.dart';
import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'formx_test.mocks.dart';

class FirstValidator extends Validator<String?> {
  @override
  Future<ValidatorResult> validate(String? value) =>
      Future.value(ValidatorResult.success());
}

class SecondValidator extends Validator<String?> {
  @override
  Future<ValidatorResult> validate(String? value) =>
      Future.value(ValidatorResult.success());
}

@GenerateMocks([FirstValidator, SecondValidator])
void main() {
  late MockFirstValidator firstValidator;
  late MockSecondValidator secondValidator;

  setUp(() {
    firstValidator = MockFirstValidator();
    secondValidator = MockSecondValidator();

    when(firstValidator.validate(any))
        .thenAnswer((_) async => ValidatorResult.success());
    when(secondValidator.validate(any))
        .thenAnswer((_) async => ValidatorResult.success());
  });

  test(
      'when object is created via empty factory '
      'then it should create a FormX instance with an empty map', () {
    final empty = FormX.empty();
    expect(empty.state.inputMap, {});
  });

  test(
      'when object is created via setupForm factory '
      'then it should setup inputMap with all the information', () {
    final inputsMap = {
      'a': FormXField<String>.from(value: '', validators: const []),
      'b': FormXField<String>.from(value: '', validators: const []),
      'c': FormXField<String>.from(value: '', validators: const []),
    };
    final testClass = FormX.setupForm(inputsMap);
    expect(testClass.state.inputMap, inputsMap);
  });

  group('when user wants to update form field', () {
    late FormX<String> testClass;
    late Map<String, FormXField<String>> inputsMap;

    setUp(() {
      inputsMap = {
        'a': FormXField<String>.from(
          value: '',
          validators: [
            firstValidator,
            secondValidator,
          ],
        ),
        'b': FormXField<String>.from(value: '', validators: const []),
        'c': FormXField<String>.from(value: '', validators: const []),
      };
      testClass = FormX.setupForm(inputsMap);
    });

    test(
        'then it should return a new instance '
        'with the updated field', () {
      testClass = testClass.updateField('123', 'a');

      inputsMap['a'] = inputsMap['a']!.updateValue('123');
      expect(testClass, FormX.setupForm(inputsMap));
    });

    test('then it should never validate field', () {
      testClass = testClass.updateField('123', 'a');
      verifyNever(firstValidator.validate('123456'));
    });
  });

  group('when user wants to update and validate form field', () {
    late FormX<String> testClass;
    late Map<String, FormXField<String>> inputsMap;
    setUp(() {
      inputsMap = {
        'a': FormXField<String>.from(
          value: '',
          validators: [
            firstValidator,
            secondValidator,
          ],
        ),
        'b': FormXField<String>.from(value: '', validators: const []),
        'c': FormXField<String>.from(value: '', validators: const []),
      };
      testClass = FormX.setupForm(inputsMap);
    });

    test(
        'without soft validation '
        'then it should return a new instance '
        'with the updated and validated field', () async {
      const newValue = '123';

      testClass = await testClass.updateAndValidateField(newValue, 'a');

      inputsMap['a'] =
          await inputsMap['a']!.updateValue(newValue).validateItem();
      expect(testClass, FormX.setupForm(inputsMap));
      verify(firstValidator.validate(newValue));
      verify(secondValidator.validate(newValue));
    });

    test(
        'with soft validation '
        'then it should return a new instance '
        'with the updated and validated field ', () async {
      const newValue = '123';

      testClass = await testClass.updateAndValidateField(newValue, 'a',
          softValidation: true);

      inputsMap['a'] = await inputsMap['a']!
          .updateValue(newValue)
          .validateItem(softValidation: true);
      expect(testClass, FormX.setupForm(inputsMap));
      verify(firstValidator.validate(newValue));
      verify(secondValidator.validate(newValue));
    });

    group('and field is not valid', () {
      test(
          'with soft validation then it should not update the error map with an '
          'error but isFormValid should be updated', () {
        fakeAsync((async) async {
          // setting up valid form
          await testClass.updateAndValidateField(
            '12',
            'a',
          );
          await testClass.updateAndValidateField(
            '123',
            'b',
          );
          await testClass.updateAndValidateField(
            '1234',
            'c',
          );

          expect(testClass.state.inputMap['a']!.errorMessage, null);
          // Form is valid
          expect(testClass.state.isFormValid, true);

          when(secondValidator.validate('123')).thenAnswer(
            (_) async => const ValidatorResult(
              isValid: false,
              errorMessage: 'invalid string',
            ),
          );

          // update with soft validation
          testClass.updateAndValidateField(
            '123',
            'a',
            softValidation: true,
          );

          async.elapse(const Duration(milliseconds: 200));
          // error is not updated
          expect(
            testClass.state.inputMap['a']!.errorMessage,
            null,
          );
          // form is now invalid because there is an error, even though it won't show in the UI
          expect(testClass.state.isFormValid, false);
        });
      });

      test(
          'with invalid string then it should update the error map with an error',
          () async {
        when(secondValidator.validate('123')).thenAnswer(
          (_) async => const ValidatorResult(
            isValid: false,
            errorMessage: 'invalid string',
          ),
        );

        expect(
          testClass.state.inputMap['a']!.errorMessage,
          null,
        );

        testClass = await testClass.updateAndValidateField(
          '123',
          'a',
        );

        expect(
          testClass.state.inputMap['a']!.errorMessage,
          'invalid string',
        );
      });

      test(
          'and it is invalid in multiple validators then it should '
          'only update errorMap with the first error', () async {
        when(firstValidator.validate('')).thenAnswer(
          (_) async => const ValidatorResult(
            isValid: false,
            errorMessage: 'mandatory field error',
          ),
        );
        when(secondValidator.validate('123')).thenAnswer(
          (_) async => const ValidatorResult(
            isValid: false,
            errorMessage: 'invalid string',
          ),
        );
        expect(
          testClass.state.inputMap['a']!.errorMessage,
          null,
        );

        testClass = await testClass.updateAndValidateField(
          '',
          'a',
        );

        expect(
          testClass.state.inputMap['a']!.errorMessage,
          'mandatory field error',
        );
      });
    });
  });

  group('when validateForm is called', () {
    late FormX<String> testClass;
    late Map<String, FormXField<String>> inputsMap;

    setUp(() {
      inputsMap = {
        'a': FormXField<String>.from(value: '1', validators: [firstValidator]),
        'b': FormXField<String>.from(
          value: '2',
          validators: [secondValidator],
        ),
        'c': FormXField<String>.from(value: '3', validators: const []),
      };
      testClass = FormX.setupForm(inputsMap);
    });

    test('then it should validate every field', () async {
      await testClass.validateForm();
      verify(firstValidator.validate('1'));
      verify(secondValidator.validate('2'));
    });

    test('then it should return a new FormX with a validated state map',
        () async {
      when(firstValidator.validate(any)).thenAnswer(
        (_) async => const ValidatorResult(
          isValid: false,
          errorMessage: 'error',
        ),
      );

      final Map<String, FormXField<String>> newMap = Map.from(inputsMap);
      for (var entry in newMap.entries) {
        newMap[entry.key] = await entry.value.validateItem();
      }

      final result = await testClass.validateForm();

      expect(result, FormX<String>.setupForm(newMap));
    });
  });
}
