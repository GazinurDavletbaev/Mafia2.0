import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {
  final String role;
  final VoidCallback onClose;

  const RoleCard({
    super.key,
    required this.role,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: onClose,
        child: Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage('assets/$role.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}