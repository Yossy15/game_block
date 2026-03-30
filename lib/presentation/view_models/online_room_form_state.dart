import 'package:block/domain/models/online_room.dart';
import 'package:flutter/foundation.dart';

@immutable
class OnlineRoomFormState {
  const OnlineRoomFormState({
    this.isLoading = false,
    this.errorMessage,
    this.session,
    this.isUnlimitedTime = false,
    this.durationMinutes = '5',
  });

  final bool isLoading;
  final String? errorMessage;
  final OnlineRoomSession? session;
  final bool isUnlimitedTime;
  final String durationMinutes;

  OnlineRoomFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    OnlineRoomSession? session,
    bool clearSession = false,
    bool? isUnlimitedTime,
    String? durationMinutes,
  }) {
    return OnlineRoomFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      session: clearSession ? null : (session ?? this.session),
      isUnlimitedTime: isUnlimitedTime ?? this.isUnlimitedTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}
