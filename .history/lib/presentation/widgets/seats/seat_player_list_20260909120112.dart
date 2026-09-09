import 'package:flutter/material.dart';
import 'seat_player_tile.dart';

class SeatPlayerList extends StatelessWidget {
  final List<int> seats;
  final bool isLeft;
  final List<TextEditingController> controllers;
  final List<String> avatarUrls;
  final Function(int) onTap;
  final Function(int, String) onChanged;
  final Map<String, GlobalKey>? tutorialKeys;

  const SeatPlayerList({
    super.key,
    required this.seats,
    required this.isLeft,
    required this.controllers,
    required this.avatarUrls,
    required this.onTap,
    required this.onChanged,
    this.tutorialKeys,
  });

  @override
  Widget build(BuildContext context) {
    final seatplayer = tutorialKeys?['seat_player'];
    return Column(
      children: seats.asMap().entries.map((entry) {
        final index = entry.key;
        final seat = entry.value;
        // 🔥 ТОЛЬКО ПЕРВЫЙ ЭЛЕМЕНТ (индекс 0) ПОЛУЧАЕТ КЛЮЧ
        final isFirst = index == 4;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SeatPlayerTile(
              key: isFirst ? seatplayer : null,
              seatNumber: seat,
              controller: controllers[seat - 1],
              avatarUrl:
                  avatarUrls.length > seat - 1 ? avatarUrls[seat - 1] : '',
              isLeft: isLeft,
              onTap: () => onTap(seat - 1),
              onChanged: (value) => onChanged(seat - 1, value),
            ),
          ),
        );
      }).toList(),
    );
  }
}
