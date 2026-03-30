import 'dart:async';

import 'package:block/data/repositories/online_room_repository.dart';
import 'package:block/data/services/online_room_socket_service.dart';
import 'package:block/presentation/view_models/online_room_lobby_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'online_room_lobby_view_model.g.dart';

@riverpod
class OnlineRoomLobbyViewModel extends _$OnlineRoomLobbyViewModel {
  @override
  OnlineRoomLobbyState build(String roomCode, String playerId) {
    Future.microtask(() async {
      await _initialize(roomCode: roomCode, playerId: playerId);
    });

    return const OnlineRoomLobbyState();
  }

  Future<void> _initialize({
    required String roomCode,
    required String playerId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      restStatus: 'REST loading room...',
      socketStatus: 'Socket waiting...',
      attachStatus: 'Attach waiting...',
    );

    try {
      final room = await ref.read(onlineRoomRepositoryProvider).getRoom(roomCode: roomCode);
      state = state.copyWith(
        isLoading: false,
        room: room,
        restStatus: 'REST connected',
      );

      final socketService = ref.read(onlineRoomSocketServiceProvider);
      socketService.connect(
        onConnected: () {
          state = state.copyWith(
            socketStatus: 'Socket connected',
            attachStatus: 'Attaching room...',
          );
          socketService.attachRoom(
            roomCode: roomCode,
            playerId: playerId,
            onAttached: (attachedRoom) {
              state = state.copyWith(
                room: attachedRoom,
                isLoading: false,
                clearError: true,
                attachStatus: 'Attach room success',
              );
            },
            onError: (message) {
              state = state.copyWith(
                errorMessage: message,
                isLoading: false,
                attachStatus: 'Attach failed: $message',
              );
            },
          );
        },
        onRoomUpdated: (updatedRoom) {
          state = state.copyWith(
            room: updatedRoom,
            isLoading: false,
            clearError: true,
            socketStatus: 'Socket connected',
          );
        },
        onMatchStarted: (updatedRoom) {
          state = state.copyWith(
            room: updatedRoom,
            isLoading: false,
            isStarting: false,
            clearError: true,
            pendingMatchId: updatedRoom.currentMatch?.matchId,
            socketStatus: 'Socket connected',
            attachStatus: 'Attach room success',
          );
        },
        onError: (message) {
          state = state.copyWith(
            errorMessage: message,
            isLoading: false,
            isStarting: false,
            socketStatus: 'Socket error: $message',
          );
        },
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load room.',
        restStatus: 'REST failed',
      );
    }
  }

  Future<bool> leaveRoom({
    required String roomCode,
    required String playerId,
  }) async {
    state = state.copyWith(isLeaving: true, clearError: true);
    final completer = Completer<bool>();

    ref.read(onlineRoomSocketServiceProvider).leaveRoom(
      roomCode: roomCode,
      playerId: playerId,
      onLeft: () {
        state = state.copyWith(isLeaving: false);
        completer.complete(true);
      },
      onError: (message) {
        state = state.copyWith(isLeaving: false, errorMessage: message);
        completer.complete(false);
      },
    );

    return completer.future;
  }

  Future<bool> startMatch({
    required String roomCode,
    required String playerId,
  }) async {
    state = state.copyWith(isStarting: true, clearError: true);
    final completer = Completer<bool>();

    ref.read(onlineRoomSocketServiceProvider).startMatch(
      roomCode: roomCode,
      playerId: playerId,
      onStarted: (room) {
        state = state.copyWith(
          room: room,
          isStarting: false,
          pendingMatchId: room.currentMatch?.matchId,
        );
        completer.complete(true);
      },
      onError: (message) {
        state = state.copyWith(isStarting: false, errorMessage: message);
        completer.complete(false);
      },
    );

    return completer.future;
  }

  void consumePendingMatchNavigation() {
    state = state.copyWith(clearPendingMatch: true);
  }
}
