 import '../data/ai_config_model.dart';

class CraftHintService {
  CraftAIProfile? getProfileFor(String craft) {
    return offlineCraftProfiles[craft];
  }

  List<String> getTips(String craft) {
    return getProfileFor(craft)?.tips ?? [];
  }

  List<String> getMistakes(String craft) {
    return getProfileFor(craft)?.commonMistakes ?? [];
  }

  List<String> getMaterials(String craft) {
    return getProfileFor(craft)?.recommendedMaterials ?? [];
  }
}