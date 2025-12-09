import 'package:home_widget/home_widget.dart';
import 'package:finer/core/constants/app_constants.dart';

class WidgetService {
  static Future<void> updateBalanceWidget({
    required double balance,
    required String currency,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'balance',
        '${balance.toStringAsFixed(2)} $currency',
      );
      await HomeWidget.updateWidget(
        name: 'BalanceWidget',
        iOSName: 'BalanceWidget',
        androidName: 'BalanceWidgetProvider',
      );
    } catch (e) {
      print('Error updating balance widget: $e');
    }
  }

  static Future<void> updateAdviceWidget({
    required String advice,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('advice', advice);
      await HomeWidget.updateWidget(
        name: 'AdviceWidget',
        iOSName: 'AdviceWidget',
        androidName: 'AdviceWidgetProvider',
      );
    } catch (e) {
      print('Error updating advice widget: $e');
    }
  }

  static Future<void> updateChartWidget({
    required List<double> expenses,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'expenses',
        expenses.join(','),
      );
      await HomeWidget.updateWidget(
        name: 'ChartWidget',
        iOSName: 'ChartWidget',
        androidName: 'ChartWidgetProvider',
      );
    } catch (e) {
      print('Error updating chart widget: $e');
    }
  }

  static Future<void> updateAllWidgets({
    required double balance,
    required String currency,
    required String advice,
    required List<double> expenses,
  }) async {
    await Future.wait([
      updateBalanceWidget(balance: balance, currency: currency),
      updateAdviceWidget(advice: advice),
      updateChartWidget(expenses: expenses),
    ]);
  }

  static Future<void> registerWidgets() async {
    try {
      await HomeWidget.registerBackgroundCallback(backgroundCallback);
    } catch (e) {
      print('Error registering widgets: $e');
    }
  }

  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri?.host == 'refresh') {
      // Handle widget refresh
      // This would typically fetch fresh data and update widgets
    }
  }
}
