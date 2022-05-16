import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/core/util/input_converter.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  test("should return a failure when the string is not an integer", () {
    // arrange
    const str = 'abc';
    // act
    final result = inputConverter.stringToUnsignedInteger(str);
    // assert
    expect(result, Left(InvalidInputFailure()));
  });

  test(
    'should return a failure when the string is a negative integer',
        () async {
      // arrange
      const str = '-123';
      // act
      final result = inputConverter.stringToUnsignedInteger(str);
      // assert
      expect(result, Left(InvalidInputFailure()));
    },
  );
}
