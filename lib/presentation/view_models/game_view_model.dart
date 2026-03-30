import 'dart:async';

import 'package:block/core/constants/game_constants.dart';
import 'package:block/data/datasources/block_data.dart';
import 'package:block/data/repositories/high_score_repository.dart';
import 'package:block/data/services/sound_manager.dart';
import 'package:block/domain/models/block.dart';
import 'package:block/presentation/view_models/game_state.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_view_model.g.dart';

@riverpod
class GameViewModel extends _$GameViewModel {
  Timer? _countdownTimer;
  late final int _initialDurationSeconds;

  @override
  GameState build(bool isTimerMode, int? matchDurationSeconds) {
    ref.onDispose(() {
      _countdownTimer?.cancel();
    });

    _initialDurationSeconds = matchDurationSeconds ?? timerDuration;

    final initialState = GameState(
      grid: List.generate(gridSize, (_) => List.filled(gridSize, null)),
      blockSlots: List.generate(slotCount, (_) => getRandomBlock()),
      score: 0,
      highScore: 0,
      highScoreTimer: 0,
      isTimerMode: isTimerMode,
      remainingSeconds: _initialDurationSeconds,
      comboCount: 0,
      isGameOver: false,
      clearingCells: const [],
      activePopups: const [],
    );

    Future.microtask(() async {
      await _loadHighScores();
      if (isTimerMode) {
        _startTimer();
      }
    });

    return initialState;
  }

  Future<void> _loadHighScores() async {
    final scores = await ref.read(highScoreRepositoryProvider).load();
    state = state.copyWith(
      highScore: scores.classic,
      highScoreTimer: scores.timer,
    );
  }

  Future<void> handleGameOver() async {
    _countdownTimer?.cancel();
    await _updateHighScore();
  }

