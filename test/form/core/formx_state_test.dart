import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'formx_state_test.mocks.dart';

class TestValidator extends Validator<String?> {
  @override
  Future<ValidatorResult> validate(String? value) => Future.value(ValidatorResult.success());
}

@GenerateMocks([TestValidator])
void main() {
  late MockTestValidator testValidator;
  final Map<String, FormXField<String>> testMap = {
    'a': FormXField<String>.from(value: 'abc', validators: const []),
    'b': FormXField<String>.from(value: '', validators: const []),
    'c': FormXField<String>.from(value: '', validators: const []),
  };

  setUp(() {
    testValidator = MockTestValidator();

    when(testValidator.validate(any)).thenAnswer((_) async => ValidatorResult.success());
  });

  FormXState instantiate([Map<String, FormXField<String>>? inputMap]) =>
      FormXState(inputMap ?? testMap);

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
    test('when getFieldErrorMessage is called then it should return it', () async {
      when(testValidator.validate('')).thenAnswer(
        (_) async => const ValidatorResult(
          isValid: false,
          errorMessage: 'mandatory field error',
        ),
      );

      final fieldA = await FormXField<String>.from(
        value: 'abc',
        validators: const [],
      ).validateItem();
      final fieldB = await FormXField<String>.from(
        value: '',
        validators: [testValidator],
      ).validateItem();

      final testClass = instantiate({'a': fieldA, 'b': fieldB});

      expect(testClass.getFieldErrorMessage('a'), null);
      expect(testClass.getFieldErrorMessage('b'), 'mandatory field error');
    });

    test('when getFieldErrorMessage is called with invalid key then it should return null', () {
      final testClass = instantiate();

      expect(testClass.getFieldErrorMessage('d'), null);
    });
  });

  group('when isFormValid is called', () {
    test('and form is valid then it should return true', () async {
      final fieldA = await FormXField<String>.from(
        value: 'abc',
        validators: const [],
      ).validateItem();
      final fieldB = await FormXField<String>.from(
        value: '',
        validators: const [],
      ).validateItem();

      final testClass = instantiate({'a': fieldA, 'b': fieldB});

      expect(testClass.isFormValid, true);
    });

    test('and form is invalid then it should return false', () async {
      when(testValidator.validate('')).thenAnswer(
        (_) async => const ValidatorResult(
          isValid: false,
          errorMessage: 'mandatory field error',
        ),
      );

      final fieldA = await FormXField<String>.from(
        value: 'abc',
        validators: const [],
      ).validateItem();
      final fieldB = await FormXField<String>.from(
        value: '',
        validators: [testValidator],
      ).validateItem();

      final testClass = instantiate({'a': fieldA, 'b': fieldB});

      expect(testClass.isFormValid, false);
    });
  });
}
