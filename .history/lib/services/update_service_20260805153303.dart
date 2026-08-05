import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const String repoOwner = 'GazinurDavletbaev';
  static const String repoName = 'Mafia2.0';
  static const String githubApiUrl =
      'https://api.github.com/repos/$repoOwner/$repoName/releases/latest';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(Uri.parse(githubApiUrl));
      if (response.statusCode != 200) {
        _showSnackBar(context, '❌ Не удалось проверить обновления', Colors.red);
        return;
      }

      final data = jsonDecode(response.body);
      final latestTag = data['tag_name'] as String;
      final latestVersion = latestTag.replaceFirst(RegExp(r'^v'), '');

      final assets = data['assets'] as List;
      final apkAsset = assets.firstWhere(
        (asset) => (asset as Map)['name'].toString().endsWith('.apk'),
        orElse: () => null,
      );
      final apkUrl =
          apkAsset != null ? apkAsset['browser_download_url'] as String : null;

      print('Current version: $currentVersion, Latest: $latestVersion');

      if (currentVersion != latestVersion && apkUrl != null) {
        _showUpdateDialog(context, apkUrl, latestVersion);
      } else {
        _showSnackBar(
            context, '✅ У вас последняя версия $currentVersion', Colors.green);
      }
    } catch (e) {
      print('Update check failed: $e');
      _showSnackBar(context, '❌ Ошибка: $e', Colors.red);
    }
  }

  static void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void _showUpdateDialog(
      BuildContext context, String apkUrl, String latestVersion) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        title: Text(
          'Доступно обновление!',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Новая версия $latestVersion готова к установке.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Позже',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await launchUrl(Uri.parse(apkUrl),
                  mode: LaunchMode.externalApplication);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Обновить'),
          ),
        ],
      ),
    );
  }
}