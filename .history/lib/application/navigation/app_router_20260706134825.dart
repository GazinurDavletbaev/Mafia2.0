import 'package:go_router/go_router.dart';
import 'package:mafia_help/domain/rules/game_history.dart';
import 'package:mafia_help/presentation/screens/lobby_screen.dart';
import 'package:mafia_help/presentation/screens/login_screen.dart';
import 'package:mafia_help/presentation/screens/phone_verify_screen.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
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
  initialLocation: '/', // ← SplashScreen
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/lobby',
      name: 'lobby',
      builder: (context, state) => const LobbyScreen(),
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
      path: '/phone-verify',
      name: 'phone-verify',
      builder: (context, state) => const PhoneVerifyScreen(),
    ),
    GoRoute(
      path: '/new-game',
      name: 'new-game',
      builder: (context, state) => const NewGameScreen(),
    ),
    GoRoute(
      path: '/protocol',
      name: 'protocol',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return GameProtocolScreen(
          gameHistory: args?['gameHistory'] ?? GameHistory(),
          gameState: args?['gameState'] ?? GameState.initial(),
        );
      },
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
