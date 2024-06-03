import 'package:flutter/material.dart';

class AdditionalInfo extends StatelessWidget {
  // Variables
  final IconData icon;
  final String label;
  final String num;

  // Constructor
  const AdditionalInfo({
    super.key,
    required this.icon,
    required this.label,
    required this.num,
  });

  // Build
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Text(
          num,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
