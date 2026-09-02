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
  final String arrowDirection; // 'up' или 'down'
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
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: FadeTransition(
          opacity: _controller,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: ClipRect(
                child: CustomPaint(
                  painter: TipPainter(
                    arrowX: widget.arrowX,
                    arrowDirection: widget.arrowDirection,
                    isDark: isDark,
                  ),
                  child: Material(
                    elevation: 12,
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: widget.arrowDirection == 'up' ? 20.0 : 16.0,
                          bottom: widget.arrowDirection == 'down' ? 20.0 : 16.0,
                          left: 20.0,
                          right: 20.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 52.0,
                                  height: 52.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [color, color.withOpacity(0.6)],
                                    ),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Icon(
                                    widget.icon,
                                    color: Colors.white,
                                    size: 28.0,
                                  ),
                                ),
                                const SizedBox(width: 14.0),
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: 18.0,
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
                                    size: 20.0,
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
                            const SizedBox(height: 10.0),
                            Text(
                              widget.description,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16.0),
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
                                      borderRadius: BorderRadius.circular(12.0),
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
    final paint = Paint()
      ..color = isDark ? Colors.grey.shade900 : Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    if (arrowDirection == 'down') {
      final double startX = arrowX;
      final double startY = size.height - 10.0;

      path.moveTo(startX - 12.0, startY);
      path.lineTo(startX, startY + 14.0);
      path.lineTo(startX + 12.0, startY);
      path.close();

      canvas.drawPath(path, paint);

      if (isDark) {
        final borderPaint = Paint()
          ..color = Colors.grey.shade800
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawPath(path, borderPaint);
      }
    } else if (arrowDirection == 'up') {
      final double startX = arrowX;
      final double startY = 10.0;

      path.moveTo(startX - 12.0, startY);
      path.lineTo(startX, startY - 14.0);
      path.lineTo(startX + 12.0, startY);
      path.close();

      canvas.drawPath(path, paint);

      if (isDark) {
        final borderPaint = Paint()
          ..color = Colors.grey.shade800
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawPath(path, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(TipPainter oldDelegate) {
    return oldDelegate.arrowX != arrowX ||
        oldDelegate.arrowDirection != arrowDirection;
  }
}
