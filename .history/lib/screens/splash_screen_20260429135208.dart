import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Логотип (пока заглушка)
            const Icon(Icons.gavel, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Mafia Help',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            // Кнопка перехода
            ElevatedButton(
              onPressed: () {
                context.go('/register');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text('Начать', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
