import 'package:block/domain/models/block.dart';
import 'package:flutter/material.dart';

@immutable
class GameState {
  const GameState({
    required this.grid,
    required this.blockSlots,
    required this.score,
    required this.highScore,
    required this.highScoreTimer,
    required this.isTimerMode,
    required this.remainingSeconds,
    required this.comboCount,
    required this.isGameOver,
    required this.clearingCells,
    required this.activePopups,
  });

  final List<List<Color?>> grid;
  final List<Block?> blockSlots;
  final int score;
  final int highScore;
  final int highScoreTimer;
  final bool isTimerMode;
  final int remainingSeconds;
  final int comboCount;
  final bool isGameOver;
  final List<ClearedCell> clearingCells;
  final List<ScorePopup> activePopups;

  String get timeString {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  GameState copyWith({
    List<List<Color?>>? grid,
    List<Block?>? blockSlots,
    int? score,
    int? highScore,
    int? highScoreTimer,
    bool? isTimerMode,
    int? remainingSeconds,
    int? comboCount,
    bool? isGameOver,
    List<ClearedCell>? clearingCells,
    List<ScorePopup>? activePopups,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      blockSlots: blockSlots ?? this.blockSlots,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      highScoreTimer: highScoreTimer ?? this.highScoreTimer,
      isTimerMode: isTimerMode ?? this.isTimerMode,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      comboCount: comboCount ?? this.comboCount,
      isGameOver: isGameOver ?? this.isGameOver,
      clearingCells: clearingCells ?? this.clearingCells,
      activePopups: activePopups ?? this.activePopups,
    );
  }
}

@immutable
class ClearedCell {
  const ClearedCell(this.row, this.col, this.color);

  final int row;
  final int col;
  final Color color;
}

@immutable
class ScorePopup {
  const ScorePopup({
    required this.id,
    required this.score,
    required this.combo,
    required this.gridX,
    required this.gridY,
  });

  final int id;
  final int score;
  final int combo;
  final double gridX;
  final double gridY;
}
