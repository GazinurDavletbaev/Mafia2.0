import 'package:flutter/material.dart';

class CandidatesBar extends StatelessWidget {
  final List<int> seats;
  final void Function(int seat) onTap;

  const CandidatesBar({
    super.key,
    required this.seats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: seats.length,
        itemBuilder: (context, index) {
          final seat = seats[index];
          return GestureDetector(
            onTap: () => onTap(seat),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$seat',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}