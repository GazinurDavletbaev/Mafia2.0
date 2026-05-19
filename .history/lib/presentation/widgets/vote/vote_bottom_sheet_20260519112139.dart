import 'package:flutter/material.dart';
import 'package:mafia_help/domain/helpers/vote_controller.dart';

class VoteBottomSheet extends StatefulWidget {
  final VoteController controller;
  final Function(int) onVoteSubmitted;

  const VoteBottomSheet({
    super.key,
    required this.controller,
    required this.onVoteSubmitted,
  });

  @override
  State<VoteBottomSheet> createState() => _VoteBottomSheetState();
}

class _VoteBottomSheetState extends State<VoteBottomSheet> {
  int? _selectedVotes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кандидат
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Игрок ${widget.controller.currentSeat}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Кнопки 10-8
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVoteButton(10),
              const SizedBox(width: 16),
              _buildVoteButton(9),
              const SizedBox(width: 16),
              _buildVoteButton(8),
            ],
          ),
          const SizedBox(height: 16),
          // Кнопки 7-5
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVoteButton(7),
              const SizedBox(width: 16),
              _buildVoteButton(6),
              const SizedBox(width: 16),
              _buildVoteButton(5),
            ],
          ),
          const SizedBox(height: 16),
          // Кнопки 4-2
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVoteButton(4),
              const SizedBox(width: 16),
              _buildVoteButton(3),
              const SizedBox(width: 16),
              _buildVoteButton(2),
            ],
          ),
          const SizedBox(height: 16),
          // Кнопки 1-0
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVoteButton(1),
              const SizedBox(width: 16),
              _buildVoteButton(0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(int value) {
    final isSelected = _selectedVotes == value;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedVotes = value;
          });
          widget.onVoteSubmitted(value);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green : Colors.grey.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '$value',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}