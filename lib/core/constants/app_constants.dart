class AppConstants {
  static const String appName = 'ArtisanArc';
  static const String appVersion = '1.1.0';
  static const String appDescription = 'Elegant craft supply organiser and personal toolkit';
  static const double defaultVATRate = 0.20;
  static const double ukVATThreshold = 85000.0;
  static const double usVATThreshold = 100000.0;
  static const int freeTierInventoryLimit = 10000;
  static const int premiumInventoryLimit = 10000;
  static const int lowStockThreshold = 5;
  static const int freeTierProjectLimit = 1000;
  static const int premiumProjectLimit = 1000;
  static const String inventoryImagesFolder = 'inventory_images';
  static const String projectImagesFolder = 'project_images';
  static const String backupFolder = 'backups';
  static const int lowStockNotificationId = 1000;
  static const int projectReminderNotificationId = 2000;
  static const int milestoneNotificationId = 3000;
  static const String csvDateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String defaultCurrency = '£';
  static const String currencyCode = 'GBP';
  static const String supportEmail = 'personal@artisanarc.app';
  static const String feedbackEmail = 'personal@artisanarc.app';
  static const String websiteUrl = 'https://artisanarc.app';
  static const List<String> allFeatures = [
    'Unlimited inventory items',
    'Unlimited projects',
    'Advanced analytics',
    'Custom export formats',
    'Bulk operations',
    'Advanced notifications',
    'Offline AI Hints',
  ];
}
