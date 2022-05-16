import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/usecase/usecase.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

class MockNumberTriviaRepository extends Mock implements NumberTriviaRepository {}
void main(){
  late GetRandomNumberTrivia usecase;
  late NumberTriviaRepository repository;

  setUp((){
    repository = MockNumberTriviaRepository();
    usecase = GetRandomNumberTrivia(repository: repository);
  });

  const number = 1;
  const tNumber = NumberTrivia(text: "text", number: number);

  test("should get trivia for the number from the repository", () async {
    when(() => repository.getRandomNumberTrivia()).thenAnswer((_) async => const Right(tNumber));

    final result = await usecase(NoParams());
    expect(result, const Right(tNumber));
    verify(() => repository.getRandomNumberTrivia());
    verifyNoMoreInteractions(repository);

  });
}