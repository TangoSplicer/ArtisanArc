class PremiumChecker {
  static Future<void> unlockPremium() async {
    // No-op, premium is always unlocked
  }

  static Future<bool> isPremiumUnlocked() async {
    // All features are now available for personal use
    return true;
  }
}
