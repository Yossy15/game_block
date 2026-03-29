import 'package:block/logic/game_controller.dart';
import 'package:block/models/block.dart';
import 'package:block/screen/widgets/draggable_block.dart';
import 'package:block/screen/widgets/score_popup_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

/// กริด 8x8 ที่รับ Block ด้วย DragTarget เดียวครอบทั้งกริด
class Display extends StatefulWidget {
  final GameController controller;

  const Display({super.key, required this.controller});

  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> with SingleTickerProviderStateMixin {
  final GlobalKey _gridKey = GlobalKey();

  int? _hoverRow;
  int? _hoverCol;
  Block? _hoverBlock;
  bool _canPlaceHover = false;

  // ── Pulse animation for grid lines ──
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  GameController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Position Calculation
  // ---------------------------------------------------------------------------

  ({int row, int col})? _calcGridPosition(Offset globalPos, Block block) {
    final renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final adjustedGlobalPos = Offset(
      globalPos.dx,
      globalPos.dy + dragVerticalOffset,
    );
    final localPos = renderBox.globalToLocal(adjustedGlobalPos);
    final cellSize = renderBox.size.width / gridSize;

    final startRow = ((localPos.dy / cellSize) - (block.rows / 2)).round();
    final startCol = ((localPos.dx / cellSize) - (block.cols / 2)).round();

    return (row: startRow, col: startCol);
  }

  // ---------------------------------------------------------------------------
  // Drag Callbacks
  // ---------------------------------------------------------------------------

  void _onMove(DragTargetDetails<BlockDragData> details) {
    final block = details.data.block;
    final pos = _calcGridPosition(details.offset, block);
    if (pos == null) {
      _clearHover();
      return;
    }

    final canPlace = _ctrl.canPlace(block, pos.row, pos.col);
    if (pos.row != _hoverRow ||
        pos.col != _hoverCol ||
        _canPlaceHover != canPlace) {
      setState(() {
        _hoverBlock = block;
        _hoverRow = pos.row;
        _hoverCol = pos.col;
        _canPlaceHover = canPlace;
      });
    }
  }

  void _onAccept(DragTargetDetails<BlockDragData> details) {
    final block = details.data.block;
    final pos = _calcGridPosition(details.offset, block);
    if (pos != null && _ctrl.canPlace(block, pos.row, pos.col)) {
      _ctrl.placeBlock(block, pos.row, pos.col, details.data.slotIndex);
    }
    _clearHover();
  }

  void _clearHover() {
    if (_hoverRow == null && _hoverCol == null && _hoverBlock == null) return;
    setState(() {
      _hoverRow = null;
      _hoverCol = null;
      _hoverBlock = null;
      _canPlaceHover = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Hover Info
  // ---------------------------------------------------------------------------

  HoverInfo _getHoverInfo() {
    final indices = <int>{};
    final fullRows = <int>{};
    final fullCols = <int>{};

    if (_hoverRow == null ||
        _hoverCol == null ||
        _hoverBlock == null ||
        !_canPlaceHover) {
      return HoverInfo(indices, fullRows, fullCols);
    }

    for (int r = 0; r < _hoverBlock!.rows; r++) {
      for (int c = 0; c < _hoverBlock!.cols; c++) {
        if (_hoverBlock!.shape[r][c] == 1) {
          final gr = _hoverRow! + r;
          final gc = _hoverCol! + c;
          if (gr >= 0 && gr < gridSize && gc >= 0 && gc < gridSize) {
            indices.add(gr * gridSize + gc);
          }
        }
      }
    }

    for (int r = 0; r < gridSize; r++) {
      bool rowFull = true;
      for (int c = 0; c < gridSize; c++) {
        if (_ctrl.grid[r][c] == null && !indices.contains(r * gridSize + c)) {
          rowFull = false;
          break;
        }
      }
      if (rowFull) fullRows.add(r);
    }

    for (int c = 0; c < gridSize; c++) {
      bool colFull = true;
      for (int r = 0; r < gridSize; r++) {
        if (_ctrl.grid[r][c] == null && !indices.contains(r * gridSize + c)) {
          colFull = false;
          break;
        }
      }
      if (colFull) fullCols.add(c);
    }

    return HoverInfo(indices, fullRows, fullCols);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.9;
    final screenHeight = MediaQuery.of(context).size.height * 0.6;
    final raw = screenWidth < screenHeight ? screenWidth : screenHeight;

    // snap ให้หาร gridSize ลงตัวเป๊ะ ไม่มีเศษ pixel เลย
    final double gridSizePx = (raw / gridSize).floorToDouble() * gridSize;
    final double cellSize = gridSizePx / gridSize;
    final hoverInfo = _getHoverInfo();

    return Center(
      child: DragTarget<BlockDragData>(
        onWillAcceptWithDetails: (_) => true,
        onMove: _onMove,
        onAcceptWithDetails: _onAccept,
        onLeave: (_) => _clearHover(),
        builder: (context, candidateData, rejectedData) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 150),
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, _) {
                return _BoardContainer(
                  size: gridSizePx,
                  pulseValue: _pulseAnim.value,
                  child: SizedBox(
                    key: _gridKey,
                    width: gridSizePx,
                    height: gridSizePx,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1. Grid Painter
                        CustomPaint(
                          size: Size(gridSizePx, gridSizePx),
                          painter: _GridPainter(
                            cellSize: cellSize,
                            hoverInfo: hoverInfo,
                            canPlace: _canPlaceHover,
                            hoverColor: _hoverBlock?.color,
                            pulseValue: _pulseAnim.value,
                          ),
                        ),

                        // 2. Placed cells
                        for (int row = 0; row < gridSize; row++)
                          for (int col = 0; col < gridSize; col++)
                            if (_ctrl.grid[row][col] != null)
                              Positioned(
                                key: ValueKey(
                                  'pos-$row-$col-${_ctrl.grid[row][col]!.toARGB32()}',
                                ),
                                left: col * cellSize,
                                top: row * cellSize,
                                width: cellSize,
                                height: cellSize,
                                child: AnimatedPlacedCell(
                                  color: _ctrl.grid[row][col]!,
                                  isElevated:
                                      hoverInfo.fullRows.contains(row) ||
                                      hoverInfo.fullCols.contains(col),
                                ),
                              ),

                        // 3. Clearing cells
                        for (final cell in _ctrl.clearingCells)
                          Positioned(
                            key: ValueKey(
                              'clearing-${cell.row}-${cell.col}-${DateTime.now().millisecondsSinceEpoch}',
                            ),
                            left: cell.col * cellSize,
                            top: cell.row * cellSize,
                            width: cellSize,
                            height: cellSize,
                            child: AnimatedClearedCell(color: cell.color),
                          ),

                        // 4. Score Popups
                        for (final popup in _ctrl.activePopups)
                          Positioned(
                            key: ValueKey('popup-${popup.id}'),
                            left: popup.gridX * cellSize,
                            top: popup.gridY * cellSize,
                            child: FractionalTranslation(
                              translation: const Offset(-0.5, -0.5),
                              child: ScorePopupWidget(popup: popup),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Board outer container — glass card with neon border
// =============================================================================
class _BoardContainer extends StatelessWidget {
  final double size;
  final double pulseValue; // 0.0–1.0 for border glow pulse
  final Widget child;

  const _BoardContainer({
    required this.size,
    required this.pulseValue,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final glowOpacity = 0.25 + pulseValue * 0.18;
    const double radius = 12.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Glow shadow (ไม่กินพื้นที่ของ content) ─────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius + 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(glowOpacity),
                    blurRadius: 28,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
          ),

          // ── Content: ขนาด size × size เป๊ะ ─────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: SizedBox(width: size, height: size, child: child),
          ),

          // ── Neon border วาดทับ (foreground, IgnorePointer) ──────────────
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: const Color(
                      0xFF30D5C8,
                    ).withOpacity(0.35 + pulseValue * 0.20),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// AnimatedClearedCell — 3-phase: flash → shatter → particles dissolve
// =============================================================================
class AnimatedClearedCell extends StatefulWidget {
  final Color color;
  const AnimatedClearedCell({super.key, required this.color});

  @override
  State<AnimatedClearedCell> createState() => _AnimatedClearedCellState();
}

class _AnimatedClearedCellState extends State<AnimatedClearedCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  // ── Phase timings (ทั้งหมด 600ms) ─────────────────────────────────────
  // 0.00–0.15 : white flash
  // 0.05–0.45 : tile scale down + shimmer
  // 0.20–1.00 : 8 particles ระเบิดออก + fade
  static const _totalMs = 600;

  // Particle directions (8 ทิศ)
  static const _particleDirs = [
    Offset(0, -1), // N
    Offset(0.7, -0.7), // NE
    Offset(1, 0), // E
    Offset(0.7, 0.7), // SE
    Offset(0, 1), // S
    Offset(-0.7, 0.7), // SW
    Offset(-1, 0), // W
    Offset(-0.7, -0.7), // NW
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
        final t = _ctrl.value; // 0.0 → 1.0

        // ── Phase 1: white flash (0–0.15) ─────────────────────────────
        final flashT = (t / 0.15).clamp(0.0, 1.0);
        final flashOpacity = flashT < 0.4
            ? flashT /
                  0.4 // ramp up
            : 1.0 - (flashT - 0.4) / 0.6; // ramp down

        // ── Phase 2: tile (0.05–0.50) ─────────────────────────────────
        final tileT = ((t - 0.05) / 0.45).clamp(0.0, 1.0);
        final tileScale = 1.0 - _easeInCubic(tileT);
        final tileOpacity = tileT < 0.6 ? 1.0 : 1.0 - (tileT - 0.6) / 0.4;

        // ── Phase 3: particles (0.20–1.00) ────────────────────────────
        final partT = ((t - 0.20) / 0.80).clamp(0.0, 1.0);
        final particleProgress = _easeOutCubic(partT);
        final particleOpacity = partT < 0.5 ? 1.0 : 1.0 - (partT - 0.5) / 0.5;

        return SizedBox.expand(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // ── Particles ──────────────────────────────────────────
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

              // ── Tile (main block) ───────────────────────────────────
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
                            color: widget.color.withOpacity(0.8),
                            blurRadius: 10 * (1 - tileT),
                            spreadRadius: 3 * (1 - tileT),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── White flash overlay ─────────────────────────────────
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
                          color: bright.withOpacity(flashOpacity * 0.8),
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

// ── Particle painter ────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final Color color;
  final Color brightColor;
  final List<Offset> directions;
  final double progress; // 0→1 eased
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
    final maxRadius = size.width * 0.72; // ระยะสูงสุดที่ particle จะบินไป

    for (int i = 0; i < directions.length; i++) {
      final dir = directions[i];

      // สลับขนาด particle เล็ก/ใหญ่ตาม index
      final isLarge = i % 2 == 0;
      final pSize = isLarge ? size.width * 0.13 : size.width * 0.08;

      // stagger เล็กน้อย particle คู่ออกก่อน
      final stagger = isLarge ? 0.0 : 0.06;
      final localT = ((progress - stagger) / (1.0 - stagger)).clamp(0.0, 1.0);
      if (localT <= 0) continue;

      final dist = maxRadius * localT;
      final pos = center + dir * dist;

      // particle สีสลับระหว่าง bright และ color
      final particleColor = i % 3 == 0
          ? Colors.white
          : (i % 3 == 1 ? brightColor : color);

      final paint = Paint()
        ..color = particleColor.withOpacity(opacity * (1.0 - localT * 0.5))
        ..style = PaintingStyle.fill;

      // วาด particle เป็น rounded square หมุนตาม progress
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
// AnimatedPlacedCell — glossy tile with top-light sheen
// =============================================================================
class AnimatedPlacedCell extends StatelessWidget {
  final Color color;
  final bool isElevated;

  const AnimatedPlacedCell({
    super.key,
    required this.color,
    this.isElevated = false,
  });

  @override
  Widget build(BuildContext context) {
    // Derive lighter/darker shades for depth
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
                    color: color.withOpacity(0.75),
                    blurRadius: 16,
                    spreadRadius: 3,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(-1, -1),
                  ),
                ] else
                  BoxShadow(
                    color: dark.withOpacity(0.55),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Top-left gloss sheen
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
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .scaleXY(
          begin: 0.4,
          end: 1.0,
          duration: 380.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 180.ms);
  }
}

// =============================================================================
// GridPainter — dark background, neon grid lines, holographic hover
// =============================================================================
class _GridPainter extends CustomPainter {
  final double cellSize;
  final HoverInfo hoverInfo;
  final bool canPlace;
  final Color? hoverColor;
  final double pulseValue;

  _GridPainter({
    required this.cellSize,
    required this.hoverInfo,
    required this.canPlace,
    this.hoverColor,
    required this.pulseValue,
  });

  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color _bgEven = Color(0xFF0D1117);
  static const Color _bgOdd = Color(0xFF111820);
  static const Color _gridLine = Color(0xFF1E3A4A);
  static const Color _neonCyan = Color(0xFF00E5FF);
  static const Color _neonRed = Color(0xFFFF2D78);

  @override
  void paint(Canvas canvas, Size size) {
    final evenFill = Paint()..color = _bgEven;
    final oddFill = Paint()..color = _bgOdd;

    // ── Grid line paint (pulse brightness) ──────────────────────────────
    final lineAlpha = 0.3 + pulseValue * 0.12;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = _gridLine.withOpacity(lineAlpha);

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final rect = Rect.fromLTWH(
          col * cellSize,
          row * cellSize,
          cellSize,
          cellSize,
        );
        canvas.drawRect(rect, (row + col) % 2 == 0 ? evenFill : oddFill);
        canvas.drawRect(rect, linePaint);

        final index = row * gridSize + col;
        final willClear =
            hoverInfo.fullRows.contains(row) ||
            hoverInfo.fullCols.contains(col);

        if (hoverInfo.indices.contains(index) && hoverColor != null) {
          _paintHoverCell(canvas, rect, willClear);
        } else if (willClear) {
          _paintPreClearHint(canvas, rect);
        }
      }
    }

    // ── Corner accent dots ──────────────────────────────────────────────
    _paintCornerDots(canvas, size);
  }

  void _paintHoverCell(Canvas canvas, Rect rect, bool willClear) {
    final color = canPlace ? _neonCyan : _neonRed;

    // Outer glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.18 + pulseValue * 0.08)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, willClear ? 12 : 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(willClear ? 3 : 1.5),
        const Radius.circular(5),
      ),
      glowPaint,
    );

    // Fill
    final fillPaint = Paint()
      ..color = color.withOpacity(willClear ? 0.38 : 0.28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(4)),
      fillPaint,
    );

    // Border accent
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = willClear ? 1.5 : 1.0
      ..color = color.withOpacity(willClear ? 0.85 : 0.55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(4)),
      borderPaint,
    );

    // ── "Will clear" diagonal hatch lines ─────────────────────────────
    if (willClear) {
      final hatchPaint = Paint()
        ..color = color.withOpacity(0.18)
        ..strokeWidth = 1.0;
      const step = 5.0;
      final inner = rect.deflate(1.5);
      canvas.save();
      canvas.clipRRect(
        RRect.fromRectAndRadius(inner, const Radius.circular(4)),
      );
      for (double d = -inner.width; d < inner.width * 2; d += step) {
        canvas.drawLine(
          Offset(inner.left + d, inner.top),
          Offset(inner.left + d + inner.height, inner.bottom),
          hatchPaint,
        );
      }
      canvas.restore();
    }
  }

  void _paintPreClearHint(Canvas canvas, Rect rect) {
    // ไม่ใช่ส่วนของบล็อกที่ลาก แต่แถวนี้จะถูกเคลียร์ — hint เบาๆ
    final hintPaint = Paint()
      ..color = _neonCyan.withOpacity(0.06 + pulseValue * 0.04);
    canvas.drawRect(rect, hintPaint);
  }

  void _paintCornerDots(Canvas canvas, Size size) {
    // มุม 4 ด้านของกระดาน — เป็น decorative accent
    final dotPaint = Paint()
      ..color = _neonCyan.withOpacity(0.4 + pulseValue * 0.25);
    const r = 3.0;
    final offsets = [
      const Offset(r, r),
      Offset(size.width - r, r),
      Offset(r, size.height - r),
      Offset(size.width - r, size.height - r),
    ];
    for (final o in offsets) {
      canvas.drawCircle(o, r, dotPaint);
    }

    // Scan line ตัดขวางกระดาน (เคลื่อนช้าๆ ตาม pulse)
    final scanY = size.height * pulseValue;
    final scanPaint = Paint()
      ..color = _neonCyan.withOpacity(0.04)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), scanPaint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.hoverInfo != hoverInfo ||
      old.canPlace != canPlace ||
      old.hoverColor != hoverColor ||
      (old.pulseValue - pulseValue).abs() > 0.005;
}

// =============================================================================
// HoverInfo
// =============================================================================
class HoverInfo {
  final Set<int> indices;
  final Set<int> fullRows;
  final Set<int> fullCols;

  HoverInfo(this.indices, this.fullRows, this.fullCols);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HoverInfo &&
          runtimeType == other.runtimeType &&
          indices == other.indices &&
          fullRows == other.fullRows &&
          fullCols == other.fullCols;

  @override
  int get hashCode => indices.hashCode ^ fullRows.hashCode ^ fullCols.hashCode;
}
