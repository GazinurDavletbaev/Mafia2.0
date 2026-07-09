// lib/presentation/screens/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nicknameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();

  String? _selectedCountry;
  String? _selectedRegion;
  File? _avatarImage;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _currentAvatarUrl;

  final List<String> _countries = [
    'Россия',
    'Беларусь',
    'Казахстан',
    'Украина',
    'Другая',
  ];

  final Map<String, List<String>> _regions = {
    'Россия': [
      'Москва',
      'Санкт-Петербург',
      'Сибирь и Урал',
      'Республика Татарстан',
      'Краснодарский край',
      'Другой',
    ],
    'Беларусь': ['Минск', 'Гомель', 'Другой'],
    'Казахстан': ['Алматы', 'Астана', 'Другой'],
    'Украина': ['Киев', 'Харьков', 'Другой'],
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final token = await AuthService.getToken();
    if (token != null) {
      final result = await AuthService.getMe(token);
      if (result['success']) {
        final user = result['user'];
        _nicknameController.text = user.nickname ?? '';
        _firstNameController.text = user.firstName ?? '';
        _lastNameController.text = user.lastName ?? '';
        _countryController.text = user.country ?? '';
        _cityController.text = user.city ?? '';
        _regionController.text = user.region ?? '';
        _currentAvatarUrl = user.avatarUrl;
        
        if (user.country != null && _countries.contains(user.country)) {
          _selectedCountry = user.country;
        }
        if (user.region != null && _selectedCountry != null) {
          final regions = _regions[_selectedCountry!] ?? [];
          if (regions.contains(user.region)) {
            _selectedRegion = user.region;
          }
        }
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatarImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final nickname = _nicknameController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final city = _cityController.text.trim();

    if (nickname.isEmpty) {
      _showSnackBar('Введите никнейм', Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    // TODO: загрузить фото на сервер
    print('📦 Отправка: ${jsonEncode({...})}'); // ✅ Добавь
  final result = await UserService.updateProfile(...);
  print('📦 Ответ: $result'); // ✅ Добавь
    final result = await UserService.updateProfile(
      nickname: nickname,
      firstName: firstName.isNotEmpty ? firstName : null,
      lastName: lastName.isNotEmpty ? lastName : null,
      country: _selectedCountry,
      city: city.isNotEmpty ? city : null,
      region: _selectedRegion,
    );

    setState(() => _isSaving = false);

    if (result['success']) {
      _showSnackBar('Профиль обновлён!', Colors.green);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) context.go('/profile');
      });
    } else {
      _showSnackBar(result['error'] ?? 'Ошибка', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== АВАТАРКА =====
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.orange,
                            width: 2,
                          ),
                          image: _avatarImage != null
                              ? DecorationImage(
                                  image: FileImage(_avatarImage!),
                                  fit: BoxFit.cover,
                                )
                              : (_currentAvatarUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(_currentAvatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                        child: (_avatarImage == null && _currentAvatarUrl == null)
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Загрузить\nфото',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _avatarImage == null && _currentAvatarUrl == null
                          ? 'Нажмите для загрузки фото'
                          : 'Нажмите чтобы сменить фото',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== ОСНОВНАЯ ИНФОРМАЦИЯ =====
                  const Text(
                    'Основная информация',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Никнейм
                  TextField(
                    controller: _nicknameController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Никнейм',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Имя
                  TextField(
                    controller: _firstNameController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Имя',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      hintText: 'Введите ваше имя',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Фамилия
                  TextField(
                    controller: _lastNameController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Фамилия',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      hintText: 'Введите вашу фамилию',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Страна
                  DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Страна',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.public, color: Colors.orange),
                    ),
                    items: _countries.map((country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCountry = value;
                        _selectedRegion = null;
                        _regionController.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Город
                  TextField(
                    controller: _cityController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Город',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      hintText: 'Введите ваш город',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.location_city, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Регион
                  DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Регион',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.map, color: Colors.orange),
                    ),
                    items: _selectedCountry != null
                        ? (_regions[_selectedCountry!] ?? ['Другой']).map((region) {
                            return DropdownMenuItem<String>(
                              value: region,
                              child: Text(region),
                            );
                          }).toList()
                        : [],
                    onChanged: (value) {
                      setState(() {
                        _selectedRegion = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // ===== КНОПКА СОХРАНЕНИЯ =====
                  SizedBox(
                    width: double.infinity,
                    child: _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Сохранить',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}