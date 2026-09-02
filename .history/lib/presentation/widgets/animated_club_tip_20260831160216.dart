// lib/presentation/widgets/animated_club_tip.dart
import 'package:flutter/material.dart';

class AnimatedClubTip extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback? onAction;

  // 👇 Позиция
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  // 👇 Размер
  final double width;
  final double? height;

  // 👇 Стрелка
  final bool showArrow;
  final double arrowOffset;
  final String arrowDirection; // 'up', 'down', 'left', 'right'

  // 👇 Контент
  final String title;
  final String description;
  final IconData icon;
  final String buttonText;
  final Color? accentColor;

  const AnimatedClubTip({
    super.key,
    required this.onDismiss,
    this.onAction,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.width = double.infinity,
    this.height,
    this.showArrow = false,
    this.arrowOffset = 0,
    this.arrowDirection = 'down',
    required this.title,
    required this.description,
    required this.icon,
    this.buttonText = 'Понятно',
    this.accentColor,
  });

  @override
  State<AnimatedClubTip> createState() => _AnimatedClubTipState();
}

class _AnimatedClubTipState extends State<AnimatedClubTip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.accentColor ?? Colors.purple;

    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: FadeTransition(
          opacity: _controller,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 🔥 Стрелка
                  if (widget.showArrow)
                    Positioned(
                      left: widget.arrowOffset,
                      top: widget.arrowDirection == 'down' ? -10 : null,
                      bottom: widget.arrowDirection == 'up' ? -10 : null,
                      child: _buildArrow(color, isDark),
                    ),

                  // 🔥 Основная карточка
                  Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(20),
                    color: isDark ? Colors.grey.shade900 : Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [color, color.withOpacity(0.6)],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    widget.icon,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 20,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    _controller.reverse().then((_) {
                                      widget.onDismiss();
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _controller.reverse().then((_) {
                                      if (widget.onAction != null) {
                                        widget.onAction!();
                                      }
                                      widget.onDismiss();
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: color.withOpacity(0.1),
                                    foregroundColor: color,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(widget.buttonText),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrow(Color color, bool isDark) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
          left: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Transform.rotate(
        angle: _getArrowRotation(),
        child: Container(),
      ),
    );
  }

  double _getArrowRotation() {
    switch (widget.arrowDirection) {
      case 'up':
        return 3.14159;
      case 'down':
        return 0;
      case 'left':
        return -1.5708;
      case 'right':
        return 1.5708;
      default:
        return 0;
    }
  }
}
