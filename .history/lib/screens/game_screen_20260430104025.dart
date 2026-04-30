import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Text(
          'Game Screen — UI в разработке',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}