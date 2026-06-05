import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class UpdateService {
  // Ссылка на твой Gist (замени на свою)
  static const String versionUrl = 'https://gist.githubusercontent.com/GazinurDavletbaev/67600af954b987d167ab2bf78cd88ab4/raw/3922ebab683b3a7e9be74428b549d7db73c229f9/mafia_help_version.json';
  
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      // Получаем текущую версию приложения
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Скачиваем версию из Gist
      final response = await http.get(Uri.parse(versionUrl));
      if (response.statusCode != 200) return;
      
      final data = jsonDecode(response.body);
      final latestVersion = data['latest_version'];
      final apkUrl = data['apk_url'];
      
      // Сравниваем версии
      if (currentVersion != latestVersion) {
        _showUpdateDialog(context, apkUrl);
      }
    } catch (e) {
      print('Update check failed: $e');
    }
  }
  
  static void _showUpdateDialog(BuildContext context, String apkUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          'Доступно обновление!',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Новая версия приложения готова к установке.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await launchUrl(Uri.parse(apkUrl), mode: LaunchMode.externalApplication);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
            ),
            child: const Text('Обновить'),
          ),
        ],
      ),
    );
  }
}