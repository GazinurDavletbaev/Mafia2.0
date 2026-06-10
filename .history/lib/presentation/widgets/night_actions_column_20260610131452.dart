import 'package:flutter/material.dart';
import '../../data/local/models/sub_phase.dart';

class NightActionsColumn extends StatelessWidget {
  final SubPhase? currentSubPhase;
  final int currentDay;
  final List<int> nightActions;

  const NightActionsColumn({
    super.key,
    required this.currentSubPhase,
    required this.currentDay,
    required this.nightActions,
  });

  int? _getValue(int index) {
    if (nightActions.isEmpty) return null;
    final startIndex = nightActions.length - 3;
    if (startIndex + index >= 0 && startIndex + index < nightActions.length) {
      return nightActions[startIndex + index];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isMafiaActive = currentSubPhase == SubPhase.mafiaShoot;
    final isDonActive = currentSubPhase == SubPhase.donCheck;
    final isSheriffActive = currentSubPhase == SubPhase.sheriffCheck;

    final mafiaValue = _getValue(0);
    final donValue = _getValue(1);
    final sheriffValue = _getValue(2);

    return Container(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildIcon(Icons.sports_mma, isMafiaActive, 'Стрельба мафии'),
          _buildValue(mafiaValue, isMafiaActive, true),
          const SizedBox(height: 12),
          _buildIcon(Icons.emoji_people, isDonActive, 'Проверка дона'),
          _buildValue(donValue, isDonActive),
          const SizedBox(height: 12),
          _buildIcon(Icons.search, isSheriffActive, 'Проверка шерифа'),
          _buildValue(sheriffValue, isSheriffActive),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, bool isActive, String tooltip) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Tooltip(
        message: tooltip,
        child: Icon(
          icon,
          color: isActive ? Colors.orange.shade400 : Colors.grey.shade600,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildValue(int? value, bool isActive, [bool isMiss = false]) {
    if (value == null) return const SizedBox(height: 28);
    return Column(
      children: [
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? Colors.orange.shade800 : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isMiss && (value == 0 || value == -1)
                ? const Icon(Icons.broken_image, color: Colors.white, size: 16)
                : Text('$value',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
