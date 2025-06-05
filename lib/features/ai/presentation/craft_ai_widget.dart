import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../domain/craft_hint_service.dart';

class CraftAIWidget extends StatelessWidget {
  final String craft;

  const CraftAIWidget({super.key, required this.craft});

  @override
  Widget build(BuildContext context) {
    final CraftHintService service = CraftHintService();
    final tips = service.getTips(craft);
    final mistakes = service.getMistakes(craft);
    final materials = service.getMaterials(craft);

    return Scaffold(
      appBar: AppBar(title: Text('$craft Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Tips', style: TextStyle(fontWeight: FontWeight.bold)),
            ...tips.map((e) => ListTile(title: Text(e))),
            const Divider(),
            const Text('Common Mistakes', style: TextStyle(fontWeight: FontWeight.bold)),
            ...mistakes.map((e) => ListTile(title: Text(e))),
            const Divider(),
            const Text('Recommended Materials', style: TextStyle(fontWeight: FontWeight.bold)),
            ...materials.map((e) => ListTile(title: Text(e))),
          ],
        ),
      ),
    );
  }
}