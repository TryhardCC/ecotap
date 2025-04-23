import 'package:flutter/material.dart';

class FloatingNumber {
  final String text;
  final Offset position;
  final Color color;
  final DateTime createdAt;

  FloatingNumber({
    required this.text,
    required this.position,
    required this.color,
    required this.createdAt,
  });
} 