class AppConstants {
  // App Information
  static const String appName = 'ArtisanArc';
  static const String appVersion = '1.1.0';
  static const String appDescription = 'Elegant craft supply organiser and personal toolkit';
  
  // Business Constants
  static const double defaultVATRate = 0.20; // 20% VAT for UK
  static const double ukVATThreshold = 85000.0; // £85,000 VAT registration threshold
  static const double usVATThreshold = 100000.0; // Example US threshold
  
  // Inventory Constants
  static const int freeTierInventoryLimit = 10000; // Effectively unlimited
  static const int premiumInventoryLimit = 10000;
  static const int lowStockThreshold = 5;
  
  // Project Constants
  static const int freeTierProjectLimit = 1000; // Effectively unlimited
  static const int premiumProjectLimit = 1000;
  
  // File Storage
  static const String inventoryImagesFolder = 'inventory_images';
  static const String projectImagesFolder = 'project_images';
  static const String backupFolder = 'backups';
  
  // Notification IDs
  static const int lowStockNotificationId = 1000;
  static const int projectReminderNotificationId = 2000;
  static const int milestoneNotificationId = 3000;
  
  // Export Settings
  static const String csvDateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM dd, yyyy';
  
  // Currency
  static const String defaultCurrency = '£';
  static const String currencyCode = 'GBP';
  
  // Contact Information
  static const String supportEmail = 'personal@artisanarc.app';
  static const String feedbackEmail = 'personal@artisanarc.app';
  static const String websiteUrl = 'https://artisanarc.app';
  
  // App Features (All now available)
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
