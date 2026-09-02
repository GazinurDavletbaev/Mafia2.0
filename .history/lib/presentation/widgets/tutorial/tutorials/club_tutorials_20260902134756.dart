// lib/presentation/widgets/tutorial/tutorials/club_tutorials.dart
import 'package:flutter/material.dart';
import 'base_tutorial.dart';

class ClubTutorials extends TutorialGroup {
  final GlobalKey? residentsKey;
  final GlobalKey? gamesKey;
  final GlobalKey? searchButtonKey;

  ClubTutorials({
    this.residentsKey,
    this.gamesKey,
    this.searchButtonKey,
  });

  @override
  String get screenName => 'club';

  @override
  List<TutorialStep> get steps => [
        TutorialStep(
          id: 'club_residents',
          title: 'Резиденты клуба',
          description: 'Здесь отображаются все участники клуба.',
          icon: Icons.people_alt_rounded,
          targetKey: residentsKey,
          backgroundColor: Colors.deepPurple,
          width: 260,
          height: 100,
        ),
        TutorialStep(
          id: 'club_games',
          title: 'История игр',
          description: 'Все игры клуба собраны здесь.',
          icon: Icons.sports_score_rounded,
          targetKey: gamesKey,
          backgroundColor: Colors.orange.shade700,
          width: 240,
          height: 90,
        ),
        TutorialStep(
          id: 'club_search',
          title: 'Найти клуб',
          description: 'Нажмите сюда, чтобы найти и вступить в клуб.',
          icon: Icons.search_rounded,
          targetKey: searchButtonKey,
          backgroundColor: Colors.blue.shade700,
          width: 220,
          height: 90,
        ),
      ];
}
