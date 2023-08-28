import 'package:bloc_test/bloc_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'formx_cubit_test.mocks.dart';

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
  late Map<String, FormXField> testForm;
  late Map<String, FormXField> resultForm;

  setUp(() {
    firstValidator = MockFirstValidator();
    secondValidator = MockSecondValidator();

    when(firstValidator.validate(any))
        .thenAnswer((_) async => ValidatorResult.success());
    when(secondValidator.validate(any))
        .thenAnswer((_) async => ValidatorResult.success());
  });

  FormXCubit<String> instantiate() => FormXCubit<String>();

  group('when setupForm is called', () {
    blocTest(
      'and applySoftValidation is true '
      'then it should emit a configured form '
      'and a softly validated form',
      build: instantiate,
      setUp: () {
        testForm = {
          'a': FormXField<String>.from(value: '', validators: const []),
          'b': FormXField<String>.from(value: '', validators: const []),
          'c': FormXField<String>.from(value: '', validators: const []),
        };

        resultForm = Map<String, FormXField<String>>.from(testForm);
      },
      act: (cubit) async {
        await cubit.setupForm(testForm);
        for (var entry in resultForm.entries) {
          resultForm[entry.key] = await entry.value.validateItem();
        }
      },
      expect: () => [
        // pre form validation
        FormXState(testForm),
        // post form validation
        FormXState(resultForm),
      ],
    );

    blocTest(
      'and applySoftValidation is false '
      'then it should only emit a configured form',
      build: instantiate,
      setUp: () {
        testForm = {
          'a': FormXField<String>.from(value: '', validators: const []),
          'b': FormXField<String>.from(value: '', validators: const []),
          'c': FormXField<String>.from(value: '', validators: const []),
        };
      },
      act: (cubit) async =>
          await cubit.setupForm(testForm, applySoftValidation: false),
      expect: () => [
        // pre form validation
        FormXState(testForm),
      ],
    );

    test(
        'and form is invalid then it should validate form '
        'and update isFormValid and not update errorMessage', () {
      fakeAsync((async) {
        when(firstValidator.validate(any)).thenAnswer(
          (_) async => const ValidatorResult(
            isValid: false,
            errorMessage: 'error message',
          ),
        );
        final testClass = instantiate();

        testClass.setupForm({
          'a': FormXField<String>.from(value: '', validators: const []),
          'b': FormXField<String>.from(value: '', validators: [firstValidator]),
          'c': FormXField<String>.from(value: '', validators: const []),
        });

        async.elapse(const Duration(seconds: 1));
        expect(testClass.state.isFormValid, false);

        expect(testClass.state.inputMap['a']!.errorMessage, null);
        expect(testClass.state.inputMap['a']!.isValid, true);
        expect(testClass.state.inputMap['b']!.errorMessage, null);
        expect(testClass.state.inputMap['b']!.isValid, false);
        expect(testClass.state.inputMap['c']!.errorMessage, null);
        expect(testClass.state.inputMap['c']!.isValid, true);
      });
    });
  });

  group('when user wants to update form field', () {
    late FormXCubit<String> testClass;

    setUp(() {
      testClass = instantiate();

      testClass.setupForm({
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

    blocTest(
      'then it should emit new state with updated FormXField',
      build: instantiate,
      setUp: () async {
        final validator = RequiredFieldValidator('error');
        testForm = {
          'a': FormXField<String>.from(value: 'a', validators: [validator]),
          'b': FormXField<String>.from(value: 'aa', validators: const []),
          'c': FormXField<String>.from(value: 'aaa', validators: const []),
        };

        resultForm = {
          'a': FormXField<String>.from(value: 'z', validators: [validator]),
          'b': FormXField<String>.from(value: 'zz', validators: const []),
          'c': FormXField<String>.from(value: 'zzz', validators: const []),
        };
      },
      act: (cubit) async {
        await cubit.setupForm(testForm);

        // simulate test soft validation
        for (var entry in testForm.entries) {
          testForm[entry.key] =
              await entry.value.validateItem(softValidation: true);
        }

        // simulate result soft validation
        for (var entry in resultForm.entries) {
          resultForm[entry.key] =
              await entry.value.validateItem(softValidation: true);
        }

        String testValue = '';
        for (var entry in testForm.entries) {
          testValue += 'z';
          cubit.updateField(testValue, entry.key);
        }
      },
      skip: 1,
      expect: () => [
        // validated state after setup
        FormXState(testForm),
        // validated and updated states
        // verify change in 'a'
        FormXState({
          'a': resultForm['a']!,
          'b': testForm['b']!,
          'c': testForm['c']!,
        }),
        // verify change in 'a' and 'b'
        FormXState({
          'a': resultForm['a']!,
          'b': resultForm['b']!,
          'c': testForm['c']!,
        }),
        // verify form fully updated and validated
        FormXState(resultForm),
      ],
    );

    test('then it should update the correct field with the new value', () {
      expect(testClass.state.inputMap['a']!.value, '');
      testClass.updateField(
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
    late FormXCubit<String> testClass;

    setUp(() async {
      testClass = instantiate();

      await testClass.setupForm({
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

    blocTest(
      'then it should emit new state with updated and validated FormXField',
      build: instantiate,
      setUp: () async {
        final validator = RequiredFieldValidator('error');
        testForm = {
          'a': FormXField<String>.from(value: '', validators: [validator]),
          'b': FormXField<String>.from(value: '', validators: const []),
          'c': FormXField<String>.from(value: '', validators: const []),
        };

        resultForm = {
          'a': FormXField<String>.from(value: '123', validators: [validator]),
          'b': FormXField<String>.from(value: '', validators: const []),
          'c': FormXField<String>.from(value: '', validators: const []),
        };
      },
      act: (cubit) async {
        await cubit.setupForm(testForm);

        for (var entry in testForm.entries) {
          testForm[entry.key] =
              await entry.value.validateItem(softValidation: true);
        }

        for (var entry in resultForm.entries) {
          resultForm[entry.key] = await entry.value.validateItem();
        }
        await cubit.updateAndValidateField('123', 'a');
      },
      skip: 1,
      expect: () => [
        // validated state after setup
        FormXState(testForm),
        // validated and updated state
        FormXState(resultForm),
      ],
    );

    test('then it should update the correct field with the new value',
        () async {
      expect(testClass.state.inputMap['a']!.value, '');
      await testClass.updateAndValidateField(
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
        fakeAsync((async) {
          // setting up valid form
          testClass.updateAndValidateField(
            '12',
            'a',
          );
          testClass.updateAndValidateField(
            '123',
            'b',
          );
          testClass.updateAndValidateField(
            '1234',
            'c',
          );
          async.elapse(const Duration(milliseconds: 200));

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
          'with invalid string then it '
          'should update the error map with an error', () {
        fakeAsync((async) {
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

          testClass.updateAndValidateField(
            '123',
            'a',
          );
          async.elapse(const Duration(milliseconds: 200));
          expect(
            testClass.state.inputMap['a']!.errorMessage,
            'invalid string',
          );
        });
      });

      test(
          'and it is invalid in multiple validators then it should '
          'only update errorMap with the first error', () {
        fakeAsync((async) {
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

          testClass.updateAndValidateField(
            '',
            'a',
          );
          async.elapse(const Duration(milliseconds: 200));
          expect(
            testClass.state.inputMap['a']!.errorMessage,
            'mandatory field error',
          );
        });
      });
    });
  });

  group('when validateForm is called', () {
    late FormXCubit<String> testClass;

    setUp(() {
      testClass = instantiate();

      testClass.setupForm({
        'a': FormXField<String>.from(value: '1', validators: [firstValidator]),
        'b': FormXField<String>.from(
          value: '2',
          validators: [secondValidator],
        ),
        'c': FormXField<String>.from(value: '3', validators: const []),
      });
    });

    Map<String, FormXField<String>> intermediateResult = {};
    blocTest(
      'then it should emit new state with validated FormXFields',
      build: instantiate,
      setUp: () async {
        final requiredFieldValidator = RequiredFieldValidator('error');
        testForm = {
          'a': FormXField<String>.from(
              value: '1', validators: [requiredFieldValidator]),
          'b': FormXField<String>.from(
            value: '2',
            validators: [secondValidator],
          ),
          'c': FormXField<String>.from(value: '3', validators: const []),
        };

        intermediateResult = Map.from(testForm);

        resultForm = {
          'a': FormXField<String>.from(
              value: '', validators: [requiredFieldValidator]),
          'b': FormXField<String>.from(
            value: '2',
            validators: [secondValidator],
          ),
          'c': FormXField<String>.from(value: '3', validators: const []),
        };
      },
      act: (cubit) async {
        await cubit.setupForm(testForm);

        // simulate expected result soft validation
        for (var entry in intermediateResult.entries) {
          intermediateResult[entry.key] = await entry.value.validateItem();
        }

        intermediateResult['a'] = intermediateResult['a']!.updateValue('');
        cubit.updateField('', 'a');
        // simulate expected result soft validation
        for (var entry in resultForm.entries) {
          resultForm[entry.key] = await entry.value.validateItem();
        }

        await cubit.validateForm();
      },
      skip: 2,
      expect: () => [
        // validated and updated state
        FormXState(intermediateResult),
        FormXState(resultForm),
      ],
    );

    test('then it should validate every field', () async {
      await testClass.validateForm();
      verify(firstValidator.validate('1'));
      verify(secondValidator.validate('2'));
    });

    test('and form is valid then it should return true', () async {
      final result = await testClass.validateForm();
      expect(result, true);
    });

    test('and form is not valid then it should return false', () async {
      when(firstValidator.validate(any)).thenAnswer(
        (_) async => const ValidatorResult(
          isValid: false,
          errorMessage: 'mandatory field error',
        ),
      );
      final result = await testClass.validateForm();
      expect(result, false);
    });
  });
}
