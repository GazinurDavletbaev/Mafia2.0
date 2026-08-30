// lib/presentation/screens/edit_club_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/club_service.dart';

class EditClubScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> club;

  const EditClubScreen({super.key, required this.club});

  @override
  ConsumerState<EditClubScreen> createState() => _EditClubScreenState();
}

class _EditClubScreenState extends ConsumerState<EditClubScreen> {
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
  void initState() {
    super.initState();
    print('📦 Club data: ${widget.club}'); // ← ДОБАВИТЬ

    _loadClubData();
  }

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

  void _loadClubData() {
    _titleController.text = widget.club['title'] ?? '';
    _descriptionController.text = widget.club['description'] ?? '';
    _cityController.text = widget.club['city'] ?? '';
    _addressController.text = widget.club['address'] ?? ''; // ← НОВОЕ
    _vkController.text = widget.club['vk'] ?? '';
    _telegramController.text = widget.club['telegram'] ?? '';
    _twitchController.text = widget.club['twitch'] ?? '';
    _instagramController.text = widget.club['instagram'] ?? ''; // ← НОВОЕ
    _youtubeController.text = widget.club['youtube'] ?? ''; // ← НОВОЕ
    _websiteController.text = widget.club['website'] ?? ''; // ← НОВОЕ
    _selectedCountry = widget.club['country'];
    _selectedRegion = widget.club['region'];
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

  Future<void> _saveClub() async {
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

    String? newLogoUrl;

    if (_clubImage != null) {
      final uploadResult = await ClubService.uploadClubLogo(
        clubId: widget.club['id'],
        image: _clubImage!,
      );
      print('📦 uploadResult: $uploadResult');
      if (uploadResult['success']) {
        newLogoUrl = uploadResult['logo_url'];
        print('📦 newLogoUrl: $newLogoUrl');
      }
    }

    final result = await ClubService.updateClub(
      clubId: widget.club['id'],
      title: title,
      description: description,
      city: city,
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
      logoUrl: newLogoUrl,
    );

    print('📦 updateClub result: $result');

    setState(() => _isLoading = false);

    if (result['success']) {
      _showSnackBar('Клуб обновлён!', Colors.green);
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

  void _showDeleteClubDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(
              '⚠️ Удалить клуб?',
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Вы собираетесь удалить клуб "${widget.club['title']}".',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Text(
                'Все данные клуба будут безвозвратно удалены:\n'
                '• Все игры\n'
                '• Статистика игроков\n'
                '• Участники клуба\n'
                '• Рейтинг',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteClub();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Да, удалить'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClub() async {
    setState(() => _isLoading = true);

    final result = await ClubService.dissolveClub(widget.club['id']);

    setState(() => _isLoading = false);

    if (result['success']) {
      _showSnackBar('Клуб удалён', Colors.green);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.go('/lobby');
        }
      });
    } else {
      _showSnackBar(result['error'] ?? 'Ошибка удаления', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Редактировать клуб'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/lobby'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          border: Border.all(color: primaryColor, width: 2),
                          image: _clubImage != null
                              ? DecorationImage(
                                  image: FileImage(_clubImage!),
                                  fit: BoxFit.cover,
                                )
                              : (widget.club['logo_url'] != null &&
                                      widget.club['logo_url'].isNotEmpty
                                  ? DecorationImage(
                                      image:
                                          NetworkImage(widget.club['logo_url']),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                        child: _clubImage == null &&
                                (widget.club['logo_url'] == null ||
                                    widget.club['logo_url'].isEmpty)
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
                      'Нажмите чтобы сменить фото',
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

                  // КНОПКА СОХРАНЕНИЯ
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveClub,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Сохранить изменения',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // КНОПКА УДАЛЕНИЯ
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showDeleteClubDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text(
                        'Удалить клуб',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
    );
  }
}
