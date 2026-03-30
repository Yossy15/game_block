import 'package:block/domain/models/online_room.dart';
import 'package:flutter/foundation.dart';

@immutable
class OnlineMatchState {
  const OnlineMatchState({
    this.isLoading = true,
    this.room,
    this.errorMessage,
    this.roomDeleted = false,
  });

  final bool isLoading;
  final OnlineRoom? room;
  final String? errorMessage;
  final bool roomDeleted;

  OnlineRoomMatch? get match => room?.currentMatch;

  OnlineMatchState copyWith({
    bool? isLoading,
    OnlineRoom? room,
    String? errorMessage,
    bool clearError = false,
    bool? roomDeleted,
    bool clearRoom = false,
  }) {
    return OnlineMatchState(
      isLoading: isLoading ?? this.isLoading,
      room: clearRoom ? null : (room ?? this.room),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      roomDeleted: roomDeleted ?? this.roomDeleted,
    );
  }
}
