import 'dart:math';

import 'package:clean_architecture_tdd/core/error/failures.dart';
import 'package:clean_architecture_tdd/core/usecases/usecase.dart';
import 'package:clean_architecture_tdd/core/util/input_converter.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'number_trivia_bloc_test.mocks.dart';

// flutter pub run build_runner build
@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;
  
  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    
    bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia, 
        getRandomNumberTrivia: mockGetRandomNumberTrivia, 
        inputConverter: mockInputConverter);
  });
  
  test('initialState should be empty', () {
    expect(bloc.state, equals(Empty()));
  });
  
  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setupMockInputConverterSuccess() => when(mockInputConverter.stringToUnsignedInteger(any))
        .thenReturn(const Right(tNumberParsed));

    test('should call the InputConverter to validate and convert the string to an unsigned integer', () async {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)))
          .thenAnswer((realInvocation) async => const Right(tNumberTrivia));
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));

      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    // The brackets around a word means that it's a state, in this case,
    // is an Error state
    test('should emit [Error] when the input is invalid', () async {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));

      const expected = Error(message: invalidInputFailureMessage);
      // expectLater waits for some time to the expected events
      expectLater(bloc.stream , emits(expected));

      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the concrete use case', () async {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
      .thenAnswer((realInvocation) async => const Right(tNumberTrivia));

      bloc.add(const GetTriviaForConcreteNumber(tNumberString));

      await untilCalled(mockGetConcreteNumberTrivia(any));

      verify(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully', () async {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
      .thenAnswer((realInvocation) async => const Right(tNumberTrivia));

      final expected = [
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [Loading, Error] when getting data fails', () async {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((realInvocation) async => Left(ServerFailure()));

      final expected = [
        Loading(),
        const Error(message: serverFailureMessage),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [Loading, Error] with a proper message for the error when getting data fails', () async {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((realInvocation) async => Left(CacheFailure()));

      final expected = [
        Loading(),
        const Error(message: cacheFailureMessage),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test('should get data from the random use case', () async {
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((realInvocation) async => const Right(tNumberTrivia));

      bloc.add(GetTriviaForRandomNumber());

      await untilCalled(mockGetRandomNumberTrivia(any));

      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully', () async {
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((realInvocation) async => const Right(tNumberTrivia));

      final expected = [
        Loading(),
        const Loaded(trivia: tNumberTrivia),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(GetTriviaForRandomNumber());
    });

    test('should emit [Loading, Error] when getting data fails', () async {
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((realInvocation) async => Left(ServerFailure()));

      final expected = [
        Loading(),
        const Error(message: serverFailureMessage),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(GetTriviaForRandomNumber());
    });

    test('should emit [Loading, Error] with a proper message for the error when getting data fails', () async {
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((realInvocation) async => Left(CacheFailure()));

      final expected = [
        Loading(),
        const Error(message: cacheFailureMessage),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(GetTriviaForRandomNumber());
    });
  });

}