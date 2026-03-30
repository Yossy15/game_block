import 'package:block/domain/models/online_room.dart';
import 'package:flutter/foundation.dart';

@immutable
class OnlineRoomLobbyState {
  const OnlineRoomLobbyState({
    this.isLoading = true,
    this.isLeaving = false,
    this.isStarting = false,
    this.room,
    this.errorMessage,
    this.pendingMatchId,
    this.restStatus = 'REST pending',
    this.socketStatus = 'Socket pending',
    this.attachStatus = 'Attach pending',
  });

  final bool isLoading;
  final bool isLeaving;
  final bool isStarting;
  final OnlineRoom? room;
  final String? errorMessage;
  final String? pendingMatchId;
  final String restStatus;
  final String socketStatus;
  final String attachStatus;

  OnlineRoomLobbyState copyWith({
    bool? isLoading,
    bool? isLeaving,
    bool? isStarting,
    OnlineRoom? room,
    String? errorMessage,
    bool clearError = false,
    String? pendingMatchId,
    bool clearPendingMatch = false,
    String? restStatus,
    String? socketStatus,
    String? attachStatus,
  }) {
    return OnlineRoomLobbyState(
      isLoading: isLoading ?? this.isLoading,
      isLeaving: isLeaving ?? this.isLeaving,
      isStarting: isStarting ?? this.isStarting,
      room: room ?? this.room,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingMatchId: clearPendingMatch
          ? null
          : (pendingMatchId ?? this.pendingMatchId),
      restStatus: restStatus ?? this.restStatus,
      socketStatus: socketStatus ?? this.socketStatus,
      attachStatus: attachStatus ?? this.attachStatus,
    );
  }
}
