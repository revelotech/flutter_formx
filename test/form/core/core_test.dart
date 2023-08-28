import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'core_test.mocks.dart';

@GenerateMocks([FirstValidator, SecondValidator])
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

main() {
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

    test('and isFormValid should not change', () async {
      testClass = await testClass.validateForm();
      expect(testClass.state.isFormValid, true);

      when(firstValidator.validate('123')).thenAnswer(
        (_) async =>
            const ValidatorResult(isValid: false, errorMessage: 'error'),
      );
      testClass = testClass.updateField(
        '123',
        'a',
      );

      expect(testClass.state.isFormValid, true);
    });
  });

  group('when user wants to update and validate form field', () {
    late FormX<String> testClass;

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

    test('and field is valid then it should not update the field with an error',
        () async {
      expect(
        testClass.state.inputMap['a']!.errorMessage,
        null,
      );

      await testClass.updateAndValidateField(
        '123456',
        'a',
      );
      expect(
        testClass.state.inputMap['a']!.errorMessage,
        null,
      );
    });

    group('and field is not valid', () {
      test(
          'with soft validation then it should not update the field with an '
          'error but isValid should be updated', () async {
        // setting up valid form
        testClass = await testClass.updateAndValidateField('12', 'a');
        testClass = await testClass.updateAndValidateField('123', 'b');
        testClass = await testClass.updateAndValidateField('1234', 'c');

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
        testClass = await testClass.updateAndValidateField('123', 'a',
            softValidation: true);

        // error is not updated
        expect(
          testClass.state.inputMap['a']!.errorMessage,
          null,
        );
        // form is now invalid because there is an error, even though it won't show in the UI
        expect(testClass.state.inputMap['a']!.isValid, false);
        expect(testClass.state.isFormValid, false);
      });

      test('with invalid string then it should update the field with an error',
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
          'only update the field with the first error', () async {
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
