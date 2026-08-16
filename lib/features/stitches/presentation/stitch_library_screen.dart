import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/widgets/personal_app_bar.dart';
import '../data/stitch_model.dart';
import '../data/stitch_repository.dart';

class StitchLibraryScreen extends StatefulWidget {
  const StitchLibraryScreen({super.key});

  @override
  State<StitchLibraryScreen> createState() => _StitchLibraryScreenState();
}

class _StitchLibraryScreenState extends State<StitchLibraryScreen> {
  final StitchRepository _repository = GetIt.I<StitchRepository>();
  List<StitchReference> _stitches = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadStitches();
  }

  Future<void> _loadStitches() async {
    final stitches = await _repository.getStitches();
    if (!mounted) return;
    setState(() {
      _stitches = stitches;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = _stitches
        .where((s) =>
            s.name.toLowerCase().contains(_query.toLowerCase()) ||
            s.abbreviation.toLowerCase().contains(_query.toLowerCase()) ||
            s.instructions.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: PersonalAppBar(
        title: const Text('Crochet Stitch Library'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText:
                          'Search stitches or abbreviations (e.g. sc, dc)',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => setState(() => _query = val),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No matching stitches found'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final stitch = filtered[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: colors.secondaryContainer,
                                  child: Text(
                                    stitch.abbreviation,
                                    style: TextStyle(
                                      color: colors.onSecondaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                title: Text(stitch.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${stitch.craftType} · ${stitch.difficulty}'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Divider(),
                                        const Text('Instructions:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(stitch.instructions),
                                        if (stitch.tips != null &&
                                            stitch.tips!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Maker Tip: ${stitch.tips}',
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: colors.primary),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
