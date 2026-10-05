import 'package:flutter_test/flutter_test.dart';
import 'package:smartday/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateTitle rejects empty and whitespace-only strings', () {
      expect(Validators.validateTitle(null), isNotNull);
      expect(Validators.validateTitle(''), isNotNull);
      expect(Validators.validateTitle('   '), isNotNull);
    });

    test('validateTitle rejects single character title', () {
      expect(Validators.validateTitle('A'), isNotNull);
    });

    test('validateTitle accepts valid titles', () {
      expect(Validators.validateTitle('Submit Project'), isNull);
      expect(Validators.validateTitle('Go to Gym'), isNull);
    });

    test('validateDescription handles limits properly', () {
      expect(Validators.validateDescription(null), isNull);
      expect(Validators.validateDescription('Short description'), isNull);
      final longDesc = 'A' * 501;
      expect(Validators.validateDescription(longDesc), isNotNull);
    });

    test('validateCategoryName validates length correctly', () {
      expect(Validators.validateCategoryName(null), isNotNull);
      expect(Validators.validateCategoryName(''), isNotNull);
      expect(Validators.validateCategoryName('Fitness'), isNull);
      final tooLong = 'A' * 31;
      expect(Validators.validateCategoryName(tooLong), isNotNull);
    });
  });
}
