import 'player_timer_type.dart';
import 'player_card.dart';

class PlayerGrid extends StatelessWidget {
  final List<PlayerModel> players;
  final int? currentSpeaker;
  final PlayerTimerType timerType;
  final VoidCallback? onTimerComplete;
  final Function(int) onTap;
  final Function(int) onLongPress;

  const PlayerGrid({
    super.key,
    required this.players,
    this.currentSpeaker,
    required this.timerType,
    this.onTimerComplete,
    required this.onTap,
    required this.onLongPress,
  });

  int? _secondsFromType() {
    switch (timerType) {
      case PlayerTimerType.seconds60: return 60;
      case PlayerTimerType.seconds30: return 30;
      case PlayerTimerType.seconds20: return 20;
      case PlayerTimerType.seconds10: return 10;
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<PlayerModel>.from(players)
      ..sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
    
    final leftColumn = sortedPlayers.where((p) => p.seatNumber <= 5).toList().reversed.toList();
    final rightColumn = sortedPlayers.where((p) => p.seatNumber >= 6).toList();

    final timerSeconds = _secondsFromType();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: leftColumn.map((player) {
              final isSpeaking = currentSpeaker == player.seatNumber;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isSpeaking: isSpeaking,
                    isLeftColumn: true,
                    timerSeconds: isSpeaking ? timerSeconds : null,
                    onTimerComplete: onTimerComplete,
                    onTap: () => onTap(player.seatNumber),
                    onLongPress: () => onLongPress(player.seatNumber),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rightColumn.map((player) {
              final isSpeaking = currentSpeaker == player.seatNumber;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PlayerCard(
                    player: player,
                    isSpeaking: isSpeaking,
                    isLeftColumn: false,
                    timerSeconds: isSpeaking ? timerSeconds : null,
                    onTimerComplete: onTimerComplete,
                    onTap: () => onTap(player.seatNumber),
                    onLongPress: () => onLongPress(player.seatNumber),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}