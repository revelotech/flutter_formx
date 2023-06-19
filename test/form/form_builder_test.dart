import 'package:fake_async/fake_async.dart';
import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'form_builder_test.mocks.dart';

class FormXTest with FormX<String> {}

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

  FormXTest instantiate() => FormXTest();

  group('when setupForm is called', () {
    test('then it should setup inputMap with all the information', () {
      fakeAsync((async) {
        final testClass = instantiate();

        expect(testClass.inputMap.length, 0);

        testClass.setupForm({
          'a': FormItem<String>.from(value: '', validators: const []),
          'b': FormItem<String>.from(value: '', validators: const []),
          'c': FormItem<String>.from(value: '', validators: const []),
        });

        async.elapse(const Duration(seconds: 1));

        expect(testClass.inputMap.length, 3);
        expect(testClass.inputMap.keys.toList(), ['a', 'b', 'c']);

        expect(testClass.isFormValid, true);
      });
    });

    test(
        'and form is invalid then it should validate form and update isFormValid and not update errorMessage',
        () {
      fakeAsync((async) {
        when(firstValidator.validate(any)).thenAnswer(
          (_) async => const ValidatorResult(
            isValid: false,
            errorMessage: 'error message',
          ),
        );
        final testClass = instantiate();

        testClass.setupForm({
          'a': FormItem<String>.from(value: '', validators: const []),
          'b': FormItem<String>.from(value: '', validators: [firstValidator]),
          'c': FormItem<String>.from(value: '', validators: const []),
        });

        async.elapse(const Duration(seconds: 1));
        expect(testClass.isFormValid, false);

        expect(testClass.inputMap['a']!.errorMessage, null);
        expect(testClass.inputMap['a']!.isValid, true);
        expect(testClass.inputMap['b']!.errorMessage, null);
        expect(testClass.inputMap['b']!.isValid, false);
        expect(testClass.inputMap['c']!.errorMessage, null);
        expect(testClass.inputMap['c']!.isValid, true);
      });
    });
  });

  group('when user wants to update form field', () {
    late FormXTest testClass;

    setUp(() {
      testClass = instantiate();

      testClass.setupForm({
        'a': FormItem<String>.from(
          value: '',
          validators: [
            firstValidator,
            secondValidator,
          ],
        ),
        'b': FormItem<String>.from(value: '', validators: const []),
        'c': FormItem<String>.from(value: '', validators: const []),
      });
    });

    test('then it should update the correct field with the new value', () {
      expect(testClass.inputMap['a']!.value, '');
      testClass.updateField(
        '123',
        'a',
      );
      expect(
        testClass.inputMap['a']!.value,
        '123',
      );
    });

    test('then it should not validate field', () {
      expect(
        testClass.inputMap['a']!.errorMessage,
        null,
      );

      testClass.updateField(
        '123456',
        'a',
      );
      expect(
        testClass.inputMap['a']!.errorMessage,
        null,
      );
      verifyNever(firstValidator.validate('123456'));
    });
  });

  group('when user wants to update and validate form field', () {
    late FormXTest testClass;

    setUp(() {
      testClass = instantiate();

      testClass.setupForm({
        'a': FormItem<String>.from(
          value: '',
          validators: [
            firstValidator,
            secondValidator,
          ],
        ),
        'b': FormItem<String>.from(value: '', validators: const []),
        'c': FormItem<String>.from(value: '', validators: const []),
      });
    });

    test('then it should update the correct field with the new value',
        () async {
      expect(testClass.inputMap['a']!.value, '');
      await testClass.updateAndValidateField(
        '123',
        'a',
      );
      expect(
        testClass.inputMap['a']!.value,
        '123',
      );
    });

    test('and field is valid then it should not update error map with an error',
        () {
      fakeAsync((async) {
        expect(
          testClass.inputMap['a']!.errorMessage,
          null,
        );

        testClass.updateAndValidateField(
          '123456',
          'a',
        );
        async.elapse(const Duration(milliseconds: 200));
        expect(
          testClass.inputMap['a']!.errorMessage,
          null,
        );
      });
    });

    group('and field is not valid', () {
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
            testClass.inputMap['a']!.errorMessage,
            null,
          );

          testClass.updateAndValidateField(
            '123',
            'a',
          );
          async.elapse(const Duration(milliseconds: 200));
          expect(
            testClass.inputMap['a']!.errorMessage,
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
            testClass.inputMap['a']!.errorMessage,
            null,
          );

          testClass.updateAndValidateField(
            '',
            'a',
          );
          async.elapse(const Duration(milliseconds: 200));
          expect(
            testClass.inputMap['a']!.errorMessage,
            'mandatory field error',
          );
        });
      });
    });
  });

  group('when validateForm is called', () {
    late FormXTest testClass;

    setUp(() {
      testClass = instantiate();

      testClass.setupForm({
        'a': FormItem<String>.from(value: '1', validators: [firstValidator]),
        'b': FormItem<String>.from(
          value: '2',
          validators: [secondValidator],
        ),
        'c': FormItem<String>.from(value: '3', validators: const []),
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
      'a': FormItem<String>.from(value: '1', validators: const []),
      'b': FormItem<int>.from(value: 2, validators: const []),
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
      'a': FormItem<String>.from(
        value: '1',
        validators: [firstValidator],
      ),
      'b': FormItem<int>.from(value: 2, validators: const []),
    });

    await testClass.validateForm();

    final errorMessageA = testClass.getFieldErrorMessage('a');
    expect(errorMessageA, 'error message');

    final errorMessageB = testClass.getFieldErrorMessage('b');
    expect(errorMessageB, null);
  });
}
