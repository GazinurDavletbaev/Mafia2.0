import 'package:go_router/go_router.dart';
import '../../screens/splash_screen.dart';
import '../../screens/register_screen.dart';
import '../../screens/club_select_screen.dart';
import '../../screens/club_page_screen.dart';
import '../../screens/new_game_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
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
      path: '/club-page',
      name: 'club-page',
      builder: (context, state) => const ClubPageScreen(),
    ),
    GoRoute(
      path: '/new-game',
      name: 'new-game',
      builder: (context, state) => const NewGameScreen(),
    ),
  ],
);
