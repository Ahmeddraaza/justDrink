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
                val goalMl = widgetData.getInt("goalMl", 2500)
                val progress = (widgetData.getFloat("progress", 0f) * 100).toInt()

                setTextViewText(R.id.widget_intake, "$currentMl / $goalMl ml")
                setProgressBar(R.id.widget_progress, 100, progress, false)

                // Log 250ml Button - Background Intent
                val logIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("justdrink://log?amount=250")
                )
                setOnClickPendingIntent(R.id.widget_add_250, logIntent)

                // App Launch Intent on Title/Progress click
                val launchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_title, launchIntent)
                setOnClickPendingIntent(R.id.widget_progress, launchIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
