import 'package:block/data/repositories/online_room_repository.dart';
import 'package:block/data/services/online_room_socket_service.dart';
import 'package:block/presentation/view_models/online_match_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'online_match_view_model.g.dart';

@riverpod
class OnlineMatchViewModel extends _$OnlineMatchViewModel {
  int? _lastSubmittedScore;

  @override
  OnlineMatchState build(String roomCode, String playerId) {
    Future.microtask(() async {
      await _initialize(roomCode: roomCode, playerId: playerId);
    });

    return const OnlineMatchState();
  }

  Future<void> _initialize({
    required String roomCode,
    required String playerId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final room = await ref.read(onlineRoomRepositoryProvider).getRoom(roomCode: roomCode);
      state = state.copyWith(isLoading: false, room: room);

      final socketService = ref.read(onlineRoomSocketServiceProvider);
      socketService.connect(
        onConnected: () {
          socketService.attachRoom(
            roomCode: roomCode,
            playerId: playerId,
            onAttached: (attachedRoom) {
              state = state.copyWith(room: attachedRoom, isLoading: false, clearError: true);
            },
            onError: (message) {
              state = state.copyWith(errorMessage: message, isLoading: false);
            },
          );
        },
        onRoomUpdated: (updatedRoom) {
          state = state.copyWith(
            room: updatedRoom,
            isLoading: false,
            clearError: true,
            roomDeleted: false,
          );
        },
        onMatchStarted: (updatedRoom) {
          state = state.copyWith(
            room: updatedRoom,
            isLoading: false,
            clearError: true,
            roomDeleted: false,
          );
        },
        onMatchUpdated: (updatedRoom) {
          state = state.copyWith(
            room: updatedRoom,
            isLoading: false,
            clearError: true,
            roomDeleted: false,
          );
        },
        onMatchFinished: (updatedRoom) {
          state = state.copyWith(
            room: updatedRoom,
            isLoading: false,
            clearError: true,
            roomDeleted: false,
          );
        },
        onRoomDeleted: (deletedRoomCode) {
          if (deletedRoomCode == roomCode) {
            state = state.copyWith(
              isLoading: false,
              roomDeleted: true,
              clearRoom: true,
            );
          }
        },
        onError: (message) {
          state = state.copyWith(errorMessage: message, isLoading: false);
        },
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load online match.',
      );
    }
  }

  void submitScore({
    required String roomCode,
    required String playerId,
    required int score,
    bool force = false,
  }) {
    if (!force && _lastSubmittedScore == score) {
      return;
    }

    _lastSubmittedScore = score;
    ref.read(onlineRoomSocketServiceProvider).updateMatchScore(
      roomCode: roomCode,
      playerId: playerId,
      score: score,
      onUpdated: (updatedRoom) {
        state = state.copyWith(room: updatedRoom, clearError: true, roomDeleted: false);
      },
      onError: (message) {
        state = state.copyWith(errorMessage: message);
      },
    );
  }

  void completeRun({
    required String roomCode,
    required String playerId,
    required int score,
  }) {
    _lastSubmittedScore = score;
    ref.read(onlineRoomSocketServiceProvider).completeMatchRun(
      roomCode: roomCode,
      playerId: playerId,
      score: score,
      onUpdated: (updatedRoom) {
        state = state.copyWith(room: updatedRoom, clearError: true, roomDeleted: false);
      },
      onError: (message) {
        state = state.copyWith(errorMessage: message);
      },
    );
  }
}
