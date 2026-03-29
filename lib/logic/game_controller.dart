import 'dart:async';
import 'package:block/data/block_data.dart';
import 'package:block/models/block.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ขนาดกริด
const int gridSize = 8;

/// จำนวนช่อง Block ที่แสดงด้านล่าง
const int slotCount = 3;

/// ระยะเวลาโหมดจับเวลา (วินาที)
const int timerDuration = 3 * 60; // 3 นาที (แก้ให้ตรงกับ startTimer)

/// จัดการ state ทั้งหมดของเกม (grid, score, block slots)
class GameController extends ChangeNotifier {
  /// กริด 8x8: null = ว่าง, Color = มี block อยู่
  List<List<Color?>> grid = List.generate(
    gridSize,
    (_) => List.filled(gridSize, null),
  );

  /// ช่อง Block 3 ช่องด้านล่าง
  List<Block?> blockSlots = [];

  /// คะแนน
  int score = 0;

  /// คะแนนสูงสุด (โหมดปกติ)
  int highScore = 0;

  /// คะแนนสูงสุด (โหมดจับเวลา)
  int highScoreTimer =
      0; // FIX: เปลี่ยนชื่อจาก highScore_timer ให้ถูก convention

  /// โหมดจับเวลา
  bool isTimerMode = false;
  int remainingSeconds = timerDuration;
  Timer? _countdownTimer;

  /// ตัวนับ Combo ต่อเนื่อง
  int comboCount = 0;

  /// สถานะจบเกม
  bool isGameOver = false;

  /// รายชื่อเซลล์ที่กำลังเล่นแอนิเมชันตอนถูกเคลียร์
  List<ClearedCell> clearingCells = [];

  /// รายชื่อคะแนนที่กำลังเด้งขึ้นมา
  List<ScorePopup> activePopups = [];

  GameController() {
    _refillSlots();
    _loadHighScores();
  }

  // ---------------------------------------------------------------------------
  // High Score
  // ---------------------------------------------------------------------------

