import 'dart:math';

import 'package:block/models/block.dart';
import 'package:flutter/material.dart';

final List<Block> blockShapes = [
  // ─────────────────────────────────────────
  // SINGLE CELL
  // ─────────────────────────────────────────

  // ■ 1x1
  Block(
    shape: [
      [1],
    ],
    color: const Color(0xFFEF4444),
  ),

  // ─────────────────────────────────────────
  // DOMINOES (2 cells)
  // ─────────────────────────────────────────

  // ▬ 1x2
  Block(
    shape: [
      [1, 1],
    ],
    color: const Color(0xFF22C55E),
  ),

  // ▮ 2x1
  Block(
    shape: [
      [1],
      [1],
    ],
    color: const Color(0xFF3B82F6),
  ),

  // ─────────────────────────────────────────
  // TROMINOES (3 cells)
  // ─────────────────────────────────────────

  // ▬ 1x3
  Block(
    shape: [
      [1, 1, 1],
    ],
    color: const Color(0xFF10B981),
  ),

  // ▮ 3x1
  Block(
    shape: [
      [1],
      [1],
      [1],
    ],
    color: const Color(0xFF2563EB),
  ),

  // L-tromino (corner ↙)
  Block(
    shape: [
      [1, 0],
      [1, 1],
    ],
    color: const Color(0xFF06B6D4),
  ),

  // L-tromino (corner ↘)
  Block(
    shape: [
      [0, 1],
      [1, 1],
    ],
    color: const Color(0xFF0891B2),
  ),

  // L-tromino (corner ↗)
  Block(
    shape: [
      [1, 1],
      [1, 0],
    ],
    color: const Color(0xFF0E7490),
  ),

  // L-tromino (corner ↖)
  Block(
    shape: [
      [1, 1],
      [0, 1],
    ],
    color: const Color(0xFF155E75),
  ),

  // ─────────────────────────────────────────
  // TETROMINOES (4 cells) — all 7 classic + rotations
  // ─────────────────────────────────────────

  // ■■■■ I-piece horizontal
  Block(
    shape: [
      [1, 1, 1, 1],
    ],
    color: const Color(0xFF059669),
  ),

  // ■ I-piece vertical
  //■
  //■
  //■
  Block(
    shape: [
      [1],
      [1],
      [1],
      [1],
    ],
    color: const Color(0xFF1D4ED8),
  ),

  // ■■ O-piece (2x2 square)
  // ■■
  Block(
    shape: [
      [1, 1],
      [1, 1],
    ],
    color: const Color(0xFF4F46E5),
  ),

  // ■■■ T-piece (flat top)
  //  ■
  Block(
    shape: [
      [1, 1, 1],
      [0, 1, 0],
    ],
    color: const Color(0xFF8B5CF6),
  ),

  // ■   T-piece (left)
  // ■■
  // ■
  Block(
    shape: [
      [1, 0],
      [1, 1],
      [1, 0],
    ],
    color: const Color(0xFF7C3AED),
  ),

  //  ■  T-piece (flat bottom)
  // ■■■
  Block(
    shape: [
      [0, 1, 0],
      [1, 1, 1],
    ],
    color: const Color(0xFF6D28D9),
  ),

  //  ■  T-piece (right)
  // ■■
  //  ■
  Block(
    shape: [
      [0, 1],
      [1, 1],
      [0, 1],
    ],
    color: const Color(0xFF5B21B6),
  ),

  // ■■  S-piece
  //  ■■
  Block(
    shape: [
      [1, 1, 0],
      [0, 1, 1],
    ],
    color: const Color(0xFFEC4899),
  ),

  //  ■  S-piece vertical
  // ■■
  // ■
  Block(
    shape: [
      [0, 1],
      [1, 1],
      [1, 0],
    ],
    color: const Color(0xFFDB2777),
  ),

  //  ■■ Z-piece
  // ■■
  Block(
    shape: [
      [0, 1, 1],
      [1, 1, 0],
    ],
    color: const Color(0xFFBE185D),
  ),

  // ■   Z-piece vertical
  // ■■
  //  ■
  Block(
    shape: [
      [1, 0],
      [1, 1],
      [0, 1],
    ],
    color: const Color(0xFF9D174D),
  ),

  // ■   L-piece
  // ■
  // ■■
  Block(
    shape: [
      [1, 0],
      [1, 0],
      [1, 1],
    ],
    color: const Color(0xFFF59E0B),
  ),

  // ■■■ L-piece rotated
  // ■
  Block(
    shape: [
      [1, 1, 1],
      [0, 0, 1],
    ],
    color: const Color(0xFFD97706),
  ),

  //  ■  L-piece rotated 2
  //  ■
  // ■■
  Block(
    shape: [
      [0, 1],
      [0, 1],
      [1, 1],
    ],
    color: const Color(0xFFB45309),
  ),

  // ■   L-piece rotated 3
  // ■■■
  Block(
    shape: [
      [1, 0, 0],
      [1, 1, 1],
    ],
    color: const Color(0xFF92400E),
  ),

  //  ■  J-piece
  //  ■
  // ■■
  Block(
    shape: [
      [1, 1],
      [1, 0],
      [1, 0],
    ],
    color: const Color(0xFFF97316),
  ),

  // ■   J-piece rotated
  // ■■■
  Block(
    shape: [
      [1, 1, 1],
      [1, 0, 0],
    ],
    color: const Color(0xFFEA580C),
  ),

  // ■■  J-piece rotated 2
  //  ■
  //  ■
  Block(
    shape: [
      [0, 1],
      [0, 1],
      [1, 1], // flipped for J
    ],
    color: const Color(0xFFC2410C),
  ),

  //   ■ J-piece rotated 3
  // ■■■
  Block(
    shape: [
      [0, 0, 1],
      [1, 1, 1],
    ],
    color: const Color(0xFF9A3412),
  ),

  // ─────────────────────────────────────────
  // PENTOMINOES (5 cells)
  // ─────────────────────────────────────────

  // ■■■■■ I-pento horizontal
  Block(
    shape: [
      [1, 1, 1, 1, 1],
    ],
    color: const Color(0xFF14B8A6),
  ),

  // I-pento vertical
  Block(
    shape: [
      [1],
      [1],
      [1],
      [1],
      [1],
    ],
    color: const Color(0xFF0D9488),
  ),

  // ■   U-shape
  // ■■■
  // ■
  Block(
    shape: [
      [1, 0, 1],
      [1, 1, 1],
    ],
    color: const Color(0xFF0F766E),
  ),

  // ■■■ U-shape vertical
  // ■ ■
  Block(
    shape: [
      [1, 1],
      [1, 0],
      [1, 1],
    ],
    color: const Color(0xFF115E59),
  ),

  // ■■  C-shape
  // ■
  // ■■
  Block(
    shape: [
      [1, 1],
      [1, 0],
      [1, 1],
    ],
    color: const Color(0xFF84CC16),
  ),

  //  ■  Plus / Cross (+)
  // ■■■
  //  ■
  Block(
    shape: [
      [0, 1, 0],
      [1, 1, 1],
      [0, 1, 0],
    ],
    color: const Color(0xFF65A30D),
  ),

  // ■■■  F-shape
  //  ■■
  //  ■
  Block(
    shape: [
      [1, 1, 0],
      [0, 1, 1],
      [0, 1, 0],
    ],
    color: const Color(0xFF4D7C0F),
  ),

  //  ■  Y-shape
  // ■■
  //  ■
  //  ■
  Block(
    shape: [
      [0, 1],
      [1, 1],
      [0, 1],
      [0, 1],
    ],
    color: const Color(0xFF3F6212),
  ),

  // ■   Y-shape mirrored
  // ■■
  // ■
  // ■
  Block(
    shape: [
      [1, 0],
      [1, 1],
      [1, 0],
      [1, 0],
    ],
    color: const Color(0xFFEF4444),
  ),

  // ■■  N-shape (skew)
  //  ■
  //  ■
  //  ■
  Block(
    shape: [
      [1, 1, 0],
      [0, 1, 0],
      [0, 1, 1],
    ],
    color: const Color(0xFFDC2626),
  ),

  // ■   W-staircase
  // ■■
  //  ■■
  Block(
    shape: [
      [1, 0, 0],
      [1, 1, 0],
      [0, 1, 1],
    ],
    color: const Color(0xFFB91C1C),
  ),

  //   ■ W-staircase mirrored
  //  ■■
  // ■■
  Block(
    shape: [
      [0, 0, 1],
      [0, 1, 1],
      [1, 1, 0],
    ],
    color: const Color(0xFF991B1B),
  ),

  // ─────────────────────────────────────────
  // LARGE PIECES (6+ cells)
  // ─────────────────────────────────────────

  // ■■■ 2x3 rectangle
  // ■■■
  Block(
    shape: [
      [1, 1, 1],
      [1, 1, 1],
    ],
    color: const Color(0xFF6366F1),
  ),

  // ■■  2x4 rectangle
  // ■■
  // ■■
  // ■■
  Block(
    shape: [
      [1, 1],
      [1, 1],
      [1, 1],
    ],
    color: const Color(0xFF4F46E5),
  ),

  // ■■■■ 2x4 rectangle horizontal
  // ■■■■
  Block(
    shape: [
      [1, 1, 1, 1],
      [1, 1, 1, 1],
    ],
    color: const Color(0xFF4338CA),
  ),

  // ■■■ 3x3 full square
  // ■■■
  // ■■■
  Block(
    shape: [
      [1, 1, 1],
      [1, 1, 1],
      [1, 1, 1],
    ],
    color: const Color(0xFF111827),
  ),

  // ■■■ 3x3 hollow (frame)
  // ■ ■
  // ■■■
  Block(
    shape: [
      [1, 1, 1],
      [1, 0, 1],
      [1, 1, 1],
    ],
    color: const Color(0xFF1F2937),
  ),

  // ■   Big L (3 tall)
  // ■
  // ■
  // ■■■
  Block(
    shape: [
      [1, 0, 0],
      [1, 0, 0],
      [1, 0, 0],
      [1, 1, 1],
    ],
    color: const Color(0xFFF59E0B),
  ),

  //   ■ Big J (3 tall)
  //   ■
  //   ■
  // ■■■
  Block(
    shape: [
      [0, 0, 1],
      [0, 0, 1],
      [0, 0, 1],
      [1, 1, 1],
    ],
    color: const Color(0xFFFBBF24),
  ),

  // ■■■■ Big T (wide)
  //  ■
  //  ■
  Block(
    shape: [
      [1, 1, 1, 1],
      [0, 1, 0, 0],
      [0, 1, 0, 0],
    ],
    color: const Color(0xFFA78BFA),
  ),

  //  ■  Diamond
  // ■■■
  //  ■
  Block(
    shape: [
      [0, 1, 0],
      [1, 1, 1],
      [0, 1, 0],
    ],
    color: const Color(0xFF818CF8),
  ),

  // ■■■ Staircase 3
  //  ■■
  //   ■
  Block(
    shape: [
      [1, 1, 1],
      [0, 1, 1],
      [0, 0, 1],
    ],
    color: const Color(0xFF34D399),
  ),

  // ■   Staircase 3 mirrored
  // ■■
  // ■■■
  Block(
    shape: [
      [1, 0, 0],
      [1, 1, 0],
      [1, 1, 1],
    ],
    color: const Color(0xFF6EE7B7),
  ),

  // ■■  Big Z (3-row)
  //  ■
  //  ■■
  Block(
    shape: [
      [1, 1, 0],
      [0, 1, 0],
      [0, 1, 1],
    ],
    color: const Color(0xFFF9A8D4),
  ),

  // ─────────────────────────────────────────
  // SPECIAL / IRREGULAR
  // ─────────────────────────────────────────

  //  ■  Arrow up
  // ■■■
  // ■ ■
  Block(
    shape: [
      [0, 1, 0],
      [1, 1, 1],
      [1, 0, 1],
    ],
    color: const Color(0xFFFCA5A5),
  ),

  // ■■  Asymmetric hook
  // ■
  // ■■
  // ■
  Block(
    shape: [
      [1, 1],
      [1, 0],
      [1, 1],
      [0, 1],
    ],
    color: const Color(0xFF93C5FD),
  ),

  // ■■■ Irregular blob
  // ■■
  // ■
  Block(
    shape: [
      [1, 1, 1],
      [1, 1, 0],
      [1, 0, 0],
    ],
    color: const Color(0xFF6EE7B7),
  ),

  //   ■ Irregular blob mirrored
  //  ■■
  // ■■■
  Block(
    shape: [
      [0, 0, 1],
      [0, 1, 1],
      [1, 1, 1],
    ],
    color: const Color(0xFFFDE68A),
  ),
];

final _random = Random();

/// สุ่ม Block มา 1 ตัว
Block getRandomBlock() {
  final smallBlocks = blockShapes.where((b) {
    return b.shape.length <= 2 && b.shape[0].length <= 2;
  }).toList();

  final bigBlocks = blockShapes.where((b) {
    return b.shape.length > 2 || b.shape[0].length > 2;
  }).toList();

  if (_random.nextDouble() < 0.7) {
    return smallBlocks[_random.nextInt(smallBlocks.length)];
  } else {
    return bigBlocks[_random.nextInt(bigBlocks.length)];
  }
}
