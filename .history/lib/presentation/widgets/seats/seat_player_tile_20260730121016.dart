import 'package:flutter/material.dart';

class SeatPlayerTile extends StatelessWidget {
  final int seatNumber;
  final TextEditingController controller;
  final GlobalKey textFieldKey;
  final bool isLeft;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;
  final String avatarUrl;
  final bool hasPlayer; // 🔥 ЕСТЬ ЛИ ИГРОК

  const SeatPlayerTile({
    super.key,
    required this.seatNumber,
    required this.controller,
    required this.textFieldKey,
    required this.isLeft,
    required this.onTap,
    required this.onChanged,
    this.avatarUrl = '',
    this.hasPlayer = false, // 🔥 ПО УМОЛЧАНИЮ НЕТ ИГРОКА
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // 🔥 КОНТЕЙНЕР: НОМЕР ИЛИ АВАТАРКА
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: hasPlayer ? Colors.transparent : Colors.grey,
            shape: BoxShape.circle,
            image: hasPlayer && avatarUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasPlayer
              ? (avatarUrl.isEmpty
                  ? Image.asset(
                      'assets/mafia_logo.png',
                      width: 20,
                      height: 20,
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
