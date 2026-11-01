package io.github.randnotiz.app.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import io.github.randnotiz.app.MainActivity
import io.github.randnotiz.app.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * "Erinnerung des Tages": shows the photo, date and "Vor X Jahren" of a
 * memory. The Flutter app pre-computes one entry per day for the next week
 * (key `memory_entries`), so the widget can switch at midnight without
 * starting the app. Note text is only present if the user enabled it.
 */
class MemoryWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val entry = todaysEntry(widgetData)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.memory_widget)
            val launch = HomeWidgetLaunchIntent.getActivity(
                context, MainActivity::class.java, Uri.parse("randnotiz://memories"),
            )
            views.setOnClickPendingIntent(R.id.widget_root, launch)

            if (entry == null) {
                views.setViewVisibility(R.id.widget_photo, View.GONE)
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
                views.setTextViewText(R.id.widget_ago, context.getString(R.string.widget_title))
                views.setTextViewText(R.id.widget_date, context.getString(R.string.widget_empty))
                views.setViewVisibility(R.id.widget_text, View.GONE)
            } else {
                val bitmap = entry.photo?.let { decodeScaled(it, 480) }
                if (bitmap != null) {
                    views.setImageViewBitmap(R.id.widget_photo, bitmap)
                    views.setViewVisibility(R.id.widget_photo, View.VISIBLE)
                    views.setViewVisibility(R.id.widget_empty, View.GONE)
                } else {
                    views.setViewVisibility(R.id.widget_photo, View.GONE)
                    views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
                }
                views.setTextViewText(R.id.widget_ago, entry.agoLabel)
                views.setTextViewText(R.id.widget_date, entry.dateLabel)
                if (entry.text.isNullOrBlank()) {
                    views.setViewVisibility(R.id.widget_text, View.GONE)
                } else {
                    views.setTextViewText(R.id.widget_text, entry.text)
                    views.setViewVisibility(R.id.widget_text, View.VISIBLE)
                }
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private data class Entry(
        val dateLabel: String,
        val agoLabel: String,
        val photo: String?,
        val text: String?,
    )

    private fun todaysEntry(prefs: SharedPreferences): Entry? {
        val raw = prefs.getString("memory_entries", null) ?: return null
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.ROOT).format(Date())
        return try {
            val array = JSONArray(raw)
            (0 until array.length())
                .map { array.getJSONObject(it) }
                .firstOrNull { it.optString("day") == today }
                ?.let {
                    Entry(
                        dateLabel = it.optString("dateLabel"),
                        agoLabel = it.optString("agoLabel"),
                        photo = it.optString("photo").ifBlank { null },
                        text = it.optString("text").ifBlank { null },
                    )
                }
        } catch (e: Exception) {
            null
        }
    }

    /** Decodes [path] with downsampling so the bitmap fits RemoteViews limits. */
    private fun decodeScaled(path: String, maxSide: Int): Bitmap? {
        val file = File(path)
        if (!file.exists()) return null
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        var sample = 1
        while (bounds.outWidth / (sample * 2) >= maxSide || bounds.outHeight / (sample * 2) >= maxSide) {
            sample *= 2
        }
        return BitmapFactory.decodeFile(path, BitmapFactory.Options().apply { inSampleSize = sample })
    }
}
