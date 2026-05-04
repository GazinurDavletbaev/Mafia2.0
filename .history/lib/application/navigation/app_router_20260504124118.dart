import 'package:go_router/go_router.dart';
import '../../presentation/screens/club_page_screen.dart';
import '../../presentation/screens/club_select_screen.dart';
import '../../presentation/screens/game_screen.dart';
import '../../presentation/screens/new_game_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/splash_screen.dart';


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
    GoRoute(
      path: '/game',
      name: 'game',
      builder: (context, state) => const GameScreen(),
    ),
  ],
);