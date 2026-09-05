// lib/presentation/widgets/club/club_noheader.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/presentation/widgets/app_card.dart';
import 'package:mdi_plus/mdi_plus.dart';

class ClubNoHeader extends StatelessWidget {
  const ClubNoHeader(
      {super.key, Map<String, GlobalKey<State<StatefulWidget>>>? tutorialKeys});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return AppCard(
      isDark: isDark,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Icon(
            Mdi.accountGroup,
            size: 48,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'У вас пока нет клуба',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Создайте свой клуб или вступите в существующий',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                key: tutorialKeys?['club_create'],
                onPressed: () {
                  context.push('/create-club');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Создать'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
