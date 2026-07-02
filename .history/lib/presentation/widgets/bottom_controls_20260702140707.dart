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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PhaseNavButton(icon: Icons.arrow_back_ios, onTap: onBack),
        showCalculator ? _buildCalculator(context) : const MinimizeButton(),
        PhaseNavButton(icon: Icons.arrow_forward_ios, onTap: onForward),
      ],
    );
  }

  Widget _buildCalculator(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: 180,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calcButton(10, context),
              _calcButton(9, context),
              _calcButton(8, context),
              _calcButton(7, context),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calcButton(6, context),
              _calcButton(5, context),
              _calcButton(4, context),
              _calcButton(3, context),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _calcButton(2, context),
              _calcButton(1, context),
              _calcButton(0, context),
              _battleButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcButton(int n, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ElevatedButton(
          onPressed: () => onCalculatorTap(n),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            foregroundColor: isDark ? Colors.white : Colors.black87,
            padding: EdgeInsets.zero,
            minimumSize: const Size(30, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            n.toString(),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _battleButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: ElevatedButton(
          onPressed: () => onCalculatorTap(-1),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            foregroundColor: isDark ? Colors.white : Colors.black87,
            padding: EdgeInsets.zero,
            minimumSize: const Size(30, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Icon(
            Icons.share,
            size: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
