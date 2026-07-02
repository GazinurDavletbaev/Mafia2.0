import 'package:go_router/go_router.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/login_screen.dart';  // ← добавить
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/club_select_screen.dart';
import '../../presentation/screens/club_screen.dart';
import '../../presentation/screens/new_game_screen.dart';
import '../../presentation/screens/game_screen.dart';
import '../../presentation/screens/game_settings_screen.dart';
import '../../presentation/screens/game_protocol_screen.dart';
import '../../presentation/screens/saved_protocols_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../domain/rules/game_history.dart';
import '../../presentation/state/game_state.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
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
    // ... остальные маршруты
  ],
);