import 'package:flutter/material.dart';

class PremiumPrompt extends StatelessWidget {
  const PremiumPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Premium Feature'),
      content: const Text('This feature is only available to premium users.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
