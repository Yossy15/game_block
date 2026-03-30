import 'package:block/data/repositories/online_room_repository.dart';
import 'package:block/presentation/view_models/online_room_form_state.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'online_room_form_view_model.g.dart';

@riverpod
class OnlineRoomFormViewModel extends _$OnlineRoomFormViewModel {
  @override
  OnlineRoomFormState build() {
    return const OnlineRoomFormState();
  }

  Future<void> createRoom({
    required String playerName,
    int? durationSeconds,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSession: true);

    try {
      final session = await ref
          .read(onlineRoomRepositoryProvider)
          .createRoom(playerName: playerName, durationSeconds: durationSeconds);
      state = state.copyWith(isLoading: false, session: session);
    } on DioException catch (error) {
      final message = error.response?.data is Map<String, dynamic>
          ? (error.response?.data['message'] as String? ?? 'Unable to create room.')
          : 'Unable to create room.';
      state = state.copyWith(isLoading: false, errorMessage: message, clearSession: true);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to create room.',
        clearSession: true,
      );
    }
  }

  Future<void> joinRoom({
    required String roomCode,
    required String playerName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSession: true);

    try {
      final session = await ref.read(onlineRoomRepositoryProvider).joinRoom(
            roomCode: roomCode,
            playerName: playerName,
          );
      state = state.copyWith(isLoading: false, session: session);
    } on DioException catch (error) {
      final message = error.response?.data is Map<String, dynamic>
          ? (error.response?.data['message'] as String? ?? 'Unable to join room.')
          : 'Unable to join room.';
      state = state.copyWith(isLoading: false, errorMessage: message, clearSession: true);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to join room.',
        clearSession: true,
      );
    }
  }

  void clearSession() {
    state = state.copyWith(clearSession: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void setUnlimitedTime(bool value) {
    state = state.copyWith(isUnlimitedTime: value);
  }

  void setDurationMinutes(String value) {
    state = state.copyWith(durationMinutes: value);
  }
}
