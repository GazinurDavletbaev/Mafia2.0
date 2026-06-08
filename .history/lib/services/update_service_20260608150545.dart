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
      if (response.statusCode != 200) return;

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
