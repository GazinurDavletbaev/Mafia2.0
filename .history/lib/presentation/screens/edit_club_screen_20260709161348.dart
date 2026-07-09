// lib/presentation/screens/edit_club_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/club_service.dart';
import '../../services/auth_service.dart';

class EditClubScreen extends ConsumerStatefulWidget {
  final int clubId;

  const EditClubScreen({super.key, required this.clubId});

  @override
  ConsumerState<EditClubScreen> createState() => _EditClubScreenState();
}

class _EditClubScreenState extends ConsumerState<EditClubScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();

  String? _selectedCountry;
  String? _selectedRegion;
  File? _clubImage;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _currentLogoUrl;
  Map<String, dynamic>? _clubData;

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
    _loadClub();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _loadClub() async {
    setState(() => _isLoading = true);

    final token = await AuthService.getToken();
    if (token != null) {
      final result = await ClubService.getClub(widget.clubId);
      print('📦 Загрузка клуба: $result');
      if (result['success']) {
        final club = result['club'];
        _clubData = club;
        _titleController.text = club['title'] ?? '';
        _descriptionController.text = club['description'] ?? '';
        _cityController.text = club['city'] ?? '';
        _currentLogoUrl = club['logo_url'];

        if (club['country'] != null && _countries.contains(club['country'])) {
          _selectedCountry = club['country'];
        }
        if (club['region'] != null && _selectedCountry != null) {
          final regions = _regions[_selectedCountry!] ?? [];
          if (regions.contains(club['region'])) {
            _selectedRegion = club['region'];
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
        _clubImage = File(image.path);
      });
    }
  }

  Future<void> _saveClub() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final city = _cityController.text.trim();

    if (title.isEmpty) {
      _showSnackBar('Введите название клуба', Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    // ✅ 1. Загружаем логотип
    String? newLogoUrl;
    if (_clubImage != null) {
      final uploadResult = await ClubService.uploadClubLogo(
        clubId: widget.clubId,
        image: _clubImage!,
      );
      print('📦 uploadResult: $uploadResult');
      if (uploadResult['success']) {
        newLogoUrl = uploadResult['logo_url'];
        setState(() {
          _currentLogoUrl = newLogoUrl;
        });
      } else {
        _showSnackBar('Ошибка загрузки логотипа', Colors.red);
      }
    }

    // ✅ 2. Обновляем клуб
    final result = await ClubService.updateClub(
      clubId: widget.clubId,
      title: title,
      description: description.isNotEmpty ? description : null,
      city: city.isNotEmpty ? city : null,
      country: _selectedCountry,
      region: _selectedRegion,
      logoUrl: newLogoUrl,
    );

    print('📦 updateClub result: $result');

    setState(() => _isSaving = false);

    if (result['success']) {
      _showSnackBar('Клуб обновлён!', Colors.green);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context, true);
          context.go('/profile');
        }
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
        title: const Text('Редактировать клуб'),
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
                  // ===== АВАТАРКА КЛУБА =====
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange, width: 2),
                          image: _clubImage != null
                              ? DecorationImage(
                                  image: FileImage(_clubImage!),
                                  fit: BoxFit.cover,
                                )
                              : (_currentLogoUrl != null && _currentLogoUrl!.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(_currentLogoUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                        ),
                        child: (_clubImage == null && (_currentLogoUrl == null || _currentLogoUrl!.isEmpty))
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
                      _clubImage == null && (_currentLogoUrl == null || _currentLogoUrl!.isEmpty)
                          ? 'Нажмите для загрузки фото'
                          : 'Нажмите чтобы сменить фото',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== ОБЩАЯ ИНФОРМАЦИЯ =====
                  const Text(
                    'Общая информация',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Название
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Название клуба',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.emoji_events, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Описание
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    maxLength: 240,
                    style: TextStyle(
                      color: theme.textTheme.bodyLarge?.color ?? Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Описание клуба (240 символов)',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.description, color: Colors.orange),
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
                            onPressed: _saveClub,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.black,
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}