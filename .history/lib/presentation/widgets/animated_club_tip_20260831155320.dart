// lib/presentation/widgets/animated_club_tip.dart
import 'package:flutter/material.dart';

class AnimatedClubTip extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback? onAction; // 👈 Действие при нажатии

  const AnimatedClubTip({
    super.key,
    required this.onDismiss,
    this.onAction,
  });

  @override
  State<AnimatedClubTip> createState() => _AnimatedClubTipState();
}

class _AnimatedClubTipState extends State<AnimatedClubTip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.1, end: 0).animate(
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
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // 🔥 Затемнение фона
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _controller.reverse().then((_) {
                    widget.onDismiss();
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),

            // 🔥 Основная подсказка с анимацией
            Positioned(
              top: size.height * 0.25,
              left: 16,
              right: 16,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Material(
                    elevation: 24,
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    Colors.purple.shade900,
                                    Colors.purple.shade700,
                                  ]
                                : [
                                    Colors.purple.shade400,
                                    Colors.purple.shade600,
                                  ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.group_add,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '👥 Резиденты клуба',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'Узнайте кто в команде',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _controller.reverse().then((_) {
                                          widget.onDismiss();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Нажмите на эту кнопку, чтобы посмотреть всех '
                                'резидентов клуба. Здесь вы найдете информацию '
                                'об игроках, их статистику и рейтинг.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // 🔥 Маленькая подсказка с указанием
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        color: Colors.white.withOpacity(0.6),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Нажмите сюда',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _controller.reverse().then((_) {
                                            // 👈 Сначала закрываем подсказку
                                            widget.onDismiss();
                                            // 👈 Потом выполняем действие (переход на вкладку участников)
                                            if (widget.onAction != null) {
                                              widget.onAction!();
                                            }
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              Colors.purple.shade700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: const Text(
                                          'Попробовать',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
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
          ],
        );
      },
    );
  }
}
