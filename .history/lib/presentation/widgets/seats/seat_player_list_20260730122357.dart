import 'package:flutter/material.dart';
import 'seat_player_tile.dart';

class SeatPlayerList extends StatelessWidget {
  final List<int> seats;
  final bool isLeft;
  final List<TextEditingController> controllers;
  final List<GlobalKey> textFieldKeys;
  final Function(int) onTap;
  final Function(int, String) onChanged;
  final List<avatarU

  const SeatPlayerList({
    super.key,
    required this.seats,
    required this.isLeft,
    required this.controllers,
    required this.textFieldKeys,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: seats.map((seat) {
        final index = seat - 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SeatPlayerTile(
              seatNumber: seat,
              controller: controllers[index],
              textFieldKey: textFieldKeys[index],
                avatarUrl: avatarUrls.length > index ? avatarUrls[index] : '',  // 🔥 ПЕРЕДАЁМ КОНКРЕТНУЮ

              isLeft: isLeft,
              onTap: () => onTap(index),
              onChanged: (value) => onChanged(index, value),
            ),
          ),
        );
      }).toList(),
    );
  }
}