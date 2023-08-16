import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'formx_cubit_state_test.mocks.dart';

class TestValidator extends Validator<String?> {
  @override
  Future<ValidatorResult> validate(String? value) =>
      Future.value(ValidatorResult.success());
}

@GenerateMocks([TestValidator])
void main() {
  late MockTestValidator testValidator;
  late Map<String, FormXField<String>> testMap;

  setUp(() {
    testValidator = MockTestValidator();
    testMap = {
      'a': FormXField<String>.from(value: 'abc', validators: const []),
      'b': FormXField<String>.from(value: '', validators: [testValidator]),
      'c': FormXField<String>.from(value: '', validators: const []),
    };

    when(testValidator.validate(any))
        .thenAnswer((_) async => ValidatorResult.success());
  });

  FormXCubitState instantiate() => FormXCubitState(testMap);

  group('when getFieldValue is called', () {
    test('then it should return the value', () {
      final testClass = instantiate();

      expect(testClass.getFieldValue('a'), 'abc');
      expect(testClass.getFieldValue('b'), '');
      expect(testClass.getFieldValue('c'), '');
    });

    test('with invalid key then it should return null', () {
      final testClass = instantiate();

      expect(testClass.getFieldValue('d'), null);
    });
  });

  group('when getFieldErrorMessage is called', () {
    test('when getFieldErrorMessage is called then it should return it',
        () async {
      when(testValidator.validate('')).thenAnswer(
        (_) async => const ValidatorResult(
          isValid: false,
          errorMessage: 'mandatory field error',
        ),
      );
      final testClass = instantiate();

      testClass.inputMap['b'] = await testClass.inputMap['b']!.validateItem();

      expect(testClass.getFieldErrorMessage('a'), null);
      expect(testClass.getFieldErrorMessage('b'), 'mandatory field error');
    });

    test(
        'when getFieldErrorMessage is called with invalid key then it should return null',
        () {
      final testClass = instantiate();

      expect(testClass.getFieldErrorMessage('d'), null);
    });
  });

  group('when isFormValid is called', () {
    test('and form is valid then it should return true', () async {
      final testClass = instantiate();

      testClass.inputMap['a'] = await testClass.inputMap['a']!.validateItem();
      testClass.inputMap['b'] =
          await testClass.inputMap['b']!.updateValue('cde').validateItem();
      testClass.inputMap['c'] = await testClass.inputMap['c']!.validateItem();

      expect(testClass.isFormValid, true);
    });

    test('and form is invalid then it should return false', () async {
      when(testValidator.validate('')).thenAnswer(
        (_) async => const ValidatorResult(
          isValid: false,
          errorMessage: 'mandatory field error',
        ),
      );
      final testClass = instantiate();

      testClass.inputMap['a'] = await testClass.inputMap['a']!.validateItem();
      testClass.inputMap['b'] = await testClass.inputMap['b']!.validateItem();
      testClass.inputMap['c'] = await testClass.inputMap['c']!.validateItem();

      expect(testClass.isFormValid, false);
    });
  });
}
