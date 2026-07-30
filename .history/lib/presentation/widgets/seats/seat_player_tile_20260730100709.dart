import 'package:flutter/material.dart';

class SeatPlayerTile extends StatelessWidget {
  final int seatNumber;
  final TextEditingController controller;
  final GlobalKey textFieldKey;
  final bool isLeft;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;

  const SeatPlayerTile({
    super.key,
    required this.seatNumber,
    required this.controller,
    required this.textFieldKey,
    required this.isLeft,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$seatNumber',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            key: textFieldKey,
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                fontSize: 13,
              ),
              onChanged: onChanged,
              onTap: onTap,
              decoration: InputDecoration(
                hintText: 'Игрок $seatNumber',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  fontSize: 12,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                isDense: true,
              ),
              textAlign: isLeft ? TextAlign.left : TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }
}