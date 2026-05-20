import 'package:flutter/material.dart';
import 'minimize_button.dart';
import 'phase_nav_button.dart';

class BottomControls extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onForward;
  final bool showCalculator;
  final void Function(int) onCalculatorTap;

  const BottomControls({
    super.key,
    required this.onBack,
    required this.onForward,
    this.showCalculator = false,
    required this.onCalculatorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PhaseNavButton(icon: Icons.arrow_back_ios, onTap: onBack),

        showCalculator ? _buildCalculator() : const MinimizeButton(),

        PhaseNavButton(icon: Icons.arrow_forward_ios, onTap: onForward),
      ],
    );
  }

  Widget _buildCalculator() {
    return SizedBox(
      width: 180,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calcButton(10),
              _calcButton(9),
              _calcButton(8),
              _calcButton(7),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calcButton(6),
              _calcButton(5),
              _calcButton(4),
              _calcButton(3),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calcButton(2),
              _calcButton(1),
              _calcButton(0),
              _battleButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcButton(int n) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ElevatedButton(
          onPressed: () => onCalculatorTap(n),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            minimumSize: const Size(30, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(n.toString(), style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }

  Widget _battleButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ElevatedButton(
          onPressed: () => onCalculatorTap(-1),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            minimumSize: const Size(30, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const Icon(Icons.war, size: 16),
        ),
      ),
    );
  }
}
