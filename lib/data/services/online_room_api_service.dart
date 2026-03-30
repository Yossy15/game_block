import 'package:block/domain/models/online_room.dart';
import 'package:dio/dio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:block/core/network/dio_client.dart';

part 'online_room_api_service.g.dart';

class OnlineRoomApiService {
  const OnlineRoomApiService(this._dio);

  final Dio _dio;

  Future<OnlineRoomSession> createRoom({
    required String playerName,
    int? durationSeconds,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/rooms',
      data: {
        'name': playerName,
        'durationSeconds': durationSeconds,
      },
    );

    return OnlineRoomSession.fromJson(response.data!);
  }

  Future<OnlineRoomSession> joinRoom({
    required String roomCode,
    required String playerName,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/rooms/join',
      data: {
        'roomCode': roomCode,
        'name': playerName,
      },
    );

    return OnlineRoomSession.fromJson(response.data!);
  }

  Future<OnlineRoom> getRoom({required String roomCode}) async {
    final response = await _dio.get<Map<String, dynamic>>('/rooms/$roomCode');
    return OnlineRoom.fromJson(response.data!);
  }
}

@riverpod
OnlineRoomApiService onlineRoomApiService(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  return OnlineRoomApiService(dio);
}
