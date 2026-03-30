import 'package:block/domain/models/block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// แสดงผล Block เป็นตาราง cell สไตล์ neon arcade
class BlockWidget extends StatelessWidget {
  final Block block;
  final double cellSize;

  /// true = block เพิ่งโผล่ครั้งแรก → เล่น stagger cascade animation
  final bool isNew;

  const BlockWidget({
    super.key,
    required this.block,
    this.cellSize = 20,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    // สร้าง palette จากสีหลักของ block
    final HSLColor hsl = HSLColor.fromColor(block.color);
    final Color bright = hsl
        .withLightness((hsl.lightness + 0.28).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.15).clamp(0.0, 1.0))
        .toColor();
    final Color deep = hsl
        .withLightness((hsl.lightness - 0.20).clamp(0.0, 1.0))
        .toColor();
    final Color glow = hsl
        .withLightness((hsl.lightness + 0.10).clamp(0.0, 1.0))
        .withSaturation(1.0)
        .toColor();

    // นับ index เฉพาะ filled cell เพื่อ stagger
    int filledIndex = 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(block.shape.length, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(block.shape[row].length, (col) {
            final isFilled = block.shape[row][col] == 1;
            final currentIndex = isFilled ? filledIndex++ : -1;

            if (!isFilled) {
              // ช่องว่าง — spacer โปร่งใส
              return SizedBox(
                width: cellSize,
                height: cellSize,
              )._addMargin;
            }

            // ── Filled cell ──────────────────────────────────────────
            Widget cell = _NeonCell(
              cellSize: cellSize,
              color: block.color,
              bright: bright,
              deep: deep,
              glow: glow,
            );

            if (isNew) {
              // stagger แต่ละ cell ห่างกัน 35ms
              final delay = (currentIndex * 35).ms;
              cell = cell
                  .animate(delay: delay)
                  .scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.0, 1.0),
                    duration: 380.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 200.ms)
                  .then() // ต่อ effect หลัง pop-in เสร็จ
                  .shimmer(
                    duration: 500.ms,
                    color: Colors.white.withValues(alpha: 0.6),
                    curve: Curves.easeOut,
                  );
            }

            return cell;
          }),
        );
      }),
    );
  }
}

// ── ฟังก์ชัน helper เพิ่ม margin ให้ SizedBox spacer ──────────────────────
extension _WidgetMargin on Widget {
  Widget get _addMargin =>
      Padding(padding: const EdgeInsets.all(1.5), child: this);
}

// =============================================================================
// _NeonCell — tile เดียวที่มี 3 layer: glow → body gradient → gloss sheen
// =============================================================================
class _NeonCell extends StatelessWidget {
  final double cellSize;
  final Color color;
  final Color bright;
  final Color deep;
  final Color glow;

  const _NeonCell({
    required this.cellSize,
    required this.color,
    required this.bright,
    required this.deep,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Stack(
          children: [
            // ── Layer 1: glow halo (ด้านหลังสุด) ─────────────────────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.5),
                  boxShadow: [
                    BoxShadow(
                      color: glow.withValues(alpha: 0.55),
                      blurRadius: cellSize * 0.5,
                      spreadRadius: cellSize * 0.05,
                    ),
                    BoxShadow(
                      color: deep.withValues(alpha: 0.8),
                      blurRadius: 2,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
              ),
            ),

            // ── Layer 2: body (gradient + border accent) ───────────────
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [bright, color, deep],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(4.5),
                  border: Border.all(
                    color: bright.withValues(alpha: 0.45),
                    width: 0.75,
                  ),
                ),
              ),
            ),

            // ── Layer 3: gloss sheen (มุมบนซ้าย) ─────────────────────
            Positioned(
              top: 1,
              left: 1.5,
              right: cellSize * 0.35,
              height: cellSize * 0.28,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Layer 4: bottom edge shadow (ให้รู้สึก 3D) ────────────
            Positioned(
              bottom: 0,
              left: 2,
              right: 2,
              height: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(4.5),
                  ),
                  color: deep.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

