import 'package:audioplayers/audioplayers.dart';
import 'package:block/gen/assets.gen.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sound_manager.g.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _placePlayer = AudioPlayer();
  final AudioPlayer _clearPlayer = AudioPlayer();

  String _toAudioAssetPath(String assetPath) {
    const prefix = 'assets/';
    return assetPath.startsWith(prefix)
        ? assetPath.substring(prefix.length)
        : assetPath;
  }

  /// Pre-cache sound files for low-latency playback
  Future<void> init() async {
    // Optionally pre-load if needed, but AudioPlayer.play(AssetSource(...)) works well
  }

  /// Play the sound when a block is placed on the grid
  Future<void> playPlace() async {
    try {
      await _placePlayer.stop(); // Stop current sound if it's still playing
      await _placePlayer.setPlaybackRate(1.3); // Higher pitch, faster sound for new feel
      await _placePlayer.play(
        AssetSource(_toAudioAssetPath(Assets.sounds.place)),
        volume: 0.6,
      );
    } catch (e) {
      debugPrint('Error playing place sound: $e');
    }
  }

  /// Play the sound when one or more lines are cleared
  Future<void> playClear() async {
    try {
      await _clearPlayer.stop();
      // ใช้ไฟล์เสียงที่ถูกสร้างขึ้นมาใหม่ (clear_new.wav) แทนการเล่นซ้ำๆ
      await _clearPlayer.play(
        AssetSource('sounds/clear_new.wav'),
        volume: 1.0,
      );
    } catch (e) {
      debugPrint('Error playing clear sound: $e');
    }
  }

  void dispose() {
    _placePlayer.dispose();
    _clearPlayer.dispose();
  }
}

@Riverpod(keepAlive: true)
SoundManager soundManager(Ref ref) {
  return SoundManager();
}
