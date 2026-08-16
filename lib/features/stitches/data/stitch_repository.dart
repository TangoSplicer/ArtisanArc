import 'package:hive/hive.dart';
import 'stitch_model.dart';

class StitchRepository {
  static const String _boxName = 'stitchLibraryBox';

  Future<Box<StitchReference>> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<StitchReference>(_boxName);
    }
    return Hive.box<StitchReference>(_boxName);
  }

  Future<List<StitchReference>> getStitches() async {
    final box = await _openBox();
    if (box.isEmpty) {
      await _seedDefaultStitches(box);
    }
    return box.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> saveStitch(StitchReference stitch) async {
    final box = await _openBox();
    await box.put(stitch.id, stitch);
  }

  Future<void> _seedDefaultStitches(Box<StitchReference> box) async {
    final defaults = [
      StitchReference(
        id: 'stitch-sc',
        name: 'Single Crochet',
        abbreviation: 'sc',
        craftType: 'Crochet',
        difficulty: 'Beginner',
        instructions:
            'Insert hook into stitch, yarn over, pull up a loop (2 loops on hook), yarn over, pull through both loops.',
        tips: 'The foundational stitch for amigurumi and dense textures.',
      ),
      StitchReference(
        id: 'stitch-hdc',
        name: 'Half Double Crochet',
        abbreviation: 'hdc',
        craftType: 'Crochet',
        difficulty: 'Beginner',
        instructions:
            'Yarn over, insert hook into stitch, yarn over, pull up a loop (3 loops on hook), yarn over, pull through all 3 loops.',
        tips: 'Taller than single crochet but tighter than double crochet.',
      ),
      StitchReference(
        id: 'stitch-dc',
        name: 'Double Crochet',
        abbreviation: 'dc',
        craftType: 'Crochet',
        difficulty: 'Beginner',
        instructions:
            'Yarn over, insert hook into stitch, yarn over, pull up a loop (3 loops), yarn over, pull through 2 loops (2 loops), yarn over, pull through remaining 2 loops.',
        tips: 'Great for blankets, cardigans, and granny squares.',
      ),
      StitchReference(
        id: 'stitch-tr',
        name: 'Treble Crochet',
        abbreviation: 'tr',
        craftType: 'Crochet',
        difficulty: 'Intermediate',
        instructions:
            'Yarn over twice, insert hook into stitch, yarn over, pull up a loop (4 loops), [yarn over, pull through 2 loops] 3 times.',
        tips: 'Adds height and lacy drape to crochet projects.',
      ),
      StitchReference(
        id: 'stitch-bobble',
        name: 'Bobble Stitch',
        abbreviation: 'bobble',
        craftType: 'Crochet',
        difficulty: 'Intermediate',
        instructions:
            'Work 5-dc cluster in the same stitch: [yarn over, insert hook, yarn over, pull up loop, yarn over, pull through 2 loops] 4 times in same stitch, yarn over and pull through all 5 loops on hook.',
        tips: 'Creates lovely 3D texture for pillows and toys.',
      ),
    ];
    for (final stitch in defaults) {
      await box.put(stitch.id, stitch);
    }
  }
}
