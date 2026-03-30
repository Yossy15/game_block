import 'package:block/data/services/online_room_api_service.dart';
import 'package:block/domain/models/online_room.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'online_room_repository.g.dart';

class OnlineRoomRepository {
  const OnlineRoomRepository(this._apiService);

  final OnlineRoomApiService _apiService;

  Future<OnlineRoomSession> createRoom({
    required String playerName,
    int? durationSeconds,
  }) {
    return _apiService.createRoom(
      playerName: playerName,
      durationSeconds: durationSeconds,
    );
  }

  Future<OnlineRoomSession> joinRoom({
    required String roomCode,
    required String playerName,
  }) {
    return _apiService.joinRoom(roomCode: roomCode, playerName: playerName);
  }

  Future<OnlineRoom> getRoom({required String roomCode}) {
    return _apiService.getRoom(roomCode: roomCode);
  }
}

@riverpod
OnlineRoomRepository onlineRoomRepository(Ref ref) {
  final apiService = ref.watch(onlineRoomApiServiceProvider);
  return OnlineRoomRepository(apiService);
}
