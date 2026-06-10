import 'package:flutter/material.dart';
import '../../../data/local/models/sub_phase.dart';
import '../../../domain/helpers/vote_controller.dart';

class DayColumn extends StatelessWidget {
  final SubPhase currentSubPhase;
  final List<int> nominatedSeats;
  final List<int> tiedSeats;
  final List<int> partialBestMove;
  final int eliminationVotes;
  final int? currentSpeaker;
  final VoteController? voteController;

  const DayColumn({
    super.key,
    required this.currentSubPhase,
    required this.nominatedSeats,
    required this.tiedSeats,
    required this.partialBestMove,
    required this.eliminationVotes,
    this.currentSpeaker,
    this.voteController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildIcon(),
          const SizedBox(height: 8),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    String tooltip;

    switch (currentSubPhase) {
      case SubPhase.speeches:
        icon = Icons.mic;
        tooltip = 'Речи';
        break;
      case SubPhase.voting:
      case SubPhase.revote:
        icon = Icons.how_to_vote;
        tooltip = currentSubPhase == SubPhase.revote
            ? 'Переголосование'
            : 'Голосование';
        break;
      case SubPhase.tieBreak:
        icon = Icons.gavel;
        tooltip = 'Перестрелка';
        break;
      case SubPhase.eliminationVote:
        icon = Icons.warning;
        tooltip = 'Голосование за подъём';
        break;
      case SubPhase.finalWord:
        icon = Icons.hourglass_empty;
        tooltip = 'Заключительная минута';
        break;
      case SubPhase.finalWordKill:
        icon = Icons.speaker;
        tooltip = 'Заключительная минута убитого';
        break;
      case SubPhase.bestMove:
        icon = Icons.emoji_events;
        tooltip = 'Лучший ход';
        break;
      default:
        icon = Icons.thumb_up;
        tooltip = 'Кандидаты';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Tooltip(
        message: tooltip,
        child: Icon(icon, color: Colors.grey.shade600, size: 20),
      ),
    );
  }

  Widget _buildContent() {
    // Best move
    if (currentSubPhase == SubPhase.bestMove && partialBestMove.isNotEmpty) {
      return Column(
        children: partialBestMove.map((seat) => _numberChip(seat)).toList(),
      );
    }

    // Elimination vote
    if (currentSubPhase == SubPhase.eliminationVote) {
      return Column(
        children: [
          ...tiedSeats.map((seat) => _numberChip(seat)).toList(),
          if (eliminationVotes > 0) _numberChip(eliminationVotes, isRed: true),
        ],
      );
    }

    // TieBreak, FinalWord
    if (currentSubPhase == SubPhase.tieBreak ||
        currentSubPhase == SubPhase.finalWord ||
        currentSubPhase == SubPhase.finalWordKill) {
      final speakers = currentSubPhase == SubPhase.finalWordKill
          ? [currentSpeaker].whereType<int>().toList()
          : (tiedSeats.isNotEmpty
              ? tiedSeats
              : [currentSpeaker].whereType<int>().toList());

      return Column(
        children: speakers.map((seat) {
          final isCurrent = currentSpeaker == seat;
          return _numberChip(seat, isCurrent: isCurrent);
        }).toList(),
      );
    }

    // Voting, Revote
    if (currentSubPhase == SubPhase.voting ||
        currentSubPhase == SubPhase.revote) {
      final candidates =
          currentSubPhase == SubPhase.revote && tiedSeats.isNotEmpty
              ? tiedSeats
              : nominatedSeats;

      return Column(
        children: candidates.map((seat) {
          final isCurrent = voteController?.currentSeat == seat;
          final voteCount = voteController?.results[seat];
          return _voteChip(seat, isCurrent, voteCount);
        }).toList(),
      );
    }

    // Speeches and others
    if (nominatedSeats.isNotEmpty) {
      return Column(
        children: nominatedSeats.map((seat) => _numberChip(seat)).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _numberChip(int value, {bool isCurrent = false, bool isRed = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isRed
            ? Colors.red.shade800
            : (isCurrent ? Colors.green.shade800 : Colors.orange.shade800),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$value',
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _voteChip(int seat, bool isCurrent, int? voteCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.green.shade800 : Colors.orange.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text('$seat',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          if (voteCount != null && voteCount > 0)
            Text('$voteCount',
                style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}
