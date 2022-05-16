import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../fixtures/fixture_reader.dart';

void main() {
  const tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');

  group('fromJson', () {
    test('should return a valid model when the JSON number is an integer',
        () async {
      // arrange
      final Map<String, dynamic> json = jsonDecode(fixture('trivia.json'));

      //act
      final result = NumberTriviaModel.fromJson(json);

      //assert
      expect(result, tNumberTriviaModel);
    });

    test(
        'should return a valid model when the JSON number is regarded as a double',
        () async {
      // arrange
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('trivia_double.json'));
      // act
      final result = NumberTriviaModel.fromJson(jsonMap);
      // assert
      expect(result, tNumberTriviaModel);
    });
  });

  group('toJson', () {
    test(
      'should return a JSON map containing the proper data',
          () async {
        // act
        final result = tNumberTriviaModel.toJson();
        // assert
        final expectedJsonMap = {
          "text": "Test Text",
          "number": 1,
        };
        expect(result, expectedJsonMap);
      },
    );
  });
}
