import 'package:block/data/local/shared_preferences/shared_preferences_keys.dart';
import 'package:block/data/local/shared_preferences/shared_preferences_service.dart';
import 'package:block/core/providers/app_providers.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'high_score_repository.g.dart';

class HighScoreRepository {
  const HighScoreRepository(this._preferencesService);

  final SharedPreferencesService _preferencesService;

  Future<HighScores> load() async {
    return HighScores(
      classic: _preferencesService.getInt(SharedPreferencesKeys.highScore) ?? 0,
      timer:
          _preferencesService.getInt(SharedPreferencesKeys.highScoreTimer) ?? 0,
    );
  }

  Future<void> saveClassic(int value) async {
    await _preferencesService.setInt(SharedPreferencesKeys.highScore, value);
  }

  Future<void> saveTimer(int value) async {
    await _preferencesService.setInt(SharedPreferencesKeys.highScoreTimer, value);
  }
}

class HighScores {
  const HighScores({required this.classic, required this.timer});

  final int classic;
  final int timer;
}

@riverpod
HighScoreRepository highScoreRepository(Ref ref) {
  final preferencesService = ref.watch(sharedPreferencesServiceProvider);
  return HighScoreRepository(preferencesService);
}
