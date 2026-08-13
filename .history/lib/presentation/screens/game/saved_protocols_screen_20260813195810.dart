import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  String _getDisplayName(String fileName) {
    final name = fileName.replaceAll('.xlsx', '');
    final parts = name.split('_');

    if (parts.length >= 5 && parts[0] == 'protocol') {
      final date = parts[1];
      final time = parts[2].replaceAll('-', ':');
      final table = parts[3];
      final game = parts[4];
      return '$date $time Стол $table Игра $game';
    }

    if (parts.length >= 3 && parts[0] == 'protocol') {
      final table = parts[1];
      final game = parts[2];
      return 'Стол $table Игра $game';
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
                  padding: const EdgeInsets.all(16),
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index];
                    final fileName = file.path.split('/').last;
                    final fileSize = file.statSync().size;
                    final modifiedTime = file.statSync().modified;

                    return Card(
                      color: isDark ? Colors.grey.shade800 : Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.description,
                          color: Colors.orange,
                          size: 32,
                        ),
                        title: Text(
                          _getDisplayName(fileName),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${_formatFileSize(fileSize)}  •  ${_formatDate(modifiedTime)}',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _showDeleteDialog(file),
                        ),
                        
                      ),
                    );
                  },
                ),
    );
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
