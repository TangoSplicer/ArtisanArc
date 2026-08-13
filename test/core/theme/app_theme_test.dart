import 'package:artisanarc/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrastRatio(Color first, Color second) {
  final lighter = first.computeLuminance() >= second.computeLuminance() ? first : second;
  final darker = identical(lighter, first) ? second : first;
  return (lighter.computeLuminance() + 0.05) / (darker.computeLuminance() + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppTheme dark mode', () {
    test('uses readable body and heading text on dark surfaces', () {
      final theme = AppTheme.darkTheme;
      final bodyText = theme.textTheme.bodyMedium!.color!;
      final headingText = theme.textTheme.headlineMedium!.color!;

      expect(_contrastRatio(bodyText, theme.scaffoldBackgroundColor), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(headingText, theme.colorScheme.surface), greaterThanOrEqualTo(4.5));
    });

    test('keeps fields, cards, and navigation labels readable', () {
      final theme = AppTheme.darkTheme;
      final fieldFill = theme.inputDecorationTheme.fillColor!;
      final labelColor = theme.inputDecorationTheme.labelStyle!.color!;
      final appBarText = theme.appBarTheme.foregroundColor!;
      final cardColor = theme.cardTheme.color!;

      expect(_contrastRatio(labelColor, fieldFill), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(theme.colorScheme.onSurface, cardColor), greaterThanOrEqualTo(4.5));
      expect(_contrastRatio(appBarText, theme.appBarTheme.backgroundColor!), greaterThanOrEqualTo(4.5));
    });
  });
}
