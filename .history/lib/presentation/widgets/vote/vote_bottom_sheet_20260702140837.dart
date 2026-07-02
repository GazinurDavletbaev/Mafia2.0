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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Кандидат
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Игрок ${widget.controller.currentSeat}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          // Кнопки 10-8
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVoteButton(10, context),
              const SizedBox(width: 16),
              _buildVoteButton(9, context),
              const SizedBox(width: 16),
              _buildVoteButton(8, context),
            ],
          ),
          const SizedBox(height: 16),
          // Кнопки 7-5
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVoteButton(7, context),
              const SizedBox(width: 16),
              _buildVoteButton(6, context),
              const SizedBox(width: 16),
              _buildVoteButton(5, context),
            ],
          ),
          const SizedBox(height: 16),
          // Кнопки 4-2
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVoteButton(4, context),
              const SizedBox(width: 16),
              _buildVoteButton(3, context),
              const SizedBox(width: 16),
              _buildVoteButton(2, context),
            ],
          ),
          const SizedBox(height: 16),
          // Кнопки 1-0
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildVoteButton(1, context),
              const SizedBox(width: 16),
              _buildVoteButton(0, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton(int value, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
          backgroundColor: isSelected
              ? Colors.green.shade700
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          foregroundColor: isDark ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}