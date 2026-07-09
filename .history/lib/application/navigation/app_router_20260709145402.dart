import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_help/domain/rules/game_history.dart';
import 'package:mafia_help/presentation/screens/change_password_screen.dart';
import 'package:mafia_help/presentation/screens/club_detail_screen.dart';
import 'package:mafia_help/presentation/screens/club_members_list_screen.dart';
import 'package:mafia_help/presentation/screens/edit_club_screen.dart';
import 'package:mafia_help/presentation/screens/edit_profile_screen.dart';
import 'package:mafia_help/presentation/screens/forgot_password_screen.dart';
import 'package:mafia_help/presentation/screens/lobby_screen.dart';
import 'package:mafia_help/presentation/screens/login_screen.dart';
import 'package:mafia_help/presentation/screens/phone_verify_screen.dart';
import 'package:mafia_help/presentation/screens/reset_code_screen.dart';
import 'package:mafia_help/presentation/screens/reset_password_screen.dart';
import 'package:mafia_help/presentation/state/game_state.dart';
import 'package:mafia_help/services/auth_service.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/club_select_screen.dart';
import '../../presentation/screens/club_screen.dart';
import '../../presentation/screens/game_protocol_screen.dart';
import '../../presentation/screens/saved_protocols_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/create_club_screen.dart';
import '../../presentation/screens/club_requests_screen.dart';
import '../../presentation/screens/club_members_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    if (state.uri.path == '/') {
      return Future<String?>(() async {
        final token = await AuthService.getToken();
        if (token != null && token.isNotEmpty) {
          return '/lobby';
        }
        return null;
      });
    }
    return null;
  },
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
      path: '/club-detail',
      name: 'club-detail',
      builder: (context, state) {
        final clubId = state.extra as int? ?? 0;
        return ClubDetailScreen(clubId: clubId);
      },
    ),
    GoRoute(
      path: '/edit-profie',
      name: 'edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/edit-club',
      name: 'edit-club',
      builder: (context, state) {
        final club = state.extra as Map<String, dynamic>? ?? {};
        return EditClubScreen(club: club);
      },
    ),
    GoRoute(
      path: '/club-members-list',
      name: 'club-members-list',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return ClubMembersListScreen(
          clubId: args?['clubId'] ?? 0,
          clubTitle: args?['clubTitle'] ?? 'Клуб',
        );
      },
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
      path: '/change-password',
      name: 'change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-code',
      name: 'reset-code',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return ResetCodeScreen(email: email);
      },
    ),
    GoRoute(
      path: '/reset-password',
      name: 'reset-password',
      builder: (context, state) {
        // ✅ Токен из extra (передаётся из ResetCodeScreen)
        final token = state.extra as String? ?? '';
        return ResetPasswordScreen(token: token);
      },
    ),
    // ========== ПРОФИЛЬ И КЛУБЫ ==========
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/create-club',
      name: 'create-club',
      builder: (context, state) => const CreateClubScreen(),
    ),
    GoRoute(
      path: '/club-requests',
      name: 'club-requests',
      builder: (context, state) => const ClubRequestsScreen(),
    ),
    GoRoute(
      path: '/club-members',
      name: 'club-members',
      builder: (context, state) => const ClubMembersScreen(),
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
