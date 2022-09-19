import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clean_architecture_tdd/core/error/failures.dart';
import 'package:clean_architecture_tdd/core/usecases/usecase.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/util/input_converter.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailureMessage =
    'Invalid Input - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc(
      {required this.getConcreteNumberTrivia,
      required this.getRandomNumberTrivia,
      required this.inputConverter})
      : super(Empty()) {
    on<NumberTriviaEvent>(
      (event, emit) async {
        if (event is GetTriviaForConcreteNumber) {
          final inputEither =
              inputConverter.stringToUnsignedInteger(event.numberString);
          await inputEither.fold(
            (failure) async => {
              emit(
                const Error(message: invalidInputFailureMessage),
              ),
            },
            (integer) async {
              emit(Loading());
              final failureOrTrivia = await getConcreteNumberTrivia(
                Params(number: integer),
              );
              _eitherLoadedOrErrorState(failureOrTrivia, emit);
            },
          );
        } else if (event is GetTriviaForRandomNumber) {
          emit(Loading());
          final failureOrTrivia = await getRandomNumberTrivia(
            NoParams(),
          );
          _eitherLoadedOrErrorState(failureOrTrivia, emit);
        }
      },
    );
  }

  void _eitherLoadedOrErrorState(Either<Failure, NumberTrivia> failureOrTrivia,
      Emitter<NumberTriviaState> emit) {
    failureOrTrivia.fold(
      (failure) => emit(
        Error(
          message: _mapFailureToMessage(failure),
        ),
      ),
      (trivia) => emit(
        Loaded(trivia: trivia),
      ),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return serverFailureMessage;
      case CacheFailure:
        return cacheFailureMessage;
      default:
        return 'Unexpected error';
    }
  }
}
