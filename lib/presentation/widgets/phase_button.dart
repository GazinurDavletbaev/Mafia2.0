import 'package:flutter/material.dart';

class PhaseButton extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onForward;

  const PhaseButton({
    super.key,
    required this.onBack,
    required this.onForward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back, size: 30),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onForward,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_forward, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}