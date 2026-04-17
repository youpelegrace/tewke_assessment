import 'package:carbon_intensity_dashboard/core/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Success exposes value and reports success', () {
      const Result<int, String> result = Success<int, String>(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect((result as Success<int, String>).value, 42);
    });

    test('FailureResult exposes failure and reports failure', () {
      const Result<int, String> result = FailureResult<int, String>('oops');

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect((result as FailureResult<int, String>).failure, 'oops');
    });

    test('pattern matching is exhaustive', () {
      const Result<int, String> r = Success<int, String>(7);
      final String output = switch (r) {
        Success<int, String>(value: final int v) => 'ok: $v',
        FailureResult<int, String>(failure: final String f) => 'fail: $f',
      };
      expect(output, 'ok: 7');
    });
  });
}
