// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/club_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _currentClub;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final token = await AuthService.getToken();
    if (token != null) {
      // ✅ Получаем профиль
      final userResult = await AuthService.getMe(token);
      if (userResult['success']) {
        final user = userResult['user'];
        _user = {
          'username': user.username,
          'email': user.email,
          'id': user.id,
        };
      }

      // ✅ Загружаем текущий клуб
      final clubResult = await ClubService.getMyClubs();
      if (clubResult['success'] && clubResult['clubs'] != null) {
        final clubs = (clubResult['clubs'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (clubs.isNotEmpty) {
          _currentClub = clubs[0];
        }
      }
    }

    setState(() => _isLoading = false);
  }

  // ... остальной код такой же
}