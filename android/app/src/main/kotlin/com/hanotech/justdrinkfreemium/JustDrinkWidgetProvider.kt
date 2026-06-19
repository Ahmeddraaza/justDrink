package com.hanotech.justdrinkfreemium

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
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
                val isPremium = widgetData.getBoolean("isPremium", false)

                if (!isPremium) {
                    // Show locked state
                    setViewVisibility(R.id.widget_normal_content, View.GONE)
                    setViewVisibility(R.id.widget_locked_content, View.VISIBLE)
                    
                    // App Launch Intent — tapping container opens app to subscribe
                    val launchIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java
                    )
                    setOnClickPendingIntent(R.id.widget_container, launchIntent)
                } else {
                    // Show normal content
                    setViewVisibility(R.id.widget_normal_content, View.VISIBLE)
                    setViewVisibility(R.id.widget_locked_content, View.GONE)

                    val currentMl    = widgetData.getInt("currentMl", 0)
                    val goalMl       = widgetData.getInt("goalMl", 2500)
                    val glassSize    = widgetData.getInt("glassSize", 250)
                    val glassesCount = widgetData.getInt("glassesCount", 0)

                    // progress may be stored as Double (Long bits) or Float — handle both safely
                    val progress: Float = try {
                        widgetData.getFloat("progress", 0f)
                    } catch (e: ClassCastException) {
                        // Dart's saveWidgetData<double> stores a Long on Android
                        val bits = widgetData.getLong("progress", 0L)
                        java.lang.Double.longBitsToDouble(bits).toFloat()
                    }

                    // Water fill level: ClipDrawable uses 0–10000 scale (0=empty, 10000=full)
                    val fillLevel = (progress * 10000).toInt().coerceIn(0, 10000)

                    // Update intake label
                    setTextViewText(R.id.widget_intake, "${currentMl}ml / ${goalMl}ml (${glassesCount} Glass)")

                    // Update water fill
                    setInt(R.id.widget_water_fill, "setImageLevel", fillLevel)

                    // Handle text colors: timer and subtext turn white when full or mostly full
                    val fillFraction = progress
                    val textColor = if (fillFraction >= 1.0f) {
                        android.graphics.Color.WHITE
                    } else {
                        android.graphics.Color.parseColor("#1A1C1E")
                    }
                    val subTextColor = if (fillFraction >= 1.0f) {
                        android.graphics.Color.argb(217, 255, 255, 255)
                    } else {
                        android.graphics.Color.argb(179, 26, 28, 30)
                    }
                    setTextColor(R.id.widget_time, textColor)
                    setTextColor(R.id.widget_intake, subTextColor)

                    // Handle full state (no white space)
                    if (fillFraction >= 1.0f) {
                        setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_water_full_bg)
                        setViewVisibility(R.id.widget_water_fill, View.GONE)
                    } else {
                        setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background)
                        setViewVisibility(R.id.widget_water_fill, View.VISIBLE)
                    }

                    // iOS: icon uses foregroundStyle — blue gradient when fill <= 50%, white when fill > 50%
                    // Swap between pre-tinted vector drawables to match user request: white only when full
                    if (fillFraction >= 1.0f) {
                        setImageViewResource(R.id.widget_drop_icon, R.drawable.widget_icon_white)
                    } else {
                        setImageViewResource(R.id.widget_drop_icon, R.drawable.widget_icon_blue)
                    }

                    // Background Intent — logs one glass (button click) silently in background
                    val logIntent = HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("justdrink://log?amount=$glassSize")
                    )
                    setOnClickPendingIntent(R.id.widget_add_glass, logIntent)

                    // App Launch Intent — tapping container opens app
                    val launchIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java
                    )
                    setOnClickPendingIntent(R.id.widget_container, launchIntent)
                }
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
