import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for common test utilities
class TestHelpers {
  /// Wraps a widget with necessary providers for testing
  static Widget wrapWithProviders(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: child,
      ),
    );
  }

  /// Creates a mock transaction for testing
  static Map<String, dynamic> createMockTransaction({
    String? id,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? type,
  }) {
    return {
      'id': id ?? 'test-id',
      'amount': amount ?? 1000.0,
      'category': category ?? 'Продукты',
      'description': description ?? 'Test transaction',
      'date': (date ?? DateTime.now()).toIso8601String(),
      'type': type ?? 'expense',
      'accountId': 'test-account',
    };
  }

  /// Creates a mock user for testing
  static Map<String, dynamic> createMockUser({
    String? id,
    String? email,
    String? displayName,
  }) {
    return {
      'id': id ?? 'test-user-id',
      'email': email ?? 'test@example.com',
      'displayName': displayName ?? 'Test User',
      'photoUrl': 'https://example.com/photo.jpg',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Creates a mock bank account for testing
  static Map<String, dynamic> createMockBankAccount({
    String? id,
    String? bankName,
    double? balance,
  }) {
    return {
      'id': id ?? 'test-account-id',
      'bankName': bankName ?? 'Optima Bank',
      'accountNumber': '1234567890',
      'balance': balance ?? 50000.0,
      'currency': 'KGS',
      'isActive': true,
      'isPrimary': true,
    };
  }

  /// Pumps widget and settles
  static Future<void> pumpAndSettle(
    WidgetTester tester,
    Widget widget, {
    Duration duration = const Duration(milliseconds: 100),
  }) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(duration);
  }

  /// Finds a widget by text containing a substring
  static Finder findTextContaining(String text) {
    return find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data != null &&
          widget.data!.contains(text),
    );
  }

  /// Taps a button with specific text
  static Future<void> tapButtonWithText(
    WidgetTester tester,
    String text,
  ) async {
    final button = find.widgetWithText(ElevatedButton, text);
    await tester.tap(button);
    await tester.pump();
  }

  /// Enters text into a TextField
  static Future<void> enterText(
    WidgetTester tester,
    String text, {
    int fieldIndex = 0,
  }) async {
    final textField = find.byType(TextField).at(fieldIndex);
    await tester.enterText(textField, text);
    await tester.pump();
  }

  /// Verifies a snackbar is displayed
  static void expectSnackBar(String message) {
    expect(find.text(message), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  }

  /// Verifies loading indicator is shown
  static void expectLoadingIndicator() {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Scrolls until a widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder item,
    Finder scrollable, {
    double delta = -100,
  }) async {
    await tester.dragUntilVisible(
      item,
      scrollable,
      Offset(0, delta),
    );
  }
}

/// Custom matchers for testing
class CustomMatchers {
  /// Matches a color value
  static Matcher hasColor(Color color) {
    return predicate<Widget>(
      (widget) {
        if (widget is Container) {
          final decoration = widget.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == color;
          }
        }
        return false;
      },
      'has color ${color.toString()}',
    );
  }

  /// Matches a specific font size
  static Matcher hasFontSize(double size) {
    return predicate<Text>(
      (text) => text.style?.fontSize == size,
      'has font size $size',
    );
  }

  /// Matches a specific font weight
  static Matcher hasFontWeight(FontWeight weight) {
    return predicate<Text>(
      (text) => text.style?.fontWeight == weight,
      'has font weight ${weight.toString()}',
    );
  }
}
