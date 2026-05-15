package com.justdrink.justdrink

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class JustDrinkWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.just_drink_widget).apply {
                val currentMl = widgetData.getInt("currentMl", 0)
                val glassSize = widgetData.getInt("glassSize", 250)
                val glassesCount = widgetData.getInt("glassesCount", 0)
                val progress = (widgetData.getFloat("progress", 0f) * 100).toInt()

                setTextViewText(R.id.widget_intake, "${currentMl}ml water($glassesCount Glass)")
                
                // Background Intent using dynamic glassSize
                val logIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("justdrink://log?amount=$glassSize")
                )
                setOnClickPendingIntent(R.id.widget_add_glass, logIntent)

                // App Launch Intent
                val launchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, launchIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
