package io.github.randnotiz.app

import androidx.annotation.ColorRes
import java.util.Calendar

/**
 * Meteorological seasons (northern hemisphere), as `Season` in Dart
 * (lib/core/theme/season.dart): spring from March, summer from June, autumn
 * from September, winter from December.
 */
internal enum class Season(
    /** Its launcher entry (activity-alias in AndroidManifest.xml). */
    val alias: String,
    /** The widget's accent (values/ and values-night/colors.xml). */
    @ColorRes val widgetAccent: Int,
) {
    SPRING("IconSpring", R.color.widget_accent_spring),
    SUMMER("IconSummer", R.color.widget_accent_summer),
    AUTUMN("IconAutumn", R.color.widget_accent_autumn),
    WINTER("IconWinter", R.color.widget_accent_winter);

    companion object {
        /** The season of a [Calendar.MONTH] (0 = January). */
        fun of(month: Int): Season = when (month) {
            Calendar.MARCH, Calendar.APRIL, Calendar.MAY -> SPRING
            Calendar.JUNE, Calendar.JULY, Calendar.AUGUST -> SUMMER
            Calendar.SEPTEMBER, Calendar.OCTOBER, Calendar.NOVEMBER -> AUTUMN
            else -> WINTER
        }

        fun now(): Season = of(Calendar.getInstance().get(Calendar.MONTH))
    }
}
