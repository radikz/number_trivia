import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecase/usecase.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../../core/util/constants.dart';
import '../../../../../core/util/input_converter.dart';
import '../../../domain/usecases/get_concrete_number_trivia.dart';
import '../../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';

part 'number_trivia_state.dart';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  NumberTriviaBloc(
      {required this.getRandomNumberTrivia,
      required this.getConcreteNumberTrivia,
      required this.inputConverter})
      : super(NumberTriviaEmpty()) {
    on<GetTriviaForConcreteNumber>(_onGetTriviaForConcreteNumber);
    on<GetTriviaForRandomNumber>(_onGetTriviaForRandomNumber);
  }

  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  Future<void> _onGetTriviaForConcreteNumber(
    GetTriviaForConcreteNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(NumberTriviaLoading());
    final inputEither =
        inputConverter.stringToUnsignedInteger(event.numberString);

    await inputEither.fold((failure) {
      emit(const NumberTriviaError(message: Constants.invalidInputMessage));
    }, (integer) async {
      final failureOrTrivia =
          await getConcreteNumberTrivia(Params(number: integer));

      failureOrTrivia.fold(
          (failure) => emit(
              const NumberTriviaError(message: Constants.serverFailureMessage)),
          (trivia) => emit(NumberTriviaLoaded(trivia: trivia)));
    });
  }

  Future<void> _onGetTriviaForRandomNumber(
    GetTriviaForRandomNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(NumberTriviaLoading());

    final failureOrTrivia = await getRandomNumberTrivia(NoParams());

    failureOrTrivia.fold((failure) {
      if (failure is CacheFailure) {
        emit(const NumberTriviaError(message: Constants.cacheFailureMessage));
      } else {
        emit(const NumberTriviaError(message: Constants.serverFailureMessage));
      }
    }, (trivia) => emit(NumberTriviaLoaded(trivia: trivia)));
  }
}
