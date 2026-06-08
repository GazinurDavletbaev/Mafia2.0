import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // ЗДЕСЬ ТВОЯ ССЫЛКА
  static const String versionUrl =
      'https://gist.githubusercontent.com/GazinurDavletbaev/67600af954b987d167ab2bf78cd88ab4/raw/5823914494a967917eb448fb5a2936ca77692f0a/mafia_help_version.json';

  static const String apkUrl =
      'https://github.com/GazinurDavletbaev/Mafia2.0/releases/latest/download/app-release.apk';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(Uri.parse(versionUrl));
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final latestVersion = data['latest_version'];
      print('Current version: $currentVersion, Latest: $latestVersion');

      if (currentVersion != latestVersion) {
        _showUpdateDialog(context);
      }
    } catch (e) {
      print('Update check failed: $e');
    }
  }

  static void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Доступно обновление!',
            style: TextStyle(color: Colors.white)),
        content: const Text('Новая версия готова к установке.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await launchUrl(Uri.parse(apkUrl),
                  mode: LaunchMode.externalApplication);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade800),
            child: const Text('Обновить'),
          ),
        ],
      ),
    );
  }
}
