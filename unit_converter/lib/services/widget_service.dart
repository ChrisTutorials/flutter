import 'package:home_widget/home_widget.dart';

import '../utils/platform_utils.dart';

class WidgetService {
  static const String androidProviderName = 'UnitConverterWidgetProvider';

  static Future<bool> isAvailable() async {
    if (!PlatformUtils.isAndroid) {
      return false;
    }

    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> saveLatestConversion({
    required String title,
    required String result,
    required String preset,
  }) async {
    if (!PlatformUtils.isAndroid) {
      return;
    }

    try {
      await Future.wait([
        HomeWidget.saveWidgetData('latest_title', title),
        HomeWidget.saveWidgetData('latest_result', result),
        HomeWidget.saveWidgetData('latest_preset', preset),
        HomeWidget.saveWidgetData(
          'widget_updated_at',
          DateTime.now().toIso8601String(),
        ),
      ]);

      await HomeWidget.updateWidget(name: androidProviderName);
    } catch (_) {
      return;
    }
  }

  static Future<void> requestPin() async {
    if (!PlatformUtils.isAndroid) {
      return;
    }

    try {
      await HomeWidget.requestPinWidget(name: androidProviderName);
    } catch (_) {
      return;
    }
  }
}
