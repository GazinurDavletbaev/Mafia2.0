import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/update_service.dart';
import 'game_screen.dart';

class ClubScreen extends ConsumerStatefulWidget {
  const ClubScreen({super.key});

  @override
  ConsumerState<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends ConsumerState<ClubScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Mafia Help'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Кнопка "Начать игру"
            ElevatedButton(
              onPressed: () {
                final gameId = DateTime.now().millisecondsSinceEpoch.toString();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(gameId: gameId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Начать игру',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Кнопка "Рейтинг" (пока без обработки)
            ElevatedButton(
              onPressed: () {
                // TODO: открыть экран рейтинга
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Рейтинг в разработке')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Рейтинг',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => UpdateService.checkForUpdate(context),
              child: const Text('Проверить обновления'),
            ),
            ElevatedButton(
              onPressed: () async {
                final packageInfo = await PackageInfo.fromPlatform();
                print('Local version: ${packageInfo.version}');

                final response =
                    await http.get(Uri.parse(UpdateService.versionUrl));
                print('Response status: ${response.statusCode}');
                print('Response body: ${response.body}');

                UpdateService.checkForUpdate(context);
              },
              child: const Text('Диагностика'),
            ),
          ],
        ),
      ),
    );
  }
}
