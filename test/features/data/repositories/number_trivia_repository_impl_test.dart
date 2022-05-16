import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:number_trivia/core/error/exception.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/platform/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/local/number_trivia_local_data_sources.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/remote/number_trivia_remote_data_sources.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

class MockNumberTriviaRemoteDataSources extends Mock
    implements NumberTriviaRemoteDataSources {}

class MockNumberTriviaLocalDataSource extends Mock
    implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockNumberTriviaRemoteDataSources mockRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockNumberTriviaRemoteDataSources();
    mockLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.connectivityResult).thenAnswer((_) async => ConnectivityResult.wifi);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.connectivityResult).thenAnswer((_) async => ConnectivityResult.none);
      });

      body();
    });
  }

  group("getConcreteNumberTrivia", () {
    const tNumber = 1;
    const tNumberTriviaModel =
        NumberTriviaModel(number: tNumber, text: 'test trivia');
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('should check if the device is online', () async {
      //arrange
      when(() => mockNetworkInfo.connectivityResult).thenAnswer((_) async => ConnectivityResult.mobile);
      when(() => mockRemoteDataSource.getConcreteNumberTrivia(any())).thenAnswer((_) async => tNumberTriviaModel);
      when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future.value());
      // act
      await repository.getNumberTrivia(tNumber);
      // assert
      verify(() => mockNetworkInfo.connectivityResult);
    });

    runTestsOnline(() {
      test(
          'should return remote data when the call to remote data source is successful',
              () async {
            // arrange
            when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
                .thenAnswer((_) async => tNumberTriviaModel);
            when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future.value());
            // act
            final result = await repository.getNumberTrivia(tNumber);
            // assert
            verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            expect(result, equals(const Right(tNumberTrivia)));
          });

      test(
          'should cache the data locally when the call to remote data source is successful',
              () async {
            // arrange
            when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
                .thenAnswer((_) async => tNumberTriviaModel);
            when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).thenAnswer((_) async => Future.value());
            // act
            await repository.getNumberTrivia(tNumber);
            // assert
            verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
            // final model = tNumberTrivia as NumberTrivia;
            verify(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel)).called(1);
          });

      test(
        'should return server failure when the call to remote data source is unsuccessful',
            () async {
          // arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .thenThrow(ServerException());
          // act
          final result = await repository.getNumberTrivia(tNumber);
          // assert
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          // verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful (no internet)',
            () async {
          // arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .thenThrow(SocketException("da"));
          // act
          final result = await repository.getNumberTrivia(tNumber);
          // assert
          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
          // verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline((){
      test(
        'should return last locally cached data when the cached data is present',
            () async {
          // arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
            () async {
          // arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());
          // act
          final result = await repository.getRandomNumberTrivia();
          // assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
