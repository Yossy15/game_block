import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

//const apiBaseUrlOld = 'https://socket-production-66ed.up.railway.app';

const apiBaseUrl = 'https://socket-x98z.onrender.com';

@riverpod
Dio dioClient(Ref ref) {
  return Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {'Content-Type': 'application/json'},
    ),
  );
}
