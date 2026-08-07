import 'package:flutter/material.dart';

class TimerOverAll extends StatefulWidget {
  final int seconds;
  final VoidCallback? onComplete;

  const TimerOverAll({
    super.key,
    required this.seconds,
    this.onComplete,
  });

  @override
  State<TimerOverAll> createState() => _TimerOverAllState();
}

class _TimerOverAllState extends State<TimerOverAll>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentSeconds = 0;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.seconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    );
    _controller.forward();

    // Таймер на уменьшение
    Future.delayed(Duration.zero, _startTimer);
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_currentSeconds > 0) {
        setState(() {
          _currentSeconds--;
        });
        _startTimer();
      } else {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentSeconds / widget.seconds;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: 60,
          right: 16,
          child: GestureDetector(
            onTap: () {
              // При нажатии скрываем
              widget.onComplete?.call();
            },
            child: SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 🔥 КРУГОВОЙ ИНДИКАТОР
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                  // 🔥 ЦИФРЫ ВНУТРИ
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_currentSeconds',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}