  /// โหลดคะแนนสูงสุดทั้งสองโหมดพร้อมกัน (FIX: รวมเป็น method เดียว)
  Future<void> _loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('high_score') ?? 0;
    highScoreTimer = prefs.getInt('high_score_timer') ?? 0;
    notifyListeners();
  }

  Future<void> handleGameOver() async {
    _countdownTimer?.cancel();

    // รอให้ high score update เสร็จ
    await _updateHighScore();
  }

  /// บันทึกคะแนนสูงสุดตาม mode ที่กำลังเล่น
  /// FIX: แยก normal / timer ออกจากกัน ไม่ให้ปนกัน
  Future<void> _updateHighScore() async {
    final prefs = await SharedPreferences.getInstance();

    if (isTimerMode) {
      if (score > highScoreTimer) {
        highScoreTimer = score;
        await prefs.setInt('high_score_timer', highScoreTimer);
        // notifyListeners();
      }
    } else {
      if (score > highScore) {
        highScore = score;
        await prefs.setInt('high_score', highScore);
        // notifyListeners();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Timer
  // ---------------------------------------------------------------------------

  /// เริ่มหรือรีเซ็ตจับเวลา
  void startTimer(bool timerMode) {
    _countdownTimer?.cancel(); // FIX: cancel ก่อนเสมอ ป้องกัน timer ซ้อน

    isTimerMode = timerMode;
    remainingSeconds = timerDuration; // FIX: ใช้ constant เดียวกัน

    if (isTimerMode) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds > 0) {
          remainingSeconds--;
          notifyListeners();
        } else {
          timer.cancel();
          isGameOver = true;
          _updateHighScore();
          notifyListeners();
        }
      });
    }
  }

  /// สตริงเวลา 'MM:SS'
  String get timeString {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ---------------------------------------------------------------------------
  // Game Lifecycle
  // ---------------------------------------------------------------------------

  /// เริ่มเกมใหม่
  void resetGame() {
    _countdownTimer?.cancel(); // FIX: cancel timer ก่อน reset เสมอ

    grid = List.generate(gridSize, (_) => List.filled(gridSize, null));
    score = 0;
    comboCount = 0;
    isGameOver = false;
    clearingCells = []; // FIX: ล้าง animation queue ด้วย

    _refillSlots();

    if (isTimerMode) {
      startTimer(true);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Slot Management
  // ---------------------------------------------------------------------------

  /// เติม Block ใหม่ทั้ง 3 ช่อง
  void _refillSlots() {
    blockSlots = List.generate(slotCount, (_) => getRandomBlock());
  }

  // ---------------------------------------------------------------------------
  // Placement Logic
  // ---------------------------------------------------------------------------

  /// ตรวจว่า block วางได้ที่ตำแหน่ง (startRow, startCol) หรือไม่
  bool canPlace(Block block, int startRow, int startCol) {
    for (int r = 0; r < block.rows; r++) {
      for (int c = 0; c < block.cols; c++) {
        if (block.shape[r][c] == 1) {
          final gr = startRow + r;
          final gc = startCol + c;
          if (gr < 0 || gr >= gridSize || gc < 0 || gc >= gridSize) {
            return false;
          }
          if (grid[gr][gc] != null) return false;
        }
      }
    }
    return true;
  }

  /// ตรวจสอบว่าเกมจบหรือไม่
  /// FIX: กรณีที่ slots ทุกช่องเป็น null (ก่อน refill) ให้ถือว่าเกมยังไม่จบ
  bool checkGameOver() {
    final activeBlocks = blockSlots.whereType<Block>().toList();

    // ถ้าไม่มี block เหลือเลย (ยังรอ refill) → ยังไม่จบเกม
    if (activeBlocks.isEmpty) return false;

    for (final block in activeBlocks) {
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          if (canPlace(block, r, c)) return false;
        }
      }
    }
    return true;
  }

  /// วาง block ลงบน grid เคลียร์แถว/คอลัมน์ที่เต็ม และคืนค่าคะแนนที่ได้ในรอบนั้น
  int placeBlock(Block block, int startRow, int startCol, int slotIndex) {
    int placedCells = 0;

    // วาง block
    for (int r = 0; r < block.rows; r++) {
      for (int c = 0; c < block.cols; c++) {
        if (block.shape[r][c] == 1) {
          grid[startRow + r][startCol + c] = block.color;
          placedCells++;
        }
      }
    }

    // ลบ block ออกจาก slot
    blockSlots[slotIndex] = null;

    // เคลียร์แถว/คอลัมน์ที่เต็ม
    final int linesCleared = _clearLines();

    // ==========================================
    // คำนวณคะแนนในรอบนี้
    // ==========================================
    int turnScore = 0;

    // 1. คะแนนจากการวางบล็อก — scale ตามขนาด
    final int cellBase = 1;
    turnScore += placedCells * cellBase;

    final int popupCombo = linesCleared > 0 ? comboCount : 0;

    // 2. โบนัสบล็อกใหญ่
    // if (placedCells >= 7) {
    //   turnScore += 15;
    // } else if (placedCells >= 5) {
    //   turnScore += 8;
    // }

    if (linesCleared > 0) {
      // 3. โบนัสเคลียร์เส้น
      const clearTable = [60, 120, 180, 240, 300, 360, 420, 480, 540];
      final int clearBonus = linesCleared <= 8
          ? clearTable[linesCleared]
          : clearTable[8] + (linesCleared - 8) * 160;

      // 4. Combo multiplier
      comboCount++;
      final double multiplier = switch (comboCount) {
        1 => 1.0,
        2 => 2.0,
        3 => 3.0,
        4 => 3.75,
        _ => 4.50 + (comboCount - 4) * 0.75,
      };

      turnScore += (clearBonus * multiplier).round();

      // 5. โบนัสกระดานว่างเปล่า
      if (_isBoardEmpty()) {
        turnScore += 200;
      }
    } else {
      // comboCount = 0;
    }

    score += turnScore;

    // if (comboCount >= 3) {
    //   turnScore += comboCount * 10;
    // }

    // if (placedCells == block.rows * block.cols) {
    //   turnScore += 10;
    // }
    // ถ้าใช้หมดทุกช่อง → เติมใหม่
    if (blockSlots.every((b) => b == null)) {
      _refillSlots();
    }

    // อัปเดตสถานะเกม
    isGameOver = checkGameOver();
    // if (isGameOver) {
    //   _countdownTimer?.cancel();
    //   _updateHighScore();
    // }

    // แจ้งเตือน Popups (คำนวณตำแหน่งประมาณกลางบล็อกที่วาง)
    if (turnScore > 0) {
      final centerX = (startCol + block.cols / 2).toDouble();
      final centerY = (startRow + block.rows / 2).toDouble();
      addScorePopup(turnScore, popupCombo, centerX, centerY);
    }

    notifyListeners();
    return turnScore;
  }

  void addScorePopup(int score, int combo, double gridX, double gridY) {
    final popup = ScorePopup(
      id: DateTime.now().millisecondsSinceEpoch,
      score: score,
      combo: combo,
      gridX: gridX,
      gridY: gridY,
    );
    activePopups.add(popup);
    notifyListeners();

    // ลบตัวเองอัตโนมัติหลัง 0.8 วินาที
    Future.delayed(const Duration(milliseconds: 800), () {
      activePopups.removeWhere((p) => p.id == popup.id);
      notifyListeners();
    });
  }

  bool _isBoardEmpty() {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] != null) return false;
      }
    }
    return true;
  }

  // ---------------------------------------------------------------------------
  // Line Clearing
  // ---------------------------------------------------------------------------

  int _clearLines() {
    final fullRows = <int>[];
    final fullCols = <int>[];

    for (int r = 0; r < gridSize; r++) {
      if (grid[r].every((cell) => cell != null)) fullRows.add(r);
    }

    for (int c = 0; c < gridSize; c++) {
      bool full = true;
      for (int r = 0; r < gridSize; r++) {
        if (grid[r][c] == null) {
          full = false;
          break;
        }
      }
      if (full) fullCols.add(c);
    }

    if (fullRows.isEmpty && fullCols.isEmpty) return 0;

    // FIX: snapshot รายการ cell ของรอบนี้ก่อน เพื่อป้องกัน race condition
    final cellsToClear = <ClearedCell>[];

    for (int r in fullRows) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c] != null) {
          cellsToClear.add(ClearedCell(r, c, grid[r][c]!));
          grid[r][c] = null;
        }
      }
    }

    for (int c in fullCols) {
      for (int r = 0; r < gridSize; r++) {
        if (grid[r][c] != null) {
          cellsToClear.add(ClearedCell(r, c, grid[r][c]!));
          grid[r][c] = null;
        }
      }
    }

    // FIX: ใช้ Set ของ object reference แทน removeWhere ทั่วๆ ไป
    // เพื่อป้องกันการลบ cell ของรอบอื่นออกไปด้วย
    final cellSet = Set<ClearedCell>.identity()..addAll(cellsToClear);
    clearingCells.addAll(cellsToClear);

    Future.delayed(const Duration(milliseconds: 400), () {
      clearingCells.removeWhere((cell) => cellSet.contains(cell));
      notifyListeners();
    });

    return fullRows.length + fullCols.length;
  }
}

class ClearedCell {
  final int row;
  final int col;
  final Color color;

  ClearedCell(this.row, this.col, this.color);
}

class ScorePopup {
  final int id;
  final int score;
  final int combo;
  final double gridX;
  final double gridY;

  ScorePopup({
    required this.id,
    required this.score,
    required this.combo,
    required this.gridX,
    required this.gridY,
  });
}
