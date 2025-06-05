class CraftAIProfile {
  final String craft;
  final List<String> tips;
  final List<String> commonMistakes;
  final List<String> recommendedMaterials;

  const CraftAIProfile({
    required this.craft,
    required this.tips,
    required this.commonMistakes,
    required this.recommendedMaterials,
  });
}

final Map<String, CraftAIProfile> offlineCraftProfiles = {
  'Crochet': CraftAIProfile(
    craft: 'Crochet',
    tips: [
      'Use stitch markers for large projects.',
      'Count stitches often to avoid accidental increases or decreases.',
    ],
    commonMistakes: [
      'Skipping foundation chains',
      'Inconsistent tension',
    ],
    recommendedMaterials: [
      'DK weight yarn',
      '4mm or 5mm hook',
    ],
  ),
  'Knitting': CraftAIProfile(
    craft: 'Knitting',
    tips: [
      'Use circular needles for flat projects to distribute weight.',
      'Block finished pieces for better shape.',
    ],
    commonMistakes: [
      'Twisting stitches on the cast-on row',
      'Dropping stitches',
    ],
    recommendedMaterials: [
      'Worsted weight yarn',
      '5mm needles',
    ],
  ),
  // Add more crafts as needed
};