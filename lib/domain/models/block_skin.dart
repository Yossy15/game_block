import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// โมเดลของสกิน Block — กำหนดวิธีวาดแต่ละ cell
class BlockSkin {
  final String id;
  final String displayName;
  final IconData icon;
  final Color accentColor;

  /// สร้าง Widget สำหรับ 1 cell ใน block
  final Widget Function({
    required double cellSize,
    required Color color,
  }) cellBuilder;

  /// สร้าง Widget สำหรับ 1 cell ที่วางบนกริดแล้ว (placed cell)
  final Widget Function({
    required Color color,
    required bool isElevated,
  }) placedCellBuilder;

  /// Animation สำหรับ cell ใหม่ (ในช่องสุ่ม)
  final Widget Function(Widget child, int currentIndex) animateNewCell;

  /// Animation สำหรับ cell ที่เพิ่งถูกวางบนกริด
  final Widget Function(Widget child) animatePlacedCell;

  /// สร้าง Widget สำหรับ cell ที่ถูกทำลาย (วางครบแถว)
  final Widget Function(Color color) clearCellBuilder;

  const BlockSkin({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.accentColor,
    required this.cellBuilder,
    required this.placedCellBuilder,
    required this.animateNewCell,
    required this.animatePlacedCell,
    required this.clearCellBuilder,
  });
}

// =============================================================================
// สกินทั้งหมด
// =============================================================================

final List<BlockSkin> allSkins = [
  flatSkin, // Default minimal skin
  glassSkin,
  softSkin,
  woodSkin,
  holoSkin,
  crystalSkin,
  neonSkin,
  glossySkin,
  pixelSkin,
  candySkin,
  galaxySkin,
  cyberSkin,
];

BlockSkin getSkinById(String id) {
  return allSkins.firstWhere(
    (s) => s.id == id,
    orElse: () => neonSkin,
  );
}

// =============================================================================
// 1. NEON — สกินดั้งเดิม gradient + glow halo + gloss sheen
// =============================================================================
final BlockSkin neonSkin = BlockSkin(
  id: 'neon',
  displayName: 'NEON',
  icon: Icons.flash_on_rounded,
  accentColor: const Color(0xFF00E5FF),
  cellBuilder: ({required double cellSize, required Color color}) {
    return _NeonCellWidget(cellSize: cellSize, color: color);
  },
  placedCellBuilder: ({required Color color, required bool isElevated}) {
    return _NeonPlacedCellWidget(color: color, isElevated: isElevated);
  },
  animateNewCell: (child, index) => child
      .animate(delay: (index * 35).ms)
      .scale(
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
        duration: 380.ms,
        curve: Curves.easeOutBack,
      )
      .fadeIn(duration: 200.ms)
      .then()
      .shimmer(
        duration: 500.ms,
        color: Colors.white.withValues(alpha: 0.6),
        curve: Curves.easeOut,
      ),
  animatePlacedCell: (child) => child
      .animate()
      .scaleXY(
        begin: 0.4,
        end: 1.0,
        duration: 380.ms,
        curve: Curves.easeOutBack,
      )
      .fadeIn(duration: 180.ms),
  clearCellBuilder: (color) => _NeonClearedCellWidget(color: color),
);

