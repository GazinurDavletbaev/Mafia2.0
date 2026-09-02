import 'package:flutter/material.dart';

enum TooltipDirection {
  up,
  down,
  left,
  right,
  upLeft,
  upRight,
  downLeft,
  downRight,
}

class AnimatedClubTip extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback? onAction;
  final double top;
  final double left;
  final double width;
  final double height; // Сделаем обязательной, чтобы избежать overflow
  final TooltipDirection direction;
  final double arrowOffset; // 0.0 to 1.0

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
    this.height = 180.0, // Увеличили дефолт, чтобы текст влезал
    this.direction = TooltipDirection.downRight,
    this.arrowOffset = 0.75, // Позиция выхода хвоста (ближе к правому краю)
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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
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

    // Размер зоны под хвостик
    const tailZone = 30.0;

    return Positioned(
      top: widget.top,
      left: widget.left,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width + tailZone,
          height: widget.height + tailZone,
          child: CustomPaint(
            painter: OrganicTooltipPainter(
              direction: widget.direction,
              arrowOffset: widget.arrowOffset,
              cardWidth: widget.width,
              cardHeight: widget.height,
              tailZone: tailZone,
              backgroundColor: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              borderColor:
                  isDark ? Colors.grey.shade800 : const Color(0xFFE0E0E0),
              shadowColor: Colors.black.withOpacity(0.12),
            ),
            child: Padding(
              // Сдвигаем контент, чтобы он не залезал на зону хвоста
              padding: EdgeInsets.only(
                right: (widget.direction == TooltipDirection.right ||
                        widget.direction == TooltipDirection.upRight ||
                        widget.direction == TooltipDirection.downRight)
                    ? tailZone
                    : 0,
                bottom: (widget.direction == TooltipDirection.down ||
                        widget.direction == TooltipDirection.downLeft ||
                        widget.direction == TooltipDirection.downRight)
                    ? tailZone
                    : 0,
                left: (widget.direction == TooltipDirection.left ||
                        widget.direction == TooltipDirection.upLeft ||
                        widget.direction == TooltipDirection.downLeft)
                    ? tailZone
                    : 0,
                top: (widget.direction == TooltipDirection.up ||
                        widget.direction == TooltipDirection.upLeft ||
                        widget.direction == TooltipDirection.upRight)
                    ? tailZone
                    : 0,
              ),
              child: _buildContent(isDark, color),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _controller.reverse().then((_) => widget.onDismiss());
                },
                child: Icon(Icons.close,
                    size: 18,
                    color:
                        isDark ? Colors.grey.shade400 : Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.description,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16), // Фиксированный отступ вместо Spacer
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                _controller.reverse().then((_) {
                  if (widget.onAction != null) widget.onAction!();
                  widget.onDismiss();
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.buttonText,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrganicTooltipPainter extends CustomPainter {
  final TooltipDirection direction;
  final double arrowOffset;
  final double cardWidth;
  final double cardHeight;
  final double tailZone;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;

  OrganicTooltipPainter({
    required this.direction,
    required this.arrowOffset,
    required this.cardWidth,
    required this.cardHeight,
    required this.tailZone,
    required this.backgroundColor,
    required this.borderColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final radius = 16.0;

    // Тело карточки всегда начинается с 0,0 (для простоты, хвост дорисовывается снаружи)
    // Но мы должны сдвинуть тело, если хвост смотрит ВВЕРХ или ВЛЕВО
    double offsetX = 0;
    double offsetY = 0;

    if (direction == TooltipDirection.left ||
        direction == TooltipDirection.upLeft ||
        direction == TooltipDirection.downLeft) {
      offsetX = tailZone;
    }
    if (direction == TooltipDirection.up ||
        direction == TooltipDirection.upLeft ||
        direction == TooltipDirection.upRight) {
      offsetY = tailZone;
    }

    final bodyRect = Rect.fromLTWH(offsetX, offsetY, cardWidth, cardHeight);

    // Рисуем основное тело
    path.addRRect(RRect.fromRectAndRadius(bodyRect, Radius.circular(radius)));

    // Дорисовываем хвост
    _drawTail(path, bodyRect);

    // Тень (рисуется первой, под фигурой)
    canvas.drawShadow(path, shadowColor, 12, true);

    // Заливка
    canvas.drawPath(path, Paint()..color = backgroundColor);

    // Тонкая граница
    canvas.drawPath(
        path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  void _drawTail(Path path, Rect body) {
    // Здесь магия кривых. Мы рисуем ТОЛЬКО downRight идеально, как на картинке.
    // Остальные направления сделаны по аналогии, но downRight - эталон.

    switch (direction) {
      case TooltipDirection.downRight:
        // Точка выхода из нижней грани
        final startX = body.left + (body.width * arrowOffset);
        final startY = body.bottom;

        // Кончик стрелки (вниз и вправо)
        final tipX = startX + tailZone * 1.1;
        final tipY = startY + tailZone * 1.1;

        path.moveTo(startX, startY);

        // Плавный изгиб вниз-вправо (кубическая кривая для идеальной гладкости)
        path.cubicTo(
            startX,
            startY + tailZone * 0.8, // Контрольная точка 1 (тянем вниз)
            tipX - tailZone * 0.2,
            tipY - tailZone * 0.2, // Контрольная точка 2 (подводим к кончику)
            tipX,
            tipY // Кончик
            );

        // Возврат от кончика к телу (вторая сторона хвоста)
        path.cubicTo(
            tipX - tailZone * 0.5,
            tipY - tailZone * 0.6, // Контрольная точка 3
            startX + tailZone * 0.6,
            startY + tailZone * 0.1, // Контрольная точка 4
            startX + tailZone * 0.5,
            startY // Точка возврата на нижнюю грань
            );

        path.close();
        break;

      case TooltipDirection.down:
        final cx = body.left + (body.width * arrowOffset);
        path.moveTo(cx - 12, body.bottom);
        path.quadraticBezierTo(
            cx, body.bottom + tailZone, cx + 12, body.bottom);
        path.close();
        break;

      case TooltipDirection.right:
        final cy = body.top + (body.height * arrowOffset);
        path.moveTo(body.right, cy - 12);
        path.quadraticBezierTo(body.right + tailZone, cy, body.right, cy + 12);
        path.close();
        break;

      case TooltipDirection.downLeft:
        final startX = body.left + (body.width * (1.0 - arrowOffset));
        final startY = body.bottom;
        final tipX = startX - tailZone * 1.1;
        final tipY = startY + tailZone * 1.1;
        path.moveTo(startX, startY);
        path.cubicTo(startX, startY + tailZone * 0.8, tipX + tailZone * 0.2,
            tipY - tailZone * 0.2, tipX, tipY);
        path.cubicTo(
            tipX + tailZone * 0.5,
            tipY - tailZone * 0.6,
            startX - tailZone * 0.6,
            startY + tailZone * 0.1,
            startX - tailZone * 0.5,
            startY);
        path.close();
        break;

      case TooltipDirection.upRight:
        final startX = body.left + (body.width * arrowOffset);
        final startY = body.top;
        final tipX = startX + tailZone * 1.1;
        final tipY = startY - tailZone * 1.1;
        path.moveTo(startX, startY);
        path.cubicTo(startX, startY - tailZone * 0.8, tipX - tailZone * 0.2,
            tipY + tailZone * 0.2, tipX, tipY);
        path.cubicTo(
            tipX - tailZone * 0.5,
            tipY + tailZone * 0.6,
            startX + tailZone * 0.6,
            startY - tailZone * 0.1,
            startX + tailZone * 0.5,
            startY);
        path.close();
        break;

      case TooltipDirection.up:
        final cx = body.left + (body.width * arrowOffset);
        path.moveTo(cx - 12, body.top);
        path.quadraticBezierTo(cx, body.top - tailZone, cx + 12, body.top);
        path.close();
        break;

      case TooltipDirection.left:
        final cy = body.top + (body.height * arrowOffset);
        path.moveTo(body.left, cy - 12);
        path.quadraticBezierTo(body.left - tailZone, cy, body.left, cy + 12);
        path.close();
        break;

      case TooltipDirection.upLeft:
        final startX = body.left + (body.width * (1.0 - arrowOffset));
        final startY = body.top;
        final tipX = startX - tailZone * 1.1;
        final tipY = startY - tailZone * 1.1;
        path.moveTo(startX, startY);
        path.cubicTo(startX, startY - tailZone * 0.8, tipX + tailZone * 0.2,
            tipY + tailZone * 0.2, tipX, tipY);
        path.cubicTo(
            tipX + tailZone * 0.5,
            tipY + tailZone * 0.6,
            startX - tailZone * 0.6,
            startY - tailZone * 0.1,
            startX - tailZone * 0.5,
            startY);
        path.close();
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
