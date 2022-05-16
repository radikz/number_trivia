import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:number_trivia/core/platform/network_info.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/local/number_trivia_local_data_sources.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/remote/number_trivia_remote_data_sources.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia/number_trivia_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;

Future<void> init() async {
  // bloc
  locator.registerFactory(() => NumberTriviaBloc(
      getRandomNumberTrivia: locator(),
      getConcreteNumberTrivia: locator(),
      inputConverter: locator()));

  // repository
  locator.registerLazySingleton<NumberTriviaRepository>(() =>
      NumberTriviaRepositoryImpl(
          localDataSource: locator(),
          remoteDataSource: locator(),
          networkInfo: locator()));

  // use case
  locator.registerLazySingleton(
      () => GetConcreteNumberTrivia(repository: locator()));
  locator.registerLazySingleton(
      () => GetRandomNumberTrivia(repository: locator()));

  // data sources
  locator.registerLazySingleton<NumberTriviaLocalDataSource>(
      () => NumberTriviaLocalDataSourceImpl(sharedPreferences: locator()));
  locator.registerLazySingleton<NumberTriviaRemoteDataSources>(
      () => NumberTriviaRemoteDataSourceImpl(locator()));

  // Core
  locator.registerLazySingleton(() => InputConverter());
  locator.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(locator()));

  // external
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => sharedPreferences);
  locator.registerLazySingleton(() => http.Client());
  locator.registerLazySingleton(() => Connectivity());
}
