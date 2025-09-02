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
  'Sewing': CraftAIProfile(
    craft: 'Sewing',
    tips: [
      'Always press your seams.',
      'Change your needle every 8-10 hours of sewing.',
      'Test your stitch on a scrap piece of fabric first.',
    ],
    commonMistakes: [
      'Not backstitching at the beginning and end of seams.',
      'Stretching the fabric while sewing.',
      'Using the wrong type of needle for the fabric.',
    ],
    recommendedMaterials: [
      'Cotton fabric',
      'Universal needle',
      'Polyester thread',
    ],
  ),
  'Embroidery': CraftAIProfile(
    craft: 'Embroidery',
    tips: [
      'Use a hoop to keep your fabric taut.',
      'Separate your embroidery floss for a neater look.',
      'Start with simple stitches like the backstitch and satin stitch.',
    ],
    commonMistakes: [
      'Pulling your stitches too tight.',
      'Making large knots on the back of your work.',
      'Using a single strand of floss for all stitches.',
    ],
    recommendedMaterials: [
      'Embroidery floss',
      'Linen or cotton fabric',
      'Embroidery hoop',
    ],
  ),
  'Pottery': CraftAIProfile(
    craft: 'Pottery',
    tips: [
      'Wedge your clay properly to remove air bubbles.',
      'Keep your hands wet while throwing on the wheel.',
      'Compress the rim of your pots to prevent cracking.',
    ],
    commonMistakes: [
      'Using too much water.',
      'Not centering the clay on the wheel.',
      'Making the walls of the pot too thin.',
    ],
    recommendedMaterials: [
      'Stoneware clay',
      'Pottery wheel',
      'Basic pottery tools (needle tool, wire cutter, sponge)',
    ],
  ),
  'Quilting': CraftAIProfile(
    craft: 'Quilting',
    tips: [
      'Use a rotary cutter for precise fabric cutting.',
      'Press seams consistently in one direction.',
      'Pin generously to prevent fabric shifting.',
    ],
    commonMistakes: [
      'Not pre-washing fabrics.',
      'Inconsistent seam allowances.',
      'Skipping the basting step.',
    ],
    recommendedMaterials: [
      'Cotton quilting fabric',
      'Rotary cutter and mat',
      'Quilting ruler',
    ],
  ),
  'Paper Craft': CraftAIProfile(
    craft: 'Paper Craft',
    tips: [
      'Use bone folder for crisp creases.',
      'Score before folding thick paper.',
      'Work in good lighting to avoid eye strain.',
    ],
    commonMistakes: [
      'Using too much adhesive.',
      'Not measuring twice before cutting.',
      'Rushing the drying process.',
    ],
    recommendedMaterials: [
      'Cardstock paper',
      'Craft knife',
      'Cutting mat',
    ],
  ),
  'Macramé': CraftAIProfile(
    craft: 'Macramé',
    tips: [
      'Keep consistent tension throughout.',
      'Use a macramé board for complex patterns.',
      'Comb out cords for a neat finish.',
    ],
    commonMistakes: [
      'Starting with cords too short.',
      'Inconsistent knot spacing.',
      'Not securing the mounting cord properly.',
    ],
    recommendedMaterials: [
      'Macramé cord (3-4mm)',
      'Wooden dowel or ring',
      'Macramé comb',
    ],
  ),
};