class _NeonCellWidget extends StatelessWidget {
  final double cellSize;
  final Color color;
  const _NeonCellWidget({required this.cellSize, required this.color});

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(color);
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

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Stack(
          children: [
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

class _NeonPlacedCellWidget extends StatelessWidget {
  final Color color;
  final bool isElevated;
  const _NeonPlacedCellWidget({required this.color, this.isElevated = false});

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color light = hsl
        .withLightness((hsl.lightness + 0.22).clamp(0.0, 1.0))
        .toColor();
    final Color dark = hsl
        .withLightness((hsl.lightness - 0.18).clamp(0.0, 1.0))
        .toColor();

    return AnimatedScale(
      scale: isElevated ? 1.09 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [light, color, dark],
            stops: const [0.0, 0.45, 1.0],
          ),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            if (isElevated) ...[
              BoxShadow(
                color: color.withValues(alpha: 0.75),
                blurRadius: 16,
                spreadRadius: 3,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(-1, -1),
              ),
            ] else
              BoxShadow(
                color: dark.withValues(alpha: 0.55),
                blurRadius: 4,
                offset: const Offset(1, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 1,
              left: 2,
              right: 8,
              height: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 2. FLAT — สีเรียบ minimal, ขอบบาง, ไม่มี glow
// =============================================================================
final BlockSkin flatSkin = BlockSkin(
  id: 'flat',
  displayName: 'FLAT',
  icon: Icons.square_rounded,
  accentColor: const Color(0xFF64748B),
  cellBuilder: ({required double cellSize, required Color color}) {
    return _FlatCellWidget(cellSize: cellSize, color: color);
  },
  placedCellBuilder: ({required Color color, required bool isElevated}) {
    return _FlatPlacedCellWidget(color: color, isElevated: isElevated);
  },
  animateNewCell: (child, index) => child
      .animate(delay: (index * 40).ms)
      .fadeIn(duration: 250.ms, curve: Curves.easeOut)
      .slideY(begin: 0.2, end: 0, duration: 250.ms, curve: Curves.easeOut),
  animatePlacedCell: (child) => child
      .animate()
      .fadeIn(duration: 150.ms)
      .scaleXY(
        begin: 0.8,
        end: 1.0,
        duration: 200.ms,
        curve: Curves.easeOutCubic,
      ),
  clearCellBuilder: (color) => _FlatPlacedCellWidget(color: color)
      .animate()
      .scaleXY(begin: 1.0, end: 0.0, duration: 300.ms, curve: Curves.easeIn)
      .fadeOut(duration: 300.ms),
);

class _FlatCellWidget extends StatelessWidget {
  final double cellSize;
  final Color color;
  const _FlatCellWidget({required this.cellSize, required this.color});

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color border = hsl
        .withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0))
        .toColor();

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: border.withValues(alpha: 0.6),
              width: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _FlatPlacedCellWidget extends StatelessWidget {
  final Color color;
  final bool isElevated;
  const _FlatPlacedCellWidget({required this.color, this.isElevated = false});

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color border = hsl
        .withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0))
        .toColor();

    return AnimatedScale(
      scale: isElevated ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: border.withValues(alpha: 0.6),
            width: 1.0,
          ),
          boxShadow: isElevated
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

// =============================================================================
// 3. GLOSSY — gradient สวยจัด, specular highlight วงกลมกลาง cell
// =============================================================================
final BlockSkin glossySkin = BlockSkin(
  id: 'glossy',
  displayName: 'GLOSSY',
  icon: Icons.auto_awesome,
  accentColor: const Color(0xFFFF6B9D),
  cellBuilder: ({required double cellSize, required Color color}) {
    return _GlossyCellWidget(cellSize: cellSize, color: color);
  },
  placedCellBuilder: ({required Color color, required bool isElevated}) {
    return _GlossyPlacedCellWidget(color: color, isElevated: isElevated);
  },
  animateNewCell: (child, index) => child
      .animate(delay: (index * 30).ms)
      .scale(
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
        duration: 400.ms,
        curve: Curves.elasticOut,
      ),
  animatePlacedCell: (child) => child
      .animate()
      .scaleXY(
        begin: 0.5,
        end: 1.0,
        duration: 400.ms,
        curve: Curves.elasticOut,
      )
      .fadeIn(duration: 200.ms),
  clearCellBuilder: (color) => _GlossyPlacedCellWidget(color: color)
      .animate()
      .scaleXY(begin: 1.0, end: 0.0, duration: 400.ms, curve: Curves.easeInBack)
      .rotate(begin: 0.0, end: 0.5, duration: 400.ms)
      .fadeOut(duration: 400.ms),
);

class _GlossyCellWidget extends StatelessWidget {
  final double cellSize;
  final Color color;
  const _GlossyCellWidget({required this.cellSize, required this.color});

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color bright = hsl
        .withLightness((hsl.lightness + 0.30).clamp(0.0, 1.0))
        .toColor();
    final Color deep = hsl
        .withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0))
        .toColor();

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Stack(
          children: [
            // Body gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [bright, color, deep],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: bright.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: deep.withValues(alpha: 0.6),
                      blurRadius: 3,
                      offset: const Offset(1, 2),
                    ),
                  ],
                ),
              ),
            ),
            // Circular specular highlight
            Positioned(
              top: cellSize * 0.12,
              left: cellSize * 0.15,
              width: cellSize * 0.45,
              height: cellSize * 0.40,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    colors: [
                      Colors.white.withValues(alpha: 0.65),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom reflection
            Positioned(
              bottom: 1,
              left: cellSize * 0.2,
              right: cellSize * 0.2,
              height: 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlossyPlacedCellWidget extends StatelessWidget {
  final Color color;
  final bool isElevated;
  const _GlossyPlacedCellWidget({required this.color, this.isElevated = false});

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color bright = hsl
        .withLightness((hsl.lightness + 0.30).clamp(0.0, 1.0))
        .toColor();
    final Color deep = hsl
        .withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0))
        .toColor();

    return AnimatedScale(
      scale: isElevated ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bright, color, deep],
          ),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: bright.withValues(alpha: 0.3),
            width: 0.8,
          ),
          boxShadow: [
            if (isElevated)
              BoxShadow(
                color: color.withValues(alpha: 0.7),
                blurRadius: 14,
                spreadRadius: 2,
              )
            else
              BoxShadow(
                color: deep.withValues(alpha: 0.5),
                blurRadius: 3,
                offset: const Offset(1, 2),
              ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 2,
              left: 3,
              width: 12,
              height: 10,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 4. PIXEL — retro pixel art style, ขอบชัด 2px, inner shadow เข้ม
// =============================================================================
final BlockSkin pixelSkin = BlockSkin(
  id: 'pixel',
  displayName: 'PIXEL',
  icon: Icons.grid_on_rounded,
  accentColor: const Color(0xFF10B981),
  cellBuilder: ({required double cellSize, required Color color}) {
    return _PixelCellWidget(cellSize: cellSize, color: color);
  },
  placedCellBuilder: ({required Color color, required bool isElevated}) {
    return _PixelPlacedCellWidget(color: color, isElevated: isElevated);
  },
  animateNewCell: (child, index) => child
      .animate(delay: (index * 50).ms)
      .scaleXY(
        begin: 0.0,
        end: 1.0,
        duration: 200.ms,
        curve: Curves.easeOut,
      ),
  animatePlacedCell: (child) => child
      .animate()
      .fadeIn(duration: 100.ms)
      .scaleXY(
        begin: 0.0,
        end: 1.0,
        duration: 150.ms,
        curve: Curves.easeOut,
      ),
  clearCellBuilder: (color) => _PixelPlacedCellWidget(color: color)
      .animate()
      .scaleXY(begin: 1.0, end: 0.0, duration: 250.ms, curve: Curves.easeIn)
      .fadeOut(duration: 200.ms),
);

class _PixelCellWidget extends StatelessWidget {
  final double cellSize;
  final Color color;
  const _PixelCellWidget({required this.cellSize, required this.color});

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color highlight = hsl
        .withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0))
        .toColor();
    final Color shadow = hsl
        .withLightness((hsl.lightness - 0.30).clamp(0.0, 1.0))
        .toColor();

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: CustomPaint(
          painter: _PixelCellPainter(
            color: color,
            highlight: highlight,
            shadow: shadow,
          ),
        ),
      ),
    );
  }
}

