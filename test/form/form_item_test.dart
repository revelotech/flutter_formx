import 'package:flutter_formx/flutter_formx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'form_item_test.mocks.dart';

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

  FormItem<String> instantiate({
    String? value,
    List<Validator>? validators,
  }) =>
      FormItem<String>.from(
        value: value ?? '',
        validators: validators ?? const [],
      );

  test(
      'when updateValue is called then it should return a '
      'new FormItem with the new value keeping all other properties', () {
    final item = instantiate();

    final result = item.updateValue('123');

    expect(item == result, false);
    expect(result == FormItem.from(value: '123', validators: const []), true);
  });

  group('when validateItem is called', () {
    test('then it should validate with all the validators inside it', () async {
      final item = instantiate(
        validators: [firstValidator, secondValidator],
      );

      await item.validateItem();
      verify(firstValidator.validate(''));
      verify(secondValidator.validate(''));
    });

    test(
        'and item is valid then it should return an item without error message',
        () async {
      final item = instantiate(
        value: '',
        validators: [firstValidator, secondValidator],
      );

      final result = await item.validateItem();
      expect(result.errorMessage, null);
      expect(result.isValid, true);
    });

    test(
        'and item is not valid then it should return an item with error message and isValid false',
        () async {
      when(firstValidator.validate('')).thenAnswer(
        (_) async =>
            const ValidatorResult(isValid: false, errorMessage: 'error'),
      );
      final item = instantiate(
        validators: [firstValidator, secondValidator],
      );

      final result = await item.validateItem();
      expect(result == item, false);
      expect(result.errorMessage, 'error');
      expect(result.isValid, false);
    });
  });
}
