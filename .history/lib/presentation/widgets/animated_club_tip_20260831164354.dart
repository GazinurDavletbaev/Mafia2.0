// lib/presentation/widgets/animated_club_tip.dart
import 'package:flutter/material.dart';

class AnimatedClubTip extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback? onAction;

  final double top;
  final double left;
  final double width;
  final double? height;
  final double arrowX;
  final String arrowDirection;
  final String title;
  final String description;
  final IconData icon;
  final String buttonText;
  final Color? accentColor;

  const AnimatedClubTip({
    super.key,
    required this.onDismiss,
    this.onAction,
    required this.top,
    required this.left,
    required this.width,
    this.height,
    required this.arrowX,
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
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
      child: SizedBox(
        width: widget.width,
        height: widget.height ?? 200.0,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: CustomPaint(
            painter: TipPainter(
              arrowX: widget.arrowX,
              arrowDirection: widget.arrowDirection,
              isDark: isDark,
            ),
            child: Container(
              margin: EdgeInsets.only(
                top: widget.arrowDirection == 'up' ? 20.0 : 0.0,
                bottom: widget.arrowDirection == 'down' ? 20.0 : 0.0,
              ),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(widget.icon, color: color, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _controller.reverse().then((_) {
                              widget.onDismiss();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
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
                            : Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _controller.reverse().then((_) {
                              if (widget.onAction != null) widget.onAction!();
                              widget.onDismiss();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.buttonText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TipPainter extends CustomPainter {
  final double arrowX;
  final String arrowDirection;
  final bool isDark;

  const TipPainter({
    required this.arrowX,
    required this.arrowDirection,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor = isDark ? Colors.grey.shade900 : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    // Стрелка
    final paint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path();

    if (arrowDirection == 'down') {
      final x = arrowX;
      final y = size.height - 12.0;

      // Треугольник
      path.moveTo(x - 14.0, y);
      path.lineTo(x, y + 18.0);
      path.lineTo(x + 14.0, y);
      path.close();

      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    } else if (arrowDirection == 'up') {
      final x = arrowX;
      final y = 12.0;

      path.moveTo(x - 14.0, y);
      path.lineTo(x, y - 18.0);
      path.lineTo(x + 14.0, y);
      path.close();

      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(TipPainter oldDelegate) {
    return oldDelegate.arrowX != arrowX ||
        oldDelegate.arrowDirection != arrowDirection;
  }
}
