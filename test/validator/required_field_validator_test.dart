import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_formx/src/validator/required_field_validator.dart';

void main() {
  late RequiredFieldValidator validator;
  const errorMessage = 'This field is required';

  setUp(() {
    validator = RequiredFieldValidator(errorMessage);
  });

  test('when validate is called with null then it should return invalid result',
      () async {
    final result = await validator.validate(null);

    expect(result.isValid, false);
    expect(result.errorMessage, errorMessage);
  });

  test(
      'when validate is called with empty string then it should return invalid result',
      () async {
    final result = await validator.validate('');

    expect(result.isValid, false);
    expect(result.errorMessage, errorMessage);
  });

  test(
      'when validate is called with string with only white spaces then it should return invalid result',
      () async {
    final result = await validator.validate('                 ');

    expect(result.isValid, false);
    expect(result.errorMessage, errorMessage);
  });

  test(
      'when validate is called with non-null object then it should return valid result',
      () async {
    final today = DateTime.now();
    final result = await validator.validate(today);

    expect(result.isValid, true);
    expect(result.errorMessage, null);
  });

  test(
      'when validate is called with non-empty string then it should return valid result',
      () async {
    final result = await validator.validate('Some input');

    expect(result.isValid, true);
    expect(result.errorMessage, null);
  });
}
