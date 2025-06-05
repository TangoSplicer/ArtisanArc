import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:artisanarc/features/ai/domain/craft_hint_service.dart';

class CraftAIWidget extends StatelessWidget {
  final String craft;

  const CraftAIWidget({super.key, required this.craft});

  @override
  Widget build(BuildContext context) {
    // Retrieve CraftHintService from GetIt
    final CraftHintService service = GetIt.I<CraftHintService>();
    final tips = service.getTips(craft);
    final mistakes = service.getMistakes(craft);
    final materials = service.getMaterials(craft);

    bool noDataAvailable = tips.isEmpty && mistakes.isEmpty && materials.isEmpty && craft.isNotEmpty;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('$craft AI Assistant'),
        backgroundColor: theme.colorScheme.secondaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: noDataAvailable
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: theme.colorScheme.secondary),
                    const SizedBox(height: 20),
                    Text(
                      'Sorry, no AI hints are currently available for "$craft".',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                     Text(
                      'Our AI is constantly learning. Please check back later or try a different craft term.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              )
            : ListView(
                children: [
                  if (tips.isNotEmpty) ...[
                    Text('💡 Smart Tips', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary)),
                    const SizedBox(height: 8),
                    ...tips.map((e) => Card(margin: const EdgeInsets.symmetric(vertical: 4), child: ListTile(leading: const Icon(Icons.lightbulb_outline), title: Text(e)))),
                    const SizedBox(height: 16),
                  ],
                  if (mistakes.isNotEmpty) ...[
                    Text('⚠️ Common Pitfalls', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.error)),
                    const SizedBox(height: 8),
                    ...mistakes.map((e) => Card(margin: const EdgeInsets.symmetric(vertical: 4), child: ListTile(leading: const Icon(Icons.warning_amber_outlined), title: Text(e)))),
                    const SizedBox(height: 16),
                  ],
                  if (materials.isNotEmpty) ...[
                    Text('🛠️ Suggested Materials', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.tertiary)),
                    const SizedBox(height: 8),
                    ...materials.map((e) => Card(margin: const EdgeInsets.symmetric(vertical: 4), child: ListTile(leading: const Icon(Icons.construction_outlined), title: Text(e)))),
                  ],
                ],
              ),
      ),
    );
  }
}