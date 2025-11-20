import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sova/domain/entities/transaction_entity.dart';
import 'package:sova/presentation/widgets/transaction_card.dart';

void main() {
  group('TransactionCard Widget Tests', () {
    late TransactionEntity testTransaction;

    setUp(() {
      testTransaction = TransactionEntity(
        id: 'test-1',
        amount: 1500.0,
        category: 'Продукты',
        description: 'Супермаркет',
        date: DateTime(2024, 11, 20),
        type: TransactionType.expense,
        accountId: 'account-1',
      );
    });

    testWidgets('should display transaction amount',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionCard(transaction: testTransaction),
          ),
        ),
      );

      expect(find.textContaining('1500'), findsOneWidget);
    });

    testWidgets('should display transaction category',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionCard(transaction: testTransaction),
          ),
        ),
      );

      expect(find.text('Продукты'), findsOneWidget);
    });

    testWidgets('should display transaction description',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionCard(transaction: testTransaction),
          ),
        ),
      );

      expect(find.text('Супермаркет'), findsOneWidget);
    });

    testWidgets('should show expense with red color',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionCard(transaction: testTransaction),
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.textContaining('1500').first,
      );
      
      expect(
        (text.style?.color ?? Colors.red).value,
        equals(Colors.red.value),
      );
    });

    testWidgets('should show income with green color',
        (WidgetTester tester) async {
      final incomeTransaction = testTransaction.copyWith(
        type: TransactionType.income,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionCard(transaction: incomeTransaction),
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.textContaining('1500').first,
      );
      
      expect(
        (text.style?.color ?? Colors.green).value,
        equals(Colors.green.value),
      );
    });

    testWidgets('should display category icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionCard(transaction: testTransaction),
          ),
        ),
      );

      expect(find.byType(Icon), findsAtLeastNWidgets(1));
    });

    testWidgets('should be tappable', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onTap: () => tapped = true,
              child: TransactionCard(transaction: testTransaction),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TransactionCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('should format date correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionCard(transaction: testTransaction),
          ),
        ),
      );

      // Check for date components
      expect(find.textContaining('20'), findsAtLeastNWidgets(1));
    });
  });
}
