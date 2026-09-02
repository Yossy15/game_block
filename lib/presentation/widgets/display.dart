import 'package:block/core/constants/game_constants.dart';
import 'package:block/domain/models/block.dart';
import 'package:block/presentation/view_models/game_state.dart';
import 'package:block/presentation/view_models/game_view_model.dart';
import 'package:block/presentation/view_models/skin_provider.dart';
import 'package:block/presentation/widgets/draggable_block.dart';
import 'package:block/presentation/widgets/score_popup_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// กริด 8x8 ที่รับ Block ด้วย DragTarget เดียวครอบทั้งกริด
class Display extends StatefulWidget {
  final GameState state;
  final GameViewModel viewModel;

  const Display({
    super.key,
    required this.state,
    required this.viewModel,
  });

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

  GameState get _state => widget.state;
  GameViewModel get _viewModel => widget.viewModel;

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

    // Drag feedback is rendered a bit above the finger, so convert the pointer
    // position to the visual center of the block before mapping it onto the grid.
    final adjustedGlobalPos = Offset(
      globalPos.dx,
      globalPos.dy + dragVerticalOffset,
    );
    final localPos = renderBox.globalToLocal(adjustedGlobalPos);
    final cellSize = renderBox.size.width / gridSize;

    final rawRow = ((localPos.dy / cellSize) - (block.rows / 2)).round();
    final rawCol = ((localPos.dx / cellSize) - (block.cols / 2)).round();
    final startRow = rawRow.clamp(-block.rows + 1, gridSize - 1);
    final startCol = rawCol.clamp(-block.cols + 1, gridSize - 1);

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

    final canPlace = _viewModel.canPlace(block, pos.row, pos.col);
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
    if (pos != null && _viewModel.canPlace(block, pos.row, pos.col)) {
      _viewModel.placeBlock(block, pos.row, pos.col, details.data.slotIndex);
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
        if (_state.grid[r][c] == null && !indices.contains(r * gridSize + c)) {
          rowFull = false;
          break;
        }
      }
      if (rowFull) fullRows.add(r);
    }

    for (int c = 0; c < gridSize; c++) {
      bool colFull = true;
      for (int r = 0; r < gridSize; r++) {
        if (_state.grid[r][c] == null && !indices.contains(r * gridSize + c)) {
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
                            if (_state.grid[row][col] != null)
                              Positioned(
                                key: ValueKey(
                                  'pos-$row-$col-${_state.grid[row][col]!.toARGB32()}',
                                ),
                                left: col * cellSize,
                                top: row * cellSize,
                                width: cellSize,
                                height: cellSize,
                                child: AnimatedPlacedCell(
                                  color: _state.grid[row][col]!,
                                  isElevated:
                                      hoverInfo.fullRows.contains(row) ||
                                      hoverInfo.fullCols.contains(col),
                                ),
                              ),

                        // 3. Clearing cells
                        for (final cell in _state.clearingCells)
                          Positioned(
                            key: ValueKey(
                              'clearing-${cell.row}-${cell.col}',
                            ),
                            left: cell.col * cellSize,
                            top: cell.row * cellSize,
                            width: cellSize,
                            height: cellSize,
                            child: AnimatedClearedCell(color: cell.color),
                          ),

                        // 4. Score Popups
                        for (final popup in _state.activePopups)
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
  final double pulseValue; // 0.0–1.0 (Kept for compatibility, but ignored in minimal design)
  final Widget child;

  const _BoardContainer({
    required this.size,
    required this.pulseValue,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const double radius = 12.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE5E7EB), // subtle gray border
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1.5),
        child: child,
      ),
    );
  }
}

// =============================================================================
// AnimatedClearedCell — delegates to current skin's clearCellBuilder
// =============================================================================
class AnimatedClearedCell extends ConsumerWidget {
  final Color color;
  const AnimatedClearedCell({super.key, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(skinNotifierProvider);
    return skin.clearCellBuilder(color);
  }
}

// =============================================================================
// AnimatedPlacedCell — delegates to current skin's placedCellBuilder
// =============================================================================
class AnimatedPlacedCell extends ConsumerWidget {
  final Color color;
  final bool isElevated;

  const AnimatedPlacedCell({
    super.key,
    required this.color,
    this.isElevated = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(skinNotifierProvider);

    return skin.animatePlacedCell(
      skin.placedCellBuilder(
        color: color,
        isElevated: isElevated,
      ),
    );
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
  final double pulseValue; // Kept for interface compatibility but ignored

  _GridPainter({
    required this.cellSize,
    required this.hoverInfo,
    required this.canPlace,
    this.hoverColor,
    required this.pulseValue,
  });

  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color _bgEven = Color(0xFFFAFAFA);
  static const Color _bgOdd = Color(0xFFF4F4F5);
  static const Color _gridLine = Color(0xFFE5E7EB);
  static const Color _accentBlue = Color(0xFF3B82F6);
  static const Color _accentRed = Color(0xFFEF4444);

  @override
  void paint(Canvas canvas, Size size) {
    final evenFill = Paint()..color = _bgEven;
    final oddFill = Paint()..color = _bgOdd;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _gridLine;

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
  }

  void _paintHoverCell(Canvas canvas, Rect rect, bool willClear) {
    final color = canPlace ? _accentBlue : _accentRed;

    // Fill
    final fillPaint = Paint()
      ..color = color.withValues(alpha: willClear ? 0.4 : 0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(4)),
      fillPaint,
    );

    // Border accent
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = color.withValues(alpha: 0.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(4)),
      borderPaint,
    );

    // ── "Will clear" diagonal hatch lines ─────────────────────────────
    if (willClear) {
      final hatchPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 1.5;
      const step = 6.0;
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
    final hintPaint = Paint()
      ..color = _accentBlue.withValues(alpha: 0.08);
    canvas.drawRect(rect, hintPaint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.hoverInfo != hoverInfo ||
      old.canPlace != canPlace ||
      old.hoverColor != hoverColor;
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


