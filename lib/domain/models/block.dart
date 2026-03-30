import 'package:flutter/material.dart';

/// โมเดลของ Block ที่ใช้ในเกม
class Block {
  final List<List<int>> shape;
  final Color color;

  const Block({required this.shape, required this.color});

  /// จำนวนแถวของ block
  int get rows => shape.length;

  /// จำนวนคอลัมน์ของ block (ใช้แถวแรกเป็นตัวอ้างอิง)
  int get cols => shape.isNotEmpty ? shape[0].length : 0;
}
