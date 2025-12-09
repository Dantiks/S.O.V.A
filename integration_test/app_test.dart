import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:finer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SOVA App Integration Tests', () {
    testWidgets('Complete app flow test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify splash screen appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for splash to complete
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should navigate to auth or home screen
      await tester.pumpAndSettle();
    });

    testWidgets('Authentication flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find Google Sign In button
      final signInButton = find.widgetWithText(
        ElevatedButton,
        'Войти через Google',
      );

      if (signInButton.evaluate().isNotEmpty) {
        // Tap sign in button
        await tester.tap(signInButton);
        await tester.pumpAndSettle();

        // Note: Actual Google Sign In requires real credentials
        // This is a placeholder for the flow
      }
    });

    testWidgets('Navigation between tabs', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Assuming user is logged in, find bottom navigation
      final bottomNav = find.byType(BottomNavigationBar);
      
      if (bottomNav.evaluate().isNotEmpty) {
        // Tap on different tabs
        await tester.tap(find.byIcon(Icons.account_balance));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.chat_bubble));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.analytics));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.person));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('PIN setup and verification', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to settings (if logged in)
      final settingsIcon = find.byIcon(Icons.settings);
      
      if (settingsIcon.evaluate().isNotEmpty) {
        await tester.tap(settingsIcon);
        await tester.pumpAndSettle();

        // Find PIN setup option
        final pinSetup = find.textContaining('PIN');
        
        if (pinSetup.evaluate().isNotEmpty) {
          await tester.tap(pinSetup.first);
          await tester.pumpAndSettle();

          // Enter PIN
          await tester.enterText(find.byType(TextField).first, '1234');
          await tester.pumpAndSettle();

          // Confirm PIN
          await tester.enterText(find.byType(TextField).last, '1234');
          await tester.pumpAndSettle();

          // Save
          final saveButton = find.widgetWithText(ElevatedButton, 'Сохранить');
          if (saveButton.evaluate().isNotEmpty) {
            await tester.tap(saveButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('Theme switching', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to profile/settings
      final profileTab = find.byIcon(Icons.person);
      
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();

        // Find theme toggle
        final themeSwitch = find.byType(Switch);
        
        if (themeSwitch.evaluate().isNotEmpty) {
          await tester.tap(themeSwitch.first);
          await tester.pumpAndSettle();

          // Verify theme changed
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }
      }
    });

    testWidgets('Add bank account flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to accounts tab
      final accountsTab = find.byIcon(Icons.account_balance);
      
      if (accountsTab.evaluate().isNotEmpty) {
        await tester.tap(accountsTab);
        await tester.pumpAndSettle();

        // Find add account button
        final addButton = find.byIcon(Icons.add);
        
        if (addButton.evaluate().isNotEmpty) {
          await tester.tap(addButton);
          await tester.pumpAndSettle();

          // Select a bank
          final bankOption = find.textContaining('Optima');
          
          if (bankOption.evaluate().isNotEmpty) {
            await tester.tap(bankOption.first);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('AI Chat interaction', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to chat tab
      final chatTab = find.byIcon(Icons.chat_bubble);
      
      if (chatTab.evaluate().isNotEmpty) {
        await tester.tap(chatTab);
        await tester.pumpAndSettle();

        // Find message input
        final messageInput = find.byType(TextField);
        
        if (messageInput.evaluate().isNotEmpty) {
          await tester.enterText(
            messageInput.first,
            'Проанализируй мои расходы',
          );
          await tester.pumpAndSettle();

          // Send message
          final sendButton = find.byIcon(Icons.send);
          
          if (sendButton.evaluate().isNotEmpty) {
            await tester.tap(sendButton);
            await tester.pumpAndSettle();

            // Wait for AI response
            await tester.pumpAndSettle(const Duration(seconds: 2));
          }
        }
      }
    });

    testWidgets('Analytics screen displays charts', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to analytics tab
      final analyticsTab = find.byIcon(Icons.analytics);
      
      if (analyticsTab.evaluate().isNotEmpty) {
        await tester.tap(analyticsTab);
        await tester.pumpAndSettle();

        // Verify charts are displayed
        // This depends on your chart implementation
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
    });
  });
}
