import 'package:flutter/material.dart';

class SeatPlayerTile extends StatelessWidget {
  final int seatNumber;
  final TextEditingController controller;
  final GlobalKey textFieldKey;
  final bool isLeft;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final String avatarUrl;

  const SeatPlayerTile({
    super.key,
    required this.seatNumber,
    required this.controller,
    required this.textFieldKey,
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 🔥 АВАТАРКА СВЕРХУ
        Container(
          width: 30,
          height: 30,
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
                  ? Image.asset(
                      'assets/mafia_logo.png',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
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
        const SizedBox(height: 4),
        // 🔥 ПОЛЕ ВВОДА СНИЗУ
        Container(
          key: textFieldKey,
          child: TextField(
            controller: controller,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color ?? Colors.white,
              fontSize: 12,
            ),
            onChanged: onChanged,
            onTap: onTap,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '$seatNumber',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                fontSize: 10,
              ),
              filled: true,
              fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
