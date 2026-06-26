import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:lend/core/mixins/textfields.mixin.dart';

void main() {
  final validator = _TextFieldValidator();

  group('TextFieldsMixin', () {
    test('validateField rejects empty values and accepts trimmed text', () {
      expect(
        validator.validateField('', label: 'First name'),
        'First name is required',
      );
      expect(
        validator.validateField('   ', label: 'First name'),
        'First name is required',
      );
      expect(validator.validateField(' Ada ', label: 'First name'), isNull);
    });

    test('validateEmail rejects empty and invalid emails', () {
      expect(validator.validateEmail(''), 'Email is required');
      expect(
        validator.validateEmail('not-an-email'),
        'Please enter a valid email',
      );
      expect(validator.validateEmail(' ada@example.com '), isNull);
    });

    test('validateDateOfBirth rejects empty and invalid dates', () {
      expect(validator.validateDateOfBirth(''), 'Date of birth is required');
      expect(
        validator.validateDateOfBirth('not-a-date'),
        'Select a valid date of birth',
      );
    });

    test('validateDateOfBirth enforces adult age', () {
      final under18 = DateTime.now().subtract(const Duration(days: 365 * 17));
      final adult = DateTime.now().subtract(const Duration(days: 365 * 20));
      final formatter = DateFormat('MMMM dd, yyyy');

      expect(
        validator.validateDateOfBirth(formatter.format(under18)),
        'You must be at least 18 years old',
      );
      expect(validator.validateDateOfBirth(formatter.format(adult)), isNull);
    });
  });
}

class _TextFieldValidator with TextFieldsMixin {}
