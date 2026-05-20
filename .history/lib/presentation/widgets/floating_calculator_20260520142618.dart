import 'package:flutter/material.dart';

class FloatingCalculator extends StatefulWidget {
  final Widget child;

  const FloatingCalculator({
    super.key,
    required this.child,
  });

  @override
  State<FloatingCalculator> createState() => _FloatingCalculatorState();
}

class _FloatingCalculatorState extends State<FloatingCalculator> {
  Offset _position = const Offset(20, 100);
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            _isDragging = true;
          });
        },
        onLongPressUp: () {
          setState(() {
            _isDragging = false;
          });
        },
        onPanUpdate: (details) {
          if (_isDragging) {
            setState(() {
              _position += details.delta;
              _position = Offset(
                _position.dx.clamp(0, MediaQuery.of(context).size.width - 200),
                _position.dy.clamp(0, MediaQuery.of(context).size.height - 150),
              );
            });
          }
        },
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}