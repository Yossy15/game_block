import 'package:block/domain/models/block.dart';
import 'package:block/presentation/view_models/skin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// แสดงผล Block เป็นตาราง cell โดยใช้ skin ที่เลือก
class BlockWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(skinNotifierProvider);

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
            Widget cell = skin.cellBuilder(
              cellSize: cellSize,
              color: block.color,
            );

            if (isNew) {
              cell = skin.animateNewCell(cell, currentIndex);
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
