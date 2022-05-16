import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/remote/number_trivia_remote_data_sources.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(mockHttpClient);
  });

  group("getConcreteNumberTrivia", () {
    const tNumber = 1;

    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
        "should preform a GET request on a URL with number being the endpoint and with application/json header",
        () async {
      final response = MockResponse();
      when(() => response.statusCode).thenReturn(200);
      when(() => response.body).thenReturn('[]');
      when(() => mockHttpClient.get(any())).thenAnswer((_) async => response);

      try {
        await dataSource.getConcreteNumberTrivia(tNumber);
      } catch (_) {}
      verify(() => mockHttpClient.get(
          Uri.parse("http://numbersapi.com/$tNumber"),
          headers: {'Content-Type': 'application/json'})).called(1);
    });

    test("should return numberTrivia when response 200", () async {
      final response = MockResponse();
      final data = fixture('trivia.json');
      final uri = Uri.parse('http://numbersapi.com/$tNumber');

      print("data $data");
      when(() => response.statusCode).thenReturn(200);
      when(() => response.body).thenReturn(data);
      when(() => mockHttpClient
              .get(uri, headers: {'Content-Type': 'application/json'}))
          .thenAnswer((_) async => response);

      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      expect(
          result,
          isA<NumberTriviaModel>()
              .having((t) => t.text, "text", "Test Text")
              .having((t) => t.number, "number", 1));
      // expect(result, equals(tNumberTriviaModel));
      /*try {
            final result = await dataSource.getConcreteNumberTrivia(tNumber);
            expect(result, equals(tNumberTriviaModel));
          } catch (_) {}*/
    });

    test("should return server exception when response 404", () async {
      final response = MockResponse();
      final uri = Uri.parse('http://numbersapi.com/$tNumber');

      when(() => response.statusCode).thenReturn(400);
      when(() => response.body).thenReturn("[]");
      when(() => mockHttpClient
          .get(uri, headers: {'Content-Type': 'application/json'}))
          .thenAnswer((_) async => response);

      final result = dataSource.getConcreteNumberTrivia(tNumber);
      expect(result, throwsA(isInstanceOf<ServerException>()));
    });
  });

  group("geRandomNumberTrivia", () {

    test(
        "should preform a GET request on a URL with number being the endpoint and with application/json header",
            () async {
          final response = MockResponse();
          when(() => response.statusCode).thenReturn(200);
          when(() => response.body).thenReturn('[]');
          when(() => mockHttpClient.get(any())).thenAnswer((_) async => response);

          try {
            await dataSource.getRandomNumberTrivia();
          } catch (_) {}
          verify(() => mockHttpClient.get(
              Uri.parse("http://numbersapi.com/random"),
              headers: {'Content-Type': 'application/json'})).called(1);
        });

    test("should return numberTrivia when response 200", () async {
      final response = MockResponse();
      final data = fixture('trivia.json');
      final uri = Uri.parse('http://numbersapi.com/random');

      print("data $data");
      when(() => response.statusCode).thenReturn(200);
      when(() => response.body).thenReturn(data);
      when(() => mockHttpClient
          .get(uri, headers: {'Content-Type': 'application/json'}))
          .thenAnswer((_) async => response);

      final result = await dataSource.getRandomNumberTrivia();
      expect(
          result,
          isA<NumberTriviaModel>()
              .having((t) => t.text, "text", "Test Text")
              .having((t) => t.number, "number", 1));
      // expect(result, equals(tNumberTriviaModel));
      /*try {
            final result = await dataSource.getConcreteNumberTrivia(tNumber);
            expect(result, equals(tNumberTriviaModel));
          } catch (_) {}*/
    });

    test("should return server exception when response 404", () async {
      final response = MockResponse();
      final uri = Uri.parse('http://numbersapi.com/random');

      when(() => response.statusCode).thenReturn(400);
      when(() => response.body).thenReturn("[]");
      when(() => mockHttpClient
          .get(uri, headers: {'Content-Type': 'application/json'}))
          .thenAnswer((_) async => response);

      final result = dataSource.getRandomNumberTrivia();
      expect(result, throwsA(isInstanceOf<ServerException>()));
    });
  });
}
