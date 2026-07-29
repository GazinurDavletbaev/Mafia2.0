// lib/presentation/widgets/app_card.dart
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isDark;

  const AppCard({
    super.key,
    required this.child,
    required this.isDark,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardColor = color ?? (isDark ? Colors.grey.shade800 : Colors.white);
    final BorderRadius cardBorderRadius = borderRadius ?? BorderRadius.circular(12);

    Widget card = Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: cardBorderRadius,
      ),
      elevation: elevation ?? 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: cardBorderRadius,
        child: card,
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 8),
      child: card,
    );
  }
}