class PremiumChecker {
  static Future<bool> isPremium() async {
    // No-op, premium is always unlocked for personal use
    return true;
  }
}
