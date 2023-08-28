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
