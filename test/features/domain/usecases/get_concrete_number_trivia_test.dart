import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';


class MockNumberTriviaRepository extends Mock implements NumberTriviaRepository {}
void main(){
  late GetConcreteNumberTrivia usecase;
  late MockNumberTriviaRepository repository;

  setUp(() {
    repository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(repository: repository);
  });

  const number = 1;
  const tNumber = NumberTrivia(text: "text", number: number);

  test('should get trivia for the number from the repository', () async {
    when(() => repository.getNumberTrivia(any())).thenAnswer((_) async => const Right(tNumber));
    // The "act" phase of the test. Call the not-yet-existent method.
    final result = await usecase(const Params(number: number));
    // UseCase should simply return whatever was returned from the Repository
    expect(result, const Right(tNumber));
    // Verify that the method has been called on the Repository
    verify(() => repository.getNumberTrivia(number));
    // Only the above method should be called and nothing more.
    verifyNoMoreInteractions(repository);
  });
}