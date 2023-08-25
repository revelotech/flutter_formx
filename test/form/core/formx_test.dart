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
      'when setupForm is called then it should setup inputMap with all the information',
      () {
    fakeAsync((async) {
      final emptyClass = FormX.empty();

      expect(emptyClass.state.inputMap.length, 0);

      final testClass = FormX.setupForm({
        'a': FormXField<String>.from(value: '', validators: const []),
        'b': FormXField<String>.from(value: '', validators: const []),
        'c': FormXField<String>.from(value: '', validators: const []),
      });

      async.elapse(const Duration(seconds: 1));

      expect(testClass.state.inputMap.length, 3);
      expect(testClass.state.inputMap.keys.toList(), ['a', 'b', 'c']);
    });
  });

  group('when user wants to update form field', () {
    late FormX testClass;

    setUp(() {
      testClass = FormX.setupForm({
        'a': FormXField<String>.from(
          value: '',
          validators: [
            firstValidator,
            secondValidator,
          ],
        ),
        'b': FormXField<String>.from(value: '', validators: const []),
        'c': FormXField<String>.from(value: '', validators: const []),
      });
    });

    test('then it should update the correct field with the new value', () {
      expect(testClass.state.inputMap['a']!.value, '');
      testClass = testClass.updateField(
        '123',
        'a',
      );
      expect(
        testClass.state.inputMap['a']!.value,
        '123',
      );
    });

    test('then it should not validate field', () {
      expect(
        testClass.state.inputMap['a']!.errorMessage,
        null,
      );

      testClass.updateField(
        '123456',
        'a',
      );
      expect(
        testClass.state.inputMap['a']!.errorMessage,
        null,
      );
      verifyNever(firstValidator.validate('123456'));
    });
  });

  group('when user wants to update and validate form field', () {
    late FormX testClass;

    setUp(() {
      testClass = FormX.setupForm({
        'a': FormXField<String>.from(
          value: '',
          validators: [
            firstValidator,
            secondValidator,
          ],
        ),
        'b': FormXField<String>.from(value: '', validators: const []),
        'c': FormXField<String>.from(value: '', validators: const []),
      });
    });

    test('then it should update the correct field with the new value',
        () async {
      expect(testClass.state.inputMap['a']!.value, '');
      testClass = await testClass.updateAndValidateField(
        '123',
        'a',
      );
      expect(
        testClass.state.inputMap['a']!.value,
        '123',
      );
    });

    test('and field is valid then it should not update error map with an error',
        () {
      fakeAsync((async) {
        expect(
          testClass.state.inputMap['a']!.errorMessage,
          null,
        );

        testClass.updateAndValidateField(
          '123456',
          'a',
        );
        async.elapse(const Duration(milliseconds: 200));
        expect(
          testClass.state.inputMap['a']!.errorMessage,
          null,
        );
      });
    });

    group('and field is not valid', () {
      test(
          'with soft validation then it should not update the error map with an '
          'error but isValid should be updated', () {
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
    late FormX testClass;
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

      // validating invalid form
      expect(result.state.getFieldErrorMessage('a'), 'error');
      expect(result.state.inputMap, newMap);
      expect(result.state.isFormValid, false);

      // validating valid form
      when(firstValidator.validate(any)).thenAnswer(
        (_) async => const ValidatorResult(
          isValid: true,
        ),
      );
      final result2 = await result.validateForm();
      expect(result2.state.getFieldErrorMessage('a'), null);
      expect(result2.state.isFormValid, true);
    });
  });
}
