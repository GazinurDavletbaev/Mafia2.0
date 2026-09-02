// lib/presentation/widgets/tutorial/tutorials/base_tutorial.dart
import 'package:flutter/material.dart';

class TutorialStep {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final GlobalKey? targetKey;
  final Offset? customPosition;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color textColor;

  const TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.targetKey,
    this.customPosition,
    this.width,
    this.height,
    this.backgroundColor = Colors.deepPurple,
    this.textColor = Colors.white,
  });
}

abstract class TutorialGroup {
  String get screenName;
  List<TutorialStep> get steps;

  Future<bool> shouldShow(String stepId) async {
    return true;
  }
}
