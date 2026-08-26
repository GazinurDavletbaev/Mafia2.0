import 'package:flutter/material.dart';
import 'package:mdi_plus/mdi_plus.dart';

class SeatPlayerTile extends StatelessWidget {
  final int seatNumber;
  final TextEditingController controller;
  final bool isLeft;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final String avatarUrl;

  const SeatPlayerTile({
    super.key,
    required this.seatNumber,
    required this.controller,
    required this.isLeft,
    required this.onTap,
    required this.onChanged,
    this.avatarUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool hasText = controller.text.trim().isNotEmpty;

    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: hasText ? Colors.transparent : Colors.grey,
            shape: BoxShape.circle,
            image: hasText && avatarUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasText
              ? (avatarUrl.isEmpty
                  ? Icon(
                      Mdi.accountCircle,
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                      size: 50,
                    )
                  : null)
              : Center(
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
      ],
    );
  }
}