class _PixelCellPainter extends CustomPainter {
  final Color color;
  final Color highlight;
  final Color shadow;

  const _PixelCellPainter({
    required this.color,
    required this.highlight,
    required this.shadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const bw = 2.0; // border width

    // Outer border (shadow color)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = shadow,
    );

    // Highlight (top-left bevel)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width - bw, bw),
      Paint()..color = highlight,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, bw, size.height - bw),
      Paint()..color = highlight,
    );

    // Inner fill
    canvas.drawRect(
      Rect.fromLTWH(bw, bw, size.width - bw * 2, size.height - bw * 2),
      Paint()..color = color,
    );

    // Inner highlight dot (pixel style)
    final dotSize = size.width * 0.15;
    canvas.drawRect(
      Rect.fromLTWH(bw + 2, bw + 2, dotSize, dotSize),
      Paint()..color = highlight.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _PixelCellPainter old) =>
      old.color != color;
}

class _PixelPlacedCellWidget extends StatelessWidget {
  final Color color;
  final bool isElevated;
  const _PixelPlacedCellWidget({required this.color, this.isElevated = false});

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color highlight = hsl
        .withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0))
        .toColor();
    final Color shadow = hsl
        .withLightness((hsl.lightness - 0.30).clamp(0.0, 1.0))
        .toColor();

    return AnimatedScale(
      scale: isElevated ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: CustomPaint(
          painter: _PixelCellPainter(
            color: color,
            highlight: highlight,
            shadow: shadow,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 5. CANDY — พาสเทลหวาน, stripe เฉียง, rounded มาก
// =============================================================================
final BlockSkin candySkin = BlockSkin(
  id: 'candy',
  displayName: 'CANDY',
  icon: Icons.cookie_rounded,
  accentColor: const Color(0xFFF472B6),
  cellBuilder: ({required double cellSize, required Color color}) {
    return _CandyCellWidget(cellSize: cellSize, color: color);
  },
  placedCellBuilder: ({required Color color, required bool isElevated}) {
    return _CandyPlacedCellWidget(color: color, isElevated: isElevated);
  },
  animateNewCell: (child, index) => child
      .animate(delay: (index * 45).ms)
      .scale(
        begin: const Offset(0.5, 0.5),
        end: const Offset(1.0, 1.0),
        duration: 500.ms,
        curve: Curves.elasticOut,
      )
      .rotate(begin: -0.05, end: 0, duration: 300.ms),
  animatePlacedCell: (child) => child
      .animate()
      .scaleXY(
        begin: 0.3,
        end: 1.0,
        duration: 450.ms,
        curve: Curves.elasticOut,
      )
      .fadeIn(duration: 200.ms),
  clearCellBuilder: (color) => _CandyPlacedCellWidget(color: color)
      .animate()
      .scaleXY(begin: 1.0, end: 1.5, duration: 150.ms, curve: Curves.easeOut)
      .then()
      .scaleXY(begin: 1.5, end: 0.0, duration: 200.ms, curve: Curves.easeIn)
      .fadeOut(duration: 200.ms),
);

Color _toPastel(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withSaturation((hsl.saturation * 0.5 + 0.2).clamp(0.0, 1.0))
      .withLightness((hsl.lightness * 0.5 + 0.45).clamp(0.0, 0.85))
      .toColor();
}

class _CandyCellWidget extends StatelessWidget {
  final double cellSize;
  final Color color;
  const _CandyCellWidget({required this.cellSize, required this.color});

  @override
  Widget build(BuildContext context) {
    final pastel = _toPastel(color);
    final HSLColor hsl = HSLColor.fromColor(pastel);
    final stripeColor = hsl
        .withLightness((hsl.lightness - 0.08).clamp(0.0, 1.0))
        .toColor();

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Stack(
          children: [
            // Base
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: pastel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: stripeColor.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: pastel.withValues(alpha: 0.35),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            // Diagonal stripes
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomPaint(
                  painter: _StripePainter(stripeColor: stripeColor),
                ),
              ),
            ),
            // Top gloss
            Positioned(
              top: 1,
              left: 3,
              right: 3,
              height: cellSize * 0.3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  final Color stripeColor;
  const _StripePainter({required this.stripeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripeColor.withValues(alpha: 0.25)
      ..strokeWidth = 2.5;

    const step = 6.0;
    for (double d = -size.width; d < size.width * 2; d += step) {
      canvas.drawLine(
        Offset(d, 0),
        Offset(d + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter old) =>
      old.stripeColor != stripeColor;
}

class _CandyPlacedCellWidget extends StatelessWidget {
  final Color color;
  final bool isElevated;
  const _CandyPlacedCellWidget({required this.color, this.isElevated = false});

  @override
  Widget build(BuildContext context) {
    final pastel = _toPastel(color);
    final HSLColor hsl = HSLColor.fromColor(pastel);
    final stripeColor = hsl
        .withLightness((hsl.lightness - 0.08).clamp(0.0, 1.0))
        .toColor();

    return AnimatedScale(
      scale: isElevated ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: pastel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: stripeColor.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                  boxShadow: isElevated
                      ? [
                          BoxShadow(
                            color: pastel.withValues(alpha: 0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: stripeColor.withValues(alpha: 0.3),
                            blurRadius: 3,
                            offset: const Offset(1, 2),
                          ),
                        ],
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomPaint(
                  painter: _StripePainter(stripeColor: stripeColor),
                ),
              ),
            ),
            Positioned(
              top: 1,
              left: 3,
              right: 3,
              height: 6,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.45),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 6. GALAXY — gradient หลายสี, particle dots, shimmer
// =============================================================================
final BlockSkin galaxySkin = BlockSkin(
  id: 'galaxy',
  displayName: 'GALAXY',
  icon: Icons.stars_rounded,
  accentColor: const Color(0xFF8B5CF6),
  cellBuilder: ({required double cellSize, required Color color}) {
    return _GalaxyCellWidget(cellSize: cellSize, color: color);
  },
  placedCellBuilder: ({required Color color, required bool isElevated}) {
    return _GalaxyPlacedCellWidget(color: color, isElevated: isElevated);
  },
  animateNewCell: (child, index) => child
      .animate(delay: (index * 50).ms)
      .fadeIn(duration: 400.ms)
      .scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: 400.ms,
        curve: Curves.easeOut,
      )
      .then()
      .shimmer(
        duration: 800.ms,
        color: Colors.white.withValues(alpha: 0.4),
      ),
  animatePlacedCell: (child) => child
      .animate()
      .fadeIn(duration: 300.ms)
      .scaleXY(
        begin: 0.8,
        end: 1.0,
        duration: 300.ms,
        curve: Curves.easeOut,
      ),
  clearCellBuilder: (color) => _GalaxyPlacedCellWidget(color: color)
      .animate()
      .scaleXY(begin: 1.0, end: 0.0, duration: 500.ms, curve: Curves.easeIn)
      .shimmer(duration: 400.ms, color: Colors.white)
      .fadeOut(duration: 500.ms),
);

class _GalaxyCellWidget extends StatelessWidget {
  final double cellSize;
  final Color color;
  const _GalaxyCellWidget({required this.cellSize, required this.color});

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color c1 = hsl.withHue((hsl.hue - 30) % 360).toColor();
    final Color c2 = color;
    final Color c3 = hsl.withHue((hsl.hue + 40) % 360)
        .withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0))
        .toColor();
    final Color glow = hsl.withSaturation(1.0)
        .withLightness(0.6)
        .toColor();

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Stack(
          children: [
            // Glow
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: glow.withValues(alpha: 0.45),
                      blurRadius: cellSize * 0.45,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            // Multi-color gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c1, c2, c3],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: c3.withValues(alpha: 0.4),
                    width: 0.75,
                  ),
                ),
              ),
            ),
            // Star dots
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: CustomPaint(
                  painter: _StarDotsPainter(color: color),
                ),
              ),
            ),
            // Top shimmer
            Positioned(
              top: 0,
              left: 1,
              right: cellSize * 0.3,
              height: cellSize * 0.35,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarDotsPainter extends CustomPainter {
  final Color color;
  const _StarDotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(color.toARGB32());
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 0.5 + rng.nextDouble() * 1.0;
      paint.color = Colors.white.withValues(alpha: 0.3 + rng.nextDouble() * 0.4);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarDotsPainter old) =>
      old.color != color;
}

class _GalaxyPlacedCellWidget extends StatelessWidget {
  final Color color;
  final bool isElevated;
  const _GalaxyPlacedCellWidget({required this.color, this.isElevated = false});

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color c1 = hsl.withHue((hsl.hue - 30) % 360).toColor();
    final Color c2 = color;
    final Color c3 = hsl.withHue((hsl.hue + 40) % 360)
        .withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0))
        .toColor();
    final Color glow = hsl.withSaturation(1.0)
        .withLightness(0.6)
        .toColor();

    return AnimatedScale(
      scale: isElevated ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c1, c2, c3],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: c3.withValues(alpha: 0.35),
                    width: 0.75,
                  ),
                  boxShadow: [
                    if (isElevated)
                      BoxShadow(
                        color: glow.withValues(alpha: 0.65),
                        blurRadius: 14,
                        spreadRadius: 2,
                      )
                    else
                      BoxShadow(
                        color: c1.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(1, 2),
                      ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: CustomPaint(
                  painter: _StarDotsPainter(color: color),
                ),
              ),
            ),
            Positioned(
              top: 1,
              left: 2,
              right: 8,
              height: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _NeonClearedCellWidget — 3-phase clear animation for Neon
// =============================================================================
class _NeonClearedCellWidget extends StatefulWidget {
  final Color color;
  const _NeonClearedCellWidget({required this.color});

  @override
  State<_NeonClearedCellWidget> createState() => _NeonClearedCellWidgetState();
}

class _NeonClearedCellWidgetState extends State<_NeonClearedCellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  static const _totalMs = 600;

  static const _particleDirs = [
    Offset(0, -1), Offset(0.7, -0.7), Offset(1, 0), Offset(0.7, 0.7),
    Offset(0, 1), Offset(-0.7, 0.7), Offset(-1, 0), Offset(-0.7, -0.7),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _totalMs),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(widget.color);
    final Color bright = hsl
        .withLightness((hsl.lightness + 0.3).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation + 0.2).clamp(0.0, 1.0))
        .toColor();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final flashT = (t / 0.15).clamp(0.0, 1.0);
        final flashOpacity = flashT < 0.4
            ? flashT / 0.4
            : 1.0 - (flashT - 0.4) / 0.6;
        final tileT = ((t - 0.05) / 0.45).clamp(0.0, 1.0);
        final tileScale = 1.0 - _easeInCubic(tileT);
        final tileOpacity = tileT < 0.6 ? 1.0 : 1.0 - (tileT - 0.6) / 0.4;
        final partT = ((t - 0.20) / 0.80).clamp(0.0, 1.0);
        final particleProgress = _easeOutCubic(partT);
        final particleOpacity = partT < 0.5 ? 1.0 : 1.0 - (partT - 0.5) / 0.5;

        return SizedBox.expand(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (partT > 0)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ParticlePainter(
                      color: widget.color,
                      brightColor: bright,
                      directions: _particleDirs,
                      progress: particleProgress,
                      opacity: particleOpacity,
                    ),
                  ),
                ),
              if (tileScale > 0)
                Opacity(
                  opacity: tileOpacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: tileScale.clamp(0.0, 1.0),
                    child: Container(
                      margin: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [bright, widget.color],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.8),
                            blurRadius: 10 * (1 - tileT),
                            spreadRadius: 3 * (1 - tileT),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (flashOpacity > 0.01)
                Opacity(
                  opacity: flashOpacity.clamp(0.0, 1.0),
                  child: Container(
                    margin: const EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: bright.withValues(alpha: flashOpacity * 0.8),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static double _easeInCubic(double t) => t * t * t;
  static double _easeOutCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();
}

class _ParticlePainter extends CustomPainter {
  final Color color;
  final Color brightColor;
  final List<Offset> directions;
  final double progress;
  final double opacity;

  const _ParticlePainter({
    required this.color,
    required this.brightColor,
    required this.directions,
    required this.progress,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.72;

    for (int i = 0; i < directions.length; i++) {
      final dir = directions[i];
      final isLarge = i % 2 == 0;
      final pSize = isLarge ? size.width * 0.13 : size.width * 0.08;
      final stagger = isLarge ? 0.0 : 0.06;
      final localT = ((progress - stagger) / (1.0 - stagger)).clamp(0.0, 1.0);
      if (localT <= 0) continue;

      final dist = maxRadius * localT;
      final pos = center + dir * dist;
      final particleColor = i % 3 == 0 ? Colors.white : (i % 3 == 1 ? brightColor : color);

      final paint = Paint()
        ..color = particleColor.withValues(alpha: opacity * (1.0 - localT * 0.5))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(progress * math.pi * (isLarge ? 1.5 : -2.0) + i);
      final half = pSize / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(-half, -half, half, half),
          Radius.circular(pSize * 0.25),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress || old.opacity != opacity;
}

// =============================================================================
// 7. GLASS — สกินโปร่งแสง, ขอบสว่าง, เงานุ่ม
// =============================================================================
final BlockSkin glassSkin = BlockSkin(
  id: 'glass',
  displayName: 'GLASS',
  icon: Icons.window_rounded,
  accentColor: const Color(0xFF38BDF8),
  cellBuilder: ({required double cellSize, required Color color}) {
    return _GlassCellWidget(cellSize: cellSize, color: color);
  },
  placedCellBuilder: ({required Color color, required bool isElevated}) {
    return _GlassPlacedCellWidget(color: color, isElevated: isElevated);
  },
  animateNewCell: (child, index) => child
      .animate(delay: (index * 40).ms)
      .fadeIn(duration: 350.ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic)
      .shimmer(
        duration: 800.ms,
        color: Colors.white.withValues(alpha: 0.5),
        curve: Curves.easeOut,
      ),
  animatePlacedCell: (child) => child
      .animate()
      .fadeIn(duration: 200.ms)
      .scaleXY(
        begin: 0.85,
        end: 1.0,
        duration: 250.ms,
        curve: Curves.easeOutBack,
      ),
  clearCellBuilder: (color) => _GlassPlacedCellWidget(color: color)
      .animate()
      .scaleXY(begin: 1.0, end: 1.2, duration: 150.ms, curve: Curves.easeOut)
      .then()
      .scaleXY(begin: 1.2, end: 0.0, duration: 300.ms, curve: Curves.easeIn)
      .fadeOut(duration: 300.ms),
);

class _GlassCellWidget extends StatelessWidget {
  final double cellSize;
  final Color color;
  const _GlassCellWidget({required this.cellSize, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color.withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Top-left reflection
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: cellSize * 0.4,
                  height: cellSize * 0.4,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.5,
                      colors: [
                        Colors.white.withValues(alpha: 0.6),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassPlacedCellWidget extends StatelessWidget {
  final Color color;
  final bool isElevated;
  const _GlassPlacedCellWidget({required this.color, this.isElevated = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isElevated ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: color.withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: isElevated
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topLeft,
                    radius: 1.2,
                    colors: [
                      Colors.white.withValues(alpha: 0.7),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 8. SOFT — สกินดูนุ่มนวล, สีพาสเทล, ไม่มีขอบ, เงาฟุ้ง
// =============================================================================
final BlockSkin softSkin = BlockSkin(
  id: 'soft',
  displayName: 'SOFT',
  icon: Icons.cloud_rounded,
  accentColor: const Color(0xFFFCA5A5),
  cellBuilder: ({required double cellSize, required Color color}) {
    return _SoftCellWidget(cellSize: cellSize, color: color);
  },
  placedCellBuilder: ({required Color color, required bool isElevated}) {
    return _SoftPlacedCellWidget(color: color, isElevated: isElevated);
  },
  animateNewCell: (child, index) => child
      .animate(delay: (index * 60).ms)
      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
      .scale(
        begin: const Offset(0.5, 0.5),
        end: const Offset(1.0, 1.0),
        duration: 400.ms,
        curve: Curves.easeOutCubic,
      ),
  animatePlacedCell: (child) => child
      .animate()
      .fadeIn(duration: 250.ms)
      .scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1.0, 1.0),
        duration: 300.ms,
        curve: Curves.easeOutCubic,
      ),
  clearCellBuilder: (color) => _SoftPlacedCellWidget(color: color)
      .animate()
      .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.0, 0.0), duration: 350.ms, curve: Curves.easeInBack)
      .fadeOut(duration: 300.ms),
);

Color _toSoftColor(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withSaturation((hsl.saturation * 0.7).clamp(0.0, 1.0))
      .withLightness((hsl.lightness * 0.6 + 0.35).clamp(0.0, 0.9))
      .toColor();
}

class _SoftCellWidget extends StatelessWidget {
  final double cellSize;
  final Color color;
  const _SoftCellWidget({required this.cellSize, required this.color});

  @override
  Widget build(BuildContext context) {
    final softColor = _toSoftColor(color);

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            color: softColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: softColor.withValues(alpha: 0.5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.6),
                blurRadius: 2,
                offset: const Offset(-1, -1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftPlacedCellWidget extends StatelessWidget {
  final Color color;
  final bool isElevated;
  const _SoftPlacedCellWidget({required this.color, this.isElevated = false});

  @override
  Widget build(BuildContext context) {
    final softColor = _toSoftColor(color);

    return AnimatedScale(
      scale: isElevated ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: softColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isElevated
              ? [
                  BoxShadow(
                    color: softColor.withValues(alpha: 0.6),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: softColor.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
      ),
    );
  }
}

// =============================================================================
// 9. HOLO — สกินแบบโฮโลแกรม, เหลือบสีรุ้ง, วาววับ
// =============================================================================
final BlockSkin holoSkin = BlockSkin(
  id: 'holo',
  displayName: 'HOLO',
  icon: Icons.lens_blur_rounded,
  accentColor: const Color(0xFFE879F9),
  cellBuilder: ({required double cellSize, required Color color}) {
    return _HoloCellWidget(cellSize: cellSize, color: color);
  },
  placedCellBuilder: ({required Color color, required bool isElevated}) {
    return _HoloPlacedCellWidget(color: color, isElevated: isElevated);
  },
  animateNewCell: (child, index) => child
      .animate(delay: (index * 50).ms)
      .fadeIn(duration: 400.ms)
      .scaleXY(
        begin: 0.1,
        end: 1.0,
        duration: 500.ms,
        curve: Curves.elasticOut,
      )
      .rotate(begin: 0.1, end: 0, duration: 400.ms)
      .shimmer(
        duration: 1000.ms,
        color: Colors.white,
        curve: Curves.easeInOutSine,
      ),
  animatePlacedCell: (child) => child
      .animate()
      .fadeIn(duration: 250.ms)
      .scaleXY(
        begin: 0.5,
        end: 1.0,
        duration: 350.ms,
        curve: Curves.easeOutBack,
      )
      .shimmer(
        duration: 800.ms,
        color: Colors.white.withValues(alpha: 0.6),
      ),
  clearCellBuilder: (color) => _HoloPlacedCellWidget(color: color)
      .animate()
      .scaleXY(begin: 1.0, end: 0.0, duration: 400.ms, curve: Curves.easeInBack)
      .rotate(begin: 0.0, end: 0.2, duration: 400.ms)
      .fadeOut(duration: 300.ms),
);

class _HoloCellWidget extends StatelessWidget {
  final double cellSize;
  final Color color;
  const _HoloCellWidget({required this.cellSize, required this.color});

  @override
  Widget build(BuildContext context) {
    final HSLColor base = HSLColor.fromColor(color);
    final c1 = base.withHue((base.hue + 45) % 360).toColor();
    final c2 = color;
    final c3 = base.withHue((base.hue - 45) % 360).toColor();

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: 0.0,
              endAngle: math.pi * 2,
              colors: [c1, c2, c3, c1],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.5),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoloPlacedCellWidget extends StatelessWidget {
  final Color color;
  final bool isElevated;
  const _HoloPlacedCellWidget({required this.color, this.isElevated = false});

  @override
  Widget build(BuildContext context) {
    final HSLColor base = HSLColor.fromColor(color);
    final c1 = base.withHue((base.hue + 45) % 360).toColor();
    final c2 = color;
    final c3 = base.withHue((base.hue - 45) % 360).toColor();

    return AnimatedScale(
      scale: isElevated ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [c1, c2, c3, c1],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
          boxShadow: isElevated
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.8),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ]
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.6),
            width: 1.0,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.7),
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.3),
                    ],
                    stops: const [0.0, 0.4, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 10. CRYSTAL — สกินคริสตัล 3 มิติ, ตัดเหลี่ยมเพชร
// =============================================================================
final BlockSkin crystalSkin = BlockSkin(
  id: 'crystal',
  displayName: 'CRYSTAL',
  icon: Icons.diamond_rounded,
  accentColor: const Color(0xFF67E8F9),
  cellBuilder: ({required double cellSize, required Color color}) {
    return _CrystalCellWidget(cellSize: cellSize, color: color);
  },
  placedCellBuilder: ({required Color color, required bool isElevated}) {
    return _CrystalPlacedCellWidget(color: color, isElevated: isElevated);
  },
  animateNewCell: (child, index) => child
      .animate(delay: (index * 60).ms)
      .fadeIn(duration: 300.ms)
      .scaleXY(
        begin: 0.0,
        end: 1.0,
        duration: 400.ms,
        curve: Curves.easeOutBack,
      )
      .shimmer(
        duration: 600.ms,
        color: Colors.white,
      ),
  animatePlacedCell: (child) => child
      .animate()
      .fadeIn(duration: 150.ms)
      .scaleXY(
        begin: 0.7,
        end: 1.0,
        duration: 200.ms,
        curve: Curves.easeOutBack,
      ),
  clearCellBuilder: (color) => _CrystalPlacedCellWidget(color: color)
      .animate()
      .scaleXY(begin: 1.0, end: 1.5, duration: 150.ms, curve: Curves.easeOut)
      .then()
      .scaleXY(begin: 1.5, end: 0.0, duration: 250.ms, curve: Curves.easeIn)
      .fadeOut(duration: 250.ms),
);

class _CrystalCellWidget extends StatelessWidget {
  final double cellSize;
  final Color color;
  const _CrystalCellWidget({required this.cellSize, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: CustomPaint(
          painter: _CrystalPainter(color: color),
        ),
      ),
    );
  }
}

class _CrystalPlacedCellWidget extends StatelessWidget {
  final Color color;
  final bool isElevated;
  const _CrystalPlacedCellWidget({required this.color, this.isElevated = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isElevated ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack,
      child: Container(
        margin: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          boxShadow: isElevated
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.8),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ],
        ),
        child: CustomPaint(
          painter: _CrystalPainter(color: color),
        ),
      ),
    );
  }
}

class _CrystalPainter extends CustomPainter {
  final Color color;
  const _CrystalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color topColor = hsl.withLightness((hsl.lightness + 0.3).clamp(0.0, 1.0)).toColor();
    final Color leftColor = hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
    final Color rightColor = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
    final Color bottomColor = hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0)).toColor();
    
    final double w = size.width;
    final double h = size.height;
    final double insetX = w * 0.2;
    final double insetY = h * 0.2;

    // Top facet
    final Path topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - insetX, insetY)
      ..lineTo(insetX, insetY)
      ..close();
    canvas.drawPath(topPath, Paint()..color = topColor);

    // Bottom facet
    final Path bottomPath = Path()
      ..moveTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w - insetX, h - insetY)
      ..lineTo(insetX, h - insetY)
      ..close();
    canvas.drawPath(bottomPath, Paint()..color = bottomColor);

    // Left facet
    final Path leftPath = Path()
      ..moveTo(0, 0)
      ..lineTo(insetX, insetY)
      ..lineTo(insetX, h - insetY)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(leftPath, Paint()..color = leftColor);

    // Right facet
    final Path rightPath = Path()
      ..moveTo(w, 0)
      ..lineTo(w - insetX, insetY)
      ..lineTo(w - insetX, h - insetY)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(rightPath, Paint()..color = rightColor);

    // Center face
    final Path centerPath = Path()
      ..moveTo(insetX, insetY)
      ..lineTo(w - insetX, insetY)
      ..lineTo(w - insetX, h - insetY)
      ..lineTo(insetX, h - insetY)
      ..close();
    canvas.drawPath(centerPath, Paint()..color = color);

    // Top-left highlight point
    final Path highlightPath = Path()
      ..moveTo(insetX, insetY)
      ..lineTo(insetX + w * 0.2, insetY)
      ..lineTo(insetX, insetY + h * 0.2)
      ..close();
    canvas.drawPath(highlightPath, Paint()..color = Colors.white.withValues(alpha: 0.6));
  }

  @override
  bool shouldRepaint(covariant _CrystalPainter old) => old.color != color;
}

// =============================================================================
// 11. WOOD — สกินลายไม้แบบธรรมชาติ พร้อมอนิเมชันเด้งๆ นุ่มๆ
// =============================================================================
final BlockSkin woodSkin = BlockSkin(
  id: 'wood',
  displayName: 'WOOD',
  icon: Icons.forest_rounded,
  accentColor: const Color(0xFFD97706), // Amber-700
  cellBuilder: ({required double cellSize, required Color color}) {
    return _WoodCellWidget(cellSize: cellSize, color: color);
  },
  placedCellBuilder: ({required Color color, required bool isElevated}) {
    return _WoodPlacedCellWidget(color: color, isElevated: isElevated);
  },
  animateNewCell: (child, index) => child
      .animate(delay: (index * 45).ms)
      .fadeIn(duration: 350.ms)
      .scaleXY(
        begin: 0.2,
        end: 1.0,
        duration: 450.ms,
        curve: Curves.elasticOut,
      ),
  animatePlacedCell: (child) => child
      .animate()
      .fadeIn(duration: 200.ms)
      .scaleXY(
        begin: 0.6,
        end: 1.0,
        duration: 300.ms,
        curve: Curves.easeOutBack,
      ),
  clearCellBuilder: (color) => _WoodPlacedCellWidget(color: color)
      .animate()
      .scaleXY(begin: 1.0, end: 1.3, duration: 150.ms, curve: Curves.easeOutCubic)
      .then()
      .scaleXY(begin: 1.3, end: 0.0, duration: 250.ms, curve: Curves.easeInBack)
      .fadeOut(duration: 250.ms),
);

class _WoodCellWidget extends StatelessWidget {
  final double cellSize;
  final Color color;
  const _WoodCellWidget({required this.cellSize, required this.color});

  @override
  Widget build(BuildContext context) {
    // Transform color to a warm, woody tone
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color woodBase = hsl
        .withSaturation((hsl.saturation * 0.6 + 0.3).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 0.7 + 0.15).clamp(0.0, 1.0))
        .toColor();
    final Color grainColor = hsl
        .withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0))
        .withSaturation(hsl.saturation * 0.5)
        .toColor();

    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          decoration: BoxDecoration(
            color: woodBase,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: grainColor.withValues(alpha: 0.7),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 3,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: CustomPaint(
              painter: _WoodGrainPainter(grainColor: grainColor.withValues(alpha: 0.3)),
            ),
          ),
        ),
      ),
    );
  }
}

