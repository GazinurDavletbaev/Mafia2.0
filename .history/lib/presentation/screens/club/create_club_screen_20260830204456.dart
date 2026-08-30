// lib/presentation/screens/create_club_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mafia_help/application/providers/club_provider.dart';
import 'package:mafia_help/application/providers/user_provider.dart';
import 'dart:io';
import '../../../services/club_service.dart';

class CreateClubScreen extends ConsumerStatefulWidget {
  const CreateClubScreen({super.key});

  @override
  ConsumerState<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends ConsumerState<CreateClubScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController(); // ← НОВОЕ
  final _vkController = TextEditingController();
  final _telegramController = TextEditingController();
  final _twitchController = TextEditingController();
  final _instagramController = TextEditingController(); // ← НОВОЕ
  final _youtubeController = TextEditingController(); // ← НОВОЕ
  final _websiteController = TextEditingController(); // ← НОВОЕ

  String? _selectedCountry;
  String? _selectedRegion;
  File? _clubImage;
  bool _isLoading = false;

  final List<String> _countries = [
    'Россия',
    'Беларусь',
    'Казахстан',
    'Украина',
    'Другая',
  ];

  // 🔥 НОВЫЕ РЕГИОНЫ
  final List<String> _regions = [
    'Центральный',
    'Черноземье',
    'Северо-Западный',
    'Южный',
    'Сибирь и Урал',
    'Поволжье',
    'Дальний Восток',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _vkController.dispose();
    _telegramController.dispose();
    _twitchController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _clubImage = File(image.path);
      });
    }
  }

  Future<void> _createClub() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final city = _cityController.text.trim();
    final address = _addressController.text.trim();

    if (title.isEmpty) {
      _showSnackBar('Введите название клуба', Colors.red);
      return;
    }
    if (description.isEmpty) {
      _showSnackBar('Введите описание клуба', Colors.red);
      return;
    }
    if (_selectedCountry == null) {
      _showSnackBar('Выберите страну', Colors.red);
      return;
    }
    if (_selectedRegion == null) {
      _showSnackBar('Выберите регион', Colors.red);
      return;
    }
    if (city.isEmpty) {
      _showSnackBar('Введите город', Colors.red);
      return;
    }
    if (address.isEmpty) {
      _showSnackBar('Введите адрес', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    final result = await ClubService.createClub(
      title: title,
      city: city,
      description: description,
      country: _selectedCountry,
      region: _selectedRegion,
      address: address,
      vk: _vkController.text.trim().isNotEmpty
          ? _vkController.text.trim()
          : null,
      telegram: _telegramController.text.trim().isNotEmpty
          ? _telegramController.text.trim()
          : null,
      twitch: _twitchController.text.trim().isNotEmpty
          ? _twitchController.text.trim()
          : null,
      instagram: _instagramController.text.trim().isNotEmpty
          ? _instagramController.text.trim()
          : null,
      youtube: _youtubeController.text.trim().isNotEmpty
          ? _youtubeController.text.trim()
          : null,
      website: _websiteController.text.trim().isNotEmpty
          ? _websiteController.text.trim()
          : null,
    );

    if (result['success']) {
      final clubId = result['id'];
      ref.invalidate(clubProvider);
      ref.invalidate(userProvider);
      if (_clubImage != null) {
        final uploadResult = await ClubService.uploadClubLogo(
          clubId: clubId,
          image: _clubImage!,
        );
        if (uploadResult['success']) {
          print('📦 Логотип загружен: ${uploadResult['logo_url']}');
        } else {
          print('❌ Ошибка загрузки логотипа: ${uploadResult['error']}');
        }
      }

      _showSnackBar('Клуб успешно создан!', Colors.green);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          ref.invalidate(clubProvider);
          context.go('/lobby');
        }
      });
    } else {
      _showSnackBar(result['error'] ?? 'Ошибка создания клуба', Colors.red);
    }

    setState(() => _isLoading = false);
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
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Создание клуба'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Создайте свой собственный клуб и приглашайте туда активных участников',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 📷 ФОТО
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor,
                            width: 2,
                          ),
                          image: _clubImage != null
                              ? DecorationImage(
                                  image: FileImage(_clubImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _clubImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Загрузить\nфото',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
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
                      _clubImage == null
                          ? 'Нажмите для загрузки фото'
                          : 'Нажмите чтобы сменить фото',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Общая информация',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 📛 НАЗВАНИЕ
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Название клуба *',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.emoji_events, color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 📝 ОПИСАНИЕ
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    maxLength: 240,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Описание клуба (240 символов) *',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      hintText: 'Расскажите о вашем клубе...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.description, color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🌍 СТРАНА
                  DropdownButtonFormField<String>(
                    value: _selectedCountry,
                    dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Страна *',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.public, color: primaryColor),
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
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🗺️ РЕГИОН (НОВЫЙ СПИСОК)
                  DropdownButtonFormField<String>(
                    value: _selectedRegion,
                    dropdownColor: isDark ? Colors.grey.shade800 : Colors.white,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Регион *',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.map, color: primaryColor),
                    ),
                    items: _regions.map((region) {
                      return DropdownMenuItem<String>(
                        value: region,
                        child: Text(region),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRegion = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🏙️ ГОРОД
                  TextField(
                    controller: _cityController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Город *',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      hintText: 'Введите город',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon:
                          Icon(Icons.location_city, color: primaryColor),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 📍 АДРЕС (НОВОЕ)
                  TextField(
                    controller: _addressController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Адрес *',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      hintText: 'Улица, дом, офис',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon:
                          const Icon(Icons.location_on, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Divider(color: Colors.grey),
                  const SizedBox(height: 8),

                  const Text(
                    'Ссылки',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔗 VK
                  TextField(
                    controller: _vkController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'VK',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      hintText: 'https://vk.com/...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.link, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔗 Telegram
                  TextField(
                    controller: _telegramController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Telegram',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      hintText: 'https://t.me/...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.link, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔗 Twitch
                  TextField(
                    controller: _twitchController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Twitch',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      hintText: 'https://twitch.tv/...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.link, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔗 Instagram (НОВОЕ)
                  TextField(
                    controller: _instagramController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Instagram',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      hintText: 'https://instagram.com/...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.link, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔗 YouTube (НОВОЕ)
                  TextField(
                    controller: _youtubeController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'YouTube',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      hintText: 'https://youtube.com/...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.link, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔗 Website (НОВОЕ)
                  TextField(
                    controller: _websiteController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Website',
                      labelStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      hintText: 'https://...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.link, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // КНОПКА СОЗДАНИЯ
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _createClub,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Создать клуб',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/settings'),
                    child: const Text(
                      '← Вернуться в профиль',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
