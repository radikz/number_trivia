import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/local/number_trivia_local_data_sources.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group("get last number trivia", () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));

    test("should return number trivia when shared preference is not null", () async {
      when(() => mockSharedPreferences.getString(any())).thenReturn(fixture('trivia_cached.json'));

      final result = await dataSource.getLastNumberTrivia();

      verify(() => mockSharedPreferences.getString("CACHED_NUMBER_TRIVIA"));
      // expect(result, isA<NumberTriviaModel>());
      expect(result, equals(tNumberTriviaModel));
    });

    test("should return exception when shared preference is null", () async {
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);

      final result = dataSource.getLastNumberTrivia;
      // expect(() => result(), throwsA(TypeMatcher<CacheException>));
      expect(() => result(), throwsA(isInstanceOf<CacheException>()));

    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel =
    NumberTriviaModel(number: 1, text: 'test trivia');

    test('should call SharedPreferences to cache the data', () {
      // act
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      // assert
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(() => mockSharedPreferences.setString(
        "CACHED_NUMBER_TRIVIA",
        expectedJsonString,
      ));
    });
  });
}