class _WoodPlacedCellWidget extends StatelessWidget {
  final Color color;
  final bool isElevated;
  const _WoodPlacedCellWidget({required this.color, this.isElevated = false});

  @override
  Widget build(BuildContext context) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color woodBase = hsl
        .withSaturation((hsl.saturation * 0.6 + 0.3).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 0.7 + 0.15).clamp(0.0, 1.0))
        .toColor();
    final Color grainColor = hsl
        .withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0))
        .withSaturation(hsl.saturation * 0.5)
        .toColor();
    final Color highlight = hsl
        .withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0))
        .toColor();

    return AnimatedScale(
      scale: isElevated ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack,
      child: Container(
        margin: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          color: woodBase,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: grainColor.withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: isElevated
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(1, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              CustomPaint(
                painter: _WoodGrainPainter(grainColor: grainColor.withValues(alpha: 0.4)),
                child: Container(),
              ),
              // Bevel highlight
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 3,
                child: Container(
                  color: highlight.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WoodGrainPainter extends CustomPainter {
  final Color grainColor;
  const _WoodGrainPainter({required this.grainColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = grainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Draw some organic-looking grain lines
    for (int i = 0; i < 4; i++) {
      final yOffset = h * 0.25 * i;
      path.moveTo(0, yOffset + h * 0.1);
      path.quadraticBezierTo(
        w * 0.5,
        yOffset - h * 0.1,
        w,
        yOffset + h * 0.2,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WoodGrainPainter old) => old.grainColor != grainColor;
}

// =============================================================================
// CYBER — High-tech cyberpunk style with circuits
// =============================================================================
final BlockSkin cyberSkin = BlockSkin(
  id: 'cyber',
  displayName: 'CYBER',
  icon: Icons.memory_rounded,
  accentColor: const Color(0xFFFFFF00), // Cyberpunk yellow
  cellBuilder: ({required double cellSize, required Color color}) {
    return _CyberCellWidget(cellSize: cellSize, color: color);
  },
  placedCellBuilder: ({required Color color, required bool isElevated}) {
    return _CyberPlacedCellWidget(color: color, isElevated: isElevated);
  },
  animateNewCell: (child, index) => child
      .animate(delay: (index * 20).ms)
      .scale(begin: const Offset(0.0, 1.0), end: const Offset(1.0, 1.0), duration: 250.ms, curve: Curves.easeOutExpo)
      .fadeIn(duration: 200.ms),
  animatePlacedCell: (child) => child
      .animate()
      .scaleXY(begin: 1.2, end: 1.0, duration: 150.ms, curve: Curves.easeIn)
      .shimmer(color: Colors.white, duration: 300.ms),
  clearCellBuilder: (color) => _CyberPlacedCellWidget(color: color)
      .animate()
      .fadeOut(duration: 300.ms)
      .scaleXY(begin: 1.0, end: 0.0, duration: 300.ms, curve: Curves.easeInBack),
);

class _CyberCellWidget extends StatelessWidget {
  final double cellSize;
  final Color color;
  const _CyberCellWidget({required this.cellSize, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: cellSize * 0.4,
              height: cellSize * 0.4,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.3),
                border: Border.all(color: color, width: 1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CyberPlacedCellWidget extends StatelessWidget {
  final Color color;
  final bool isElevated;
  const _CyberPlacedCellWidget({required this.color, this.isElevated = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border.all(color: color, width: isElevated ? 2.5 : 1.5),
        borderRadius: BorderRadius.circular(2),
        boxShadow: isElevated ? [
          BoxShadow(
            color: color.withValues(alpha: 0.8),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ] : [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 2,
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 2, left: 2, width: 4, height: 4,
            child: Container(color: color),
          ),
          Positioned(
            bottom: 2, right: 2, width: 4, height: 4,
            child: Container(color: color),
          ),
          Center(
            child: Container(
              width: 12, height: 2, color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
