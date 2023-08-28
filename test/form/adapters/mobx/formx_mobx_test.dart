import 'package:fake_async/fake_async.dart';
import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'formx_mobx_test.mocks.dart';

class FormXMobXTest with FormXMobX<String> {}

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

  FormXMobXTest instantiate() => FormXMobXTest();

  group('when setupForm is called', () {
    test(
        'and applySoftValidation is true '
        'then it should setup inputMap with the validated information',
        () async {
      final testClass = instantiate();

      expect(testClass.state.inputMap.length, 0);

      final inputsMap = {
        'a': FormXField<String>.from(value: '', validators: const []),
        'b': FormXField<String>.from(value: '', validators: const []),
        'c': FormXField<String>.from(value: '', validators: const []),
      };

      await testClass.setupForm(inputsMap);

      final validatedMap = Map<String, FormXField<String>>.from(inputsMap);
      for (final entry in validatedMap.entries) {
        validatedMap[entry.key] = await entry.value.validateItem();
      }

      expect(testClass.state.inputMap, validatedMap);
      expect(testClass.isFormValid, true);
    });

    test(
        'and applySoftValidation is false '
        'then it should setup inputMap with unvalidated information', () async {
      final testClass = instantiate();

      expect(testClass.state.inputMap.length, 0);

      final inputsMap = {
        'a': FormXField<String>.from(value: '', validators: const []),
        'b': FormXField<String>.from(value: '', validators: const []),
        'c': FormXField<String>.from(value: '', validators: const []),
      };

      await testClass.setupForm(inputsMap, applySoftValidation: false);

      expect(testClass.state.inputMap, inputsMap);
      expect(testClass.isFormValid, false);
    });

    test(
        'and form is invalid '
        'then it should validate form '
        'and update isFormValid '
        'and not update errorMessage', () {
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
        expect(testClass.isFormValid, false);

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
    late FormXMobXTest testClass;

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
    late FormXMobXTest testClass;

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
          expect(testClass.isFormValid, true);

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
          expect(testClass.isFormValid, false);
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
    late FormXMobXTest testClass;

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

  test(
      'when get field value '
      'then return value from given key as the given type', () {
    final testClass = instantiate();

    testClass.setupForm({
      'a': FormXField<String>.from(value: '1', validators: const []),
      'b': FormXField<int>.from(value: 2, validators: const []),
    });

    final formValueA = testClass.getFieldValue<String>('a');
    expect(formValueA, '1');
    expect(formValueA.runtimeType, String);

    final formValueB = testClass.getFieldValue<int>('b');
    expect(formValueB, 2);
    expect(formValueB.runtimeType, int);
  });

  test(
      'when get field error message '
      'then return errorMessage from given key', () async {
    when(firstValidator.validate(any)).thenAnswer(
      (_) async => const ValidatorResult(
        isValid: false,
        errorMessage: 'error message',
      ),
    );
    final testClass = instantiate();

    testClass.setupForm({
      'a': FormXField<String>.from(
        value: '1',
        validators: [firstValidator],
      ),
      'b': FormXField<int>.from(value: 2, validators: const []),
    });

    await testClass.validateForm();

    final errorMessageA = testClass.getFieldErrorMessage('a');
    expect(errorMessageA, 'error message');

    final errorMessageB = testClass.getFieldErrorMessage('b');
    expect(errorMessageB, null);
  });
}
