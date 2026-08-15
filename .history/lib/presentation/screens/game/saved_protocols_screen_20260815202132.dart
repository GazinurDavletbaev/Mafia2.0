// lib/presentation/screens/game/saved_protocols_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mafia_help/core/themes/app_theme.dart';
import 'package:mafia_help/presentation/screens/game/game_protocol_view_screen.dart';
import 'package:mafia_help/services/auth_service.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class SavedProtocolsScreen extends ConsumerStatefulWidget {
  const SavedProtocolsScreen({super.key});

  @override
  ConsumerState<SavedProtocolsScreen> createState() =>
      _SavedProtocolsScreenState();
}

class _SavedProtocolsScreenState extends ConsumerState<SavedProtocolsScreen> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() => _isLoading = true);
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      setState(() {
        _files = files
            .where((f) => f.path.endsWith('.xlsx') || f.path.endsWith('.json'))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFile(FileSystemEntity file) async {
    try {
      await file.delete();
      _loadFiles();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Файл удалён'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Ошибка удаления: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendToServer(FileSystemEntity file) async {
    final fileName = file.path.split('/').last;

    if (!fileName.endsWith('.json')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Только JSON-файлы можно отправить на сервер'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final jsonString = await File(file.path).readAsString();
      final data = jsonDecode(jsonString);

      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Не авторизован'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // 🔥 ПОКАЗЫВАЕМ ЗАГРУЗКУ
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 🔥 ОТПРАВЛЯЕМ НА СЕРВЕР
      final response = await http.post(
        Uri.parse('http://161.104.46.234:8001/games/save?token=$token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ Игра отправлена на сервер! ID: ${responseData['game_id']}'),
            backgroundColor: Colors.green,
          ),
        );
        // 🔥 ОБНОВЛЯЕМ СПИСОК
        _loadFiles();
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${errorData['detail'] ?? 'Ошибка отправки'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getDisplayName(String fileName) {
    final name = fileName.replaceAll('.xlsx', '').replaceAll('.json', '');
    final parts = name.split('_');

    if (parts.length >= 5) {
      final date = parts[0];
      final time = parts[1].replaceAll('-', ':');
      final table = parts[2];
      final game = parts[3];
      return '$date $time Стол $table Игра $game';
    }

    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Сохранённые протоколы'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: _loadFiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _files.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 80,
                        color: isDark ? Colors.grey : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Нет сохранённых протоколов',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Создайте протокол и нажмите "Сохранить"',
                        style: TextStyle(
                          color: isDark ? Colors.white30 : Colors.black38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    final fileName = file.path.split('/').last;
                    final fileSize = file.statSync().size;
                    final modifiedTime = file.statSync().modified;
                    final isJson = fileName.endsWith('.json');

                    return Card(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      margin: const EdgeInsets.only(bottom: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isJson ? Icons.code : Icons.description,
                          color: isJson ? Colors.green : Colors.deepPurple,
                          size: 22,
                        ),
                        title: Text(
                          _getDisplayName(fileName),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${_formatFileSize(fileSize)}  •  ${_formatDate(modifiedTime)}  •  ${isJson ? "JSON" : "Excel"}',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isJson)
      IconButton(
        icon: const Icon(
          Icons.file_download,
          color: Colors.green,
        ),
        onPressed: () => _exportToExcel(file),
        tooltip: 'Экспорт в Excel',
      ),
                            // 🔥 КНОПКА "ОТПРАВИТЬ НА СЕРВЕР" (только для JSON)
                            if (isJson)
                              IconButton(
                                icon: const Icon(
                                  Icons.cloud_upload,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _sendToServer(file),
                                tooltip: 'Отправить на сервер',
                              ),
                            // 🔥 КНОПКА "УДАЛИТЬ"
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _showDeleteDialog(file),
                            ),
                          ],
                        ),
                        onTap: () async {
                          final fileName = file.path.split('/').last;

                          if (fileName.endsWith('.json')) {
                            try {
                              final jsonString =
                                  await File(file.path).readAsString();
                              final data = jsonDecode(jsonString);

                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        GameProtocolViewScreen(
                                      gameData: data,
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ Ошибка чтения файла: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            try {
                              await OpenFile.open(file.path);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('❌ Не удалось открыть файл: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

Future<void> _exportToExcel(FileSystemEntity file) async {
  final fileName = file.path.split('/').last;

  if (!fileName.endsWith('.json')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Только JSON-файлы можно экспортировать в Excel'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    final jsonString = await File(file.path).readAsString();
    final Map<String, dynamic> data = jsonDecode(jsonString);

    // 🔥 ПРОВЕРЯЕМ: ЗАВЕРШЕНА ЛИ ИГРА
    if (data['winner'] == null || data['winner'] == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Игра не завершена! Нет победителя.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // 🔥 ОТПРАВЛЯЕМ НА ГЕНЕРАЦИЮ EXCEL
    final response = await http.post(
      Uri.parse('http://161.104.46.234:8001/protocol/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    Navigator.pop(context);

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 
          '${data['date']}_${data['time'].replaceAll(':', '-')}_${data['table']}_${data['game']}.xlsx';
      final path = '${directory.path}/$fileName';
      final file = File(path);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Excel создан!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 🔥 ОБНОВЛЯЕМ СПИСОК ФАЙЛОВ
      _loadFiles();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Excel не создан: ${response.statusCode}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Ошибка: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _showDeleteDialog(FileSystemEntity file) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        title: Text(
          'Удалить файл?',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        content: Text(
          'Вы уверены, что хотите удалить ${file.path.split('/').last}?',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Отмена',
              style:
                  TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFile(file);
            },
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
