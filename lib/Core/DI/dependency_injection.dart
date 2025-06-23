// import 'package:dio/dio.dart';

// import 'package:get_it/get_it.dart';

// final getIt = GetIt.instance;
// Future<void> setUpGetIt() async {
//   Dio dio = DioFactory.getDio();
//   getIt.registerLazySingleton<ApiService>(() => ApiService(dio));
//   getIt.registerLazySingleton<LoginRepo>(() => LoginRepo(getIt()));
//   getIt.registerLazySingleton<LoginCubit>(() => LoginCubit(getIt()));
//   getIt.registerFactory<SignUpCubit>(() => SignUpCubit());
// }