  Future<void> _updateHighScore() async {
    final repository = ref.read(highScoreRepositoryProvider);

    if (state.isTimerMode) {
      if (state.score > state.highScoreTimer) {
        await repository.saveTimer(state.score);
        state = state.copyWith(highScoreTimer: state.score);
      }
      return;
    }

    if (state.score > state.highScore) {
      await repository.saveClassic(state.score);
      state = state.copyWith(highScore: state.score);
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    state = state.copyWith(remainingSeconds: _initialDurationSeconds);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
        return;
      }

      timer.cancel();
      state = state.copyWith(isGameOver: true);
      unawaited(_updateHighScore());
    });
  }

  void resetGame() {
    _countdownTimer?.cancel();
    state = GameState(
      grid: List.generate(gridSize, (_) => List.filled(gridSize, null)),
      blockSlots: List.generate(slotCount, (_) => getRandomBlock()),
      score: 0,
      highScore: state.highScore,
      highScoreTimer: state.highScoreTimer,
      isTimerMode: state.isTimerMode,
      remainingSeconds: _initialDurationSeconds,
      comboCount: 0,
      isGameOver: false,
      clearingCells: const [],
      activePopups: const [],
    );

    if (state.isTimerMode) {
      _startTimer();
    }
  }

  bool canPlace(Block block, int startRow, int startCol) {
    return _canPlaceOnGrid(state.grid, block, startRow, startCol);
  }

  bool checkGameOver() {
    return _checkGameOverFrom(state);
  }

  int placeBlock(Block block, int startRow, int startCol, int slotIndex) {
    ref.read(soundManagerProvider).playPlace();

    final grid = _cloneGrid(state.grid);
    final blockSlots = [...state.blockSlots];
    var placedCells = 0;

    for (int r = 0; r < block.rows; r++) {
      for (int c = 0; c < block.cols; c++) {
        if (block.shape[r][c] == 1) {
          grid[startRow + r][startCol + c] = block.color;
          placedCells++;
        }
      }
    }

    blockSlots[slotIndex] = null;

    var workingState = state.copyWith(grid: grid, blockSlots: blockSlots);
    final lineResult = _clearLines(workingState);
    workingState = lineResult.state;

    var turnScore = placedCells;
    final popupCombo = lineResult.linesCleared > 0 ? workingState.comboCount : 0;

    if (lineResult.linesCleared > 0) {
      const clearTable = [60, 120, 180, 240, 300, 360, 420, 480, 540];
      final clearBonus = lineResult.linesCleared <= 8
          ? clearTable[lineResult.linesCleared]
          : clearTable[8] + (lineResult.linesCleared - 8) * 160;

      final nextCombo = workingState.comboCount + 1;
      final multiplier = switch (nextCombo) {
        1 => 1.0,
        2 => 2.0,
        3 => 3.0,
        4 => 3.75,
        _ => 4.50 + (nextCombo - 4) * 0.75,
      };

      turnScore += (clearBonus * multiplier).round();
      if (_isBoardEmpty(workingState.grid)) {
        turnScore += 200;
      }

      workingState = workingState.copyWith(comboCount: nextCombo);
    }

    if (workingState.blockSlots.every((slot) => slot == null)) {
      workingState = workingState.copyWith(
        blockSlots: List.generate(slotCount, (_) => getRandomBlock()),
      );
    }

    if (turnScore > 0) {
      workingState = _addScorePopup(
        workingState,
        turnScore,
        popupCombo,
        (startCol + block.cols / 2).toDouble(),
        (startRow + block.rows / 2).toDouble(),
      );
    }

    workingState = workingState.copyWith(score: workingState.score + turnScore);
    workingState = workingState.copyWith(
      isGameOver: _checkGameOverFrom(workingState),
    );

    state = workingState;
    return turnScore;
  }

  GameState _addScorePopup(
    GameState currentState,
    int score,
    int combo,
    double gridX,
    double gridY,
  ) {
    final popup = ScorePopup(
      id: DateTime.now().millisecondsSinceEpoch,
      score: score,
      combo: combo,
      gridX: gridX,
      gridY: gridY,
    );

    final nextState = currentState.copyWith(
      activePopups: [...currentState.activePopups, popup],
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      state = state.copyWith(
        activePopups: state.activePopups
            .where((item) => item.id != popup.id)
            .toList(),
      );
    });

    return nextState;
  }

  bool _isBoardEmpty(List<List<Color?>> grid) {
    for (final row in grid) {
      for (final cell in row) {
        if (cell != null) {
          return false;
        }
      }
    }
    return true;
  }

  _LineClearResult _clearLines(GameState currentState) {
    final fullRows = <int>[];
    final fullCols = <int>[];
    final grid = _cloneGrid(currentState.grid);

    for (int r = 0; r < gridSize; r++) {
      if (grid[r].every((cell) => cell != null)) {
        fullRows.add(r);
      }
    }

    for (int c = 0; c < gridSize; c++) {
      var full = true;
      for (int r = 0; r < gridSize; r++) {
        if (grid[r][c] == null) {
          full = false;
          break;
        }
      }
      if (full) {
        fullCols.add(c);
      }
    }

    if (fullRows.isEmpty && fullCols.isEmpty) {
      return _LineClearResult(state: currentState, linesCleared: 0);
    }

    ref.read(soundManagerProvider).playClear();
    final cellsToClear = <ClearedCell>[];

    for (final row in fullRows) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] != null) {
          cellsToClear.add(ClearedCell(row, col, grid[row][col]!));
          grid[row][col] = null;
        }
      }
    }

    for (final col in fullCols) {
      for (int row = 0; row < gridSize; row++) {
        if (grid[row][col] != null) {
          cellsToClear.add(ClearedCell(row, col, grid[row][col]!));
          grid[row][col] = null;
        }
      }
    }

    final resultState = currentState.copyWith(
      grid: grid,
      clearingCells: [...currentState.clearingCells, ...cellsToClear],
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      state = state.copyWith(
        clearingCells: state.clearingCells.where((cell) {
          return !cellsToClear.any(
            (cleared) => cleared.row == cell.row && cleared.col == cell.col,
          );
        }).toList(),
      );
    });

    return _LineClearResult(
      state: resultState,
      linesCleared: fullRows.length + fullCols.length,
    );
  }

  bool _checkGameOverFrom(GameState currentState) {
    final activeBlocks = currentState.blockSlots.whereType<Block>().toList();
    if (activeBlocks.isEmpty) {
      return false;
    }

    for (final block in activeBlocks) {
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          if (_canPlaceOnGrid(currentState.grid, block, r, c)) {
            return false;
          }
        }
      }
    }

    return true;
  }

  bool _canPlaceOnGrid(
    List<List<Color?>> grid,
    Block block,
    int startRow,
    int startCol,
  ) {
    for (int r = 0; r < block.rows; r++) {
      for (int c = 0; c < block.cols; c++) {
        if (block.shape[r][c] == 1) {
          final gr = startRow + r;
          final gc = startCol + c;
          if (gr < 0 || gr >= gridSize || gc < 0 || gc >= gridSize) {
            return false;
          }
          if (grid[gr][gc] != null) {
            return false;
          }
        }
      }
    }
    return true;
  }

  List<List<Color?>> _cloneGrid(List<List<Color?>> grid) {
    return grid.map((row) => [...row]).toList();
  }
}

class _LineClearResult {
  const _LineClearResult({required this.state, required this.linesCleared});

  final GameState state;
  final int linesCleared;
}
