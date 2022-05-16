import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecase/usecase.dart';
import 'package:number_trivia/core/util/constants.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
  });

  NumberTriviaBloc buildBloc() => NumberTriviaBloc(
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        inputConverter: mockInputConverter,
      );

  test("initial bloc", () {
    final bloc = buildBloc();
    expect(bloc.state, NumberTriviaEmpty());
  });

  group("get concrete number", () {
    const tNumberString = '1';
    // This is the successful output of the InputConverter
    final tNumberParsed = int.parse(tNumberString);
    // NumbFlutter TDD Clean Architecture Course [11]umberTrivia = NumberTrivia(number: 1, text: 'test trivia');
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "should emit [Error] when the input is invalid",
        build: () => buildBloc(),
        setUp: () {
          when(() => mockInputConverter.stringToUnsignedInteger("-123"))
              .thenReturn(Left(InvalidInputFailure()));
        },
        act: (bloc) => bloc.add(GetTriviaForConcreteNumber("-123")),
        seed: () => NumberTriviaEmpty(),
        expect: () => [
              NumberTriviaLoading(),
              const NumberTriviaError(message: Constants.invalidInputMessage),
            ]);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "should emit [Failure] when the failed get trivia",
        build: () => buildBloc(),
        setUp: () {
          when(() => mockInputConverter.stringToUnsignedInteger(tNumberString))
              .thenReturn(Right(tNumberParsed));
          when(() => mockGetConcreteNumberTrivia(Params(number: tNumberParsed))).thenAnswer((_) async => Left(ServerFailure()));
        },
        act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
        seed: () => NumberTriviaEmpty(),
        expect: () => [
          NumberTriviaLoading(),
          const NumberTriviaError(message: Constants.serverFailureMessage)
        ]);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "should emit [Trivia] when the success get trivia",
        build: () => buildBloc(),
        setUp: () {
          when(() => mockInputConverter.stringToUnsignedInteger(tNumberString))
              .thenReturn(Right(tNumberParsed));
          when(() => mockGetConcreteNumberTrivia(Params(number: tNumberParsed))).thenAnswer((_) async => const Right(tNumberTrivia));
        },
        act: (bloc) => bloc.add(GetTriviaForConcreteNumber(tNumberString)),
        seed: () => NumberTriviaEmpty(),
        expect: () => [
          NumberTriviaLoading(),
          const NumberTriviaLoaded(trivia: tNumberTrivia),
        ]);
  });

  group("get random number", () {
    // NumbFlutter TDD Clean Architecture Course [11]umberTrivia = NumberTrivia(number: 1, text: 'test trivia');
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "random number should emit [Failure] when the failed get trivia",
        build: () => buildBloc(),
        setUp: () {
          when(() => mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => Left(ServerFailure()));
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        seed: () => NumberTriviaEmpty(),
        expect: () => [
          NumberTriviaLoading(),
          const NumberTriviaError(message: Constants.serverFailureMessage)
        ]);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "random number should emit [Failure] when failed getting cache trivia",
        build: () => buildBloc(),
        setUp: () {
          when(() => mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => Left(CacheFailure()));
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        seed: () => NumberTriviaEmpty(),
        expect: () => [
          NumberTriviaLoading(),
          const NumberTriviaError(message: Constants.cacheFailureMessage)
        ]);

    blocTest<NumberTriviaBloc, NumberTriviaState>(
        "should emit [Trivia] when the success get trivia",
        build: () => buildBloc(),
        setUp: () {
          when(() => mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => const Right(tNumberTrivia));
        },
        act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
        seed: () => NumberTriviaEmpty(),
        expect: () => [
          NumberTriviaLoading(),
          const NumberTriviaLoaded(trivia: tNumberTrivia),
        ]);
  });
}
