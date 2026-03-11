package com.unitconverter.unit_converter

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class UnitConverterWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val title = widgetData.getString("latest_title", "Quick conversion")
            val result = widgetData.getString("latest_result", "Convert inside the app")
            val preset = widgetData.getString("latest_preset", "1 in = 2.54 cm")

            val views = RemoteViews(context.packageName, R.layout.unit_converter_widget).apply {
                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_result, result)
                setTextViewText(R.id.widget_preset, preset)
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}