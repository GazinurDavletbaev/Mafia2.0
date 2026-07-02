import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/club_select_screen.dart';
import '../../presentation/screens/club_screen.dart';
import '../../presentation/screens/new_game_screen.dart';
import '../../presentation/screens/game_screen.dart';
import '../../presentation/screens/game_settings_screen.dart';
import '../../presentation/screens/game_protocol_screen.dart';
import '../../presentation/screens/saved_protocols_screen.dart';
import '../../presentation/screens/settings_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',  // ← SplashScreen
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/club-select',
      name: 'club-select',
      builder: (context, state) => const ClubSelectScreen(),
    ),
    GoRoute(
      path: '/club',
      name: 'club',
      builder: (context, state) => const ClubScreen(),
    ),
    GoRoute(
      path: '/new-game',
      name: 'new-game',
      builder: (context, state) => const NewGameScreen(),
    ),
    GoRoute(
      path: '/game-settings',
      name: 'game-settings',
      builder: (context, state) => const GameSettingsScreen(),
    ),
    GoRoute(
  path: '/game',
  name: 'game',
  builder: (context, state) {
    final names = state.extra as List<String>? ?? [];
    return GameScreen(playerNames: names);
  },
),
    GoRoute(
      path: '/protocol',
      name: 'protocol',
      builder: (context, state) => const GameProtocolScreen(),
    ),
    GoRoute(
      path: '/saved-protocols',
      name: 'saved-protocols',
      builder: (context, state) => const SavedProtocolsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);