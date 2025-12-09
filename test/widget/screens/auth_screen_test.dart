import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/presentation/screens/auth/auth_screen.dart';

void main() {
  group('AuthScreen Widget Tests', () {
    testWidgets('should display app logo', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Verify logo is displayed
      expect(find.byType(Image), findsAtLeastNWidgets(1));
    });

    testWidgets('should display app name', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Verify app name is displayed
      expect(find.text('S.O.V.A'), findsOneWidget);
    });

    testWidgets('should display tagline', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Verify tagline exists
      expect(
        find.textContaining('финансовый'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('should display Google Sign In button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Verify Google Sign In button
      expect(
        find.widgetWithText(ElevatedButton, 'Войти через Google'),
        findsOneWidget,
      );
    });

    testWidgets('should show loading indicator when tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Find and tap the Google Sign In button
      final button = find.widgetWithText(ElevatedButton, 'Войти через Google');
      await tester.tap(button);
      await tester.pump();

      // Verify loading state (implementation dependent)
      // This is a placeholder - adjust based on actual implementation
    });

    testWidgets('should have proper layout structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Verify Scaffold exists
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify main content area
      expect(find.byType(SafeArea), findsAtLeastNWidgets(1));
    });

    testWidgets('should display features list', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );

      // Scroll to find features
      await tester.dragUntilVisible(
        find.textContaining('AI'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );

      // Verify features are displayed
      expect(find.textContaining('AI'), findsAtLeastNWidgets(1));
    });
  });
}
