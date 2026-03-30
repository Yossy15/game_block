import 'package:block/core/constants/game_constants.dart';
import 'package:block/domain/models/block.dart';
import 'package:block/presentation/widgets/block_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

const double dragVerticalOffset = -80.0; // ความสูงที่บล็อกจะลอยขึ้นจากนิ้ว

/// ข้อมูลที่ส่งไปพร้อม Drag event
class BlockDragData {
  final Block block;
  final int slotIndex;

  const BlockDragData({required this.block, required this.slotIndex});
}

/// Block ที่ลากได้ (Draggable wrapper)
class DraggableBlock extends StatelessWidget {
  final Block block;
  final int slotIndex;

  const DraggableBlock({
    super.key,
    required this.block,
    required this.slotIndex,
  });

  @override
  Widget build(BuildContext context) {
    final data = BlockDragData(block: block, slotIndex: slotIndex);

    // คำนวณ cellSize ให้ตรงกับใน Display.dart เพื่อให้ตอนลากขนาดไม่โดด
    final screenWidth = MediaQuery.of(context).size.width * 0.9;
    final screenHeight = MediaQuery.of(context).size.height * 0.6;
    final gridSizeValue = screenWidth < screenHeight
        ? screenWidth
        : screenHeight;
    final gridCellSize = gridSizeValue / gridSize;

    return Draggable<BlockDragData>(
      data: data,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      // dragAnchorStrategy: childDragAnchorStrategy,
      feedback: Transform.translate(
        offset: const Offset(0, dragVerticalOffset),
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: Material(
            color: Colors.transparent,
            child: BlockWidget(block: block, cellSize: gridCellSize)
                .animate()
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.05, 1.05),
                  duration: 100.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
        ),
      ),
      childWhenDragging: Container(
        width: 120, // สอดคล้องกับขนาดที่ User ต้องการ
        height: 120,
        color: Colors.transparent,
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Opacity(
              opacity: 0.2,
              child: BlockWidget(block: block, isNew: false),
            ),
          ),
        ),
      ),
      child: Container(
        width: 120,
        height: 120,
        color: Colors.transparent,
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: BlockWidget(
              block: block,
              cellSize: 24, // ขนาดปกติในช่องเก็บ
              isNew: true, // ให้เด้งตอนเกิดใหม่
            ),
          ),
        ),
      ),
    );
  }
}

