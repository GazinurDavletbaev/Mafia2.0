import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_help/application/providers/timer_provider.dart';

class FloatingTimerWidget extends ConsumerStatefulWidget {
  const FloatingTimerWidget({super.key});

  @override
  ConsumerState<FloatingTimerWidget> createState() =>
      _FloatingTimerWidgetState();
}

class _FloatingTimerWidgetState extends ConsumerState<FloatingTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _seconds = 0;
  bool _isVisible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
  }

  void _showTimer(int seconds) {
    setState(() {
      _seconds = seconds;
      _isVisible = true;
    });
    _controller.reset();
    _controller.forward();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _hideTimer();
        }
      });
    });
  }

  void _hideTimer() {
    _timer?.cancel();
    setState(() {
      _isVisible = false;
    });
    _controller.reset();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = ref.watch(floatingTimerProvider);

    // 🔥 ЕСЛИ ТАЙМЕР ПОЯВИЛСЯ — ПОКАЗЫВАЕМ
    if (seconds != null && seconds > 0 && !_isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTimer(seconds);
      });
    }

    // 🔥 ЕСЛИ ТАЙМЕР ЗАКОНЧИЛСЯ — СКРЫВАЕМ
    if (seconds == null && _isVisible) {
      _hideTimer();
    }

    if (!_isVisible) return const SizedBox.shrink();

    return Positioned(
      top: 60,
      right: 16,
      child: GestureDetector(
        onTap: _hideTimer,
        child: SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🔥 КРУГОВОЙ ИНДИКАТОР
              CircularProgressIndicator(
                value: _seconds / 60,
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
                    '$_seconds',
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
  }
}