package io.github.randnotiz.app

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.media.ExifInterface
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.InputStream
import java.text.SimpleDateFormat
import java.util.Locale
import kotlin.math.max

/**
 * Small image helpers for photos picked outside the MediaStore gallery
 * (e.g. Google Photos via the system photo picker): reads the capture date,
 * applies the EXIF orientation, downscales and writes a JPEG copy.
 */
object ImageTools {

    /** Result: width, height and capture time (epoch millis, or null). */
    fun importImage(src: String, dest: String, maxSide: Int, quality: Int): Map<String, Any?> =
        importStream({ FileInputStream(src) }, dest, maxSide, quality, knownTakenAt = null)

    /**
     * Reads the image from [open] (called up to three times), applies the EXIF
     * orientation, downscales to [maxSide] and writes a JPEG to [dest].
     * [knownTakenAt] (e.g. from the photo picker) wins over the EXIF date.
     */
    fun importStream(
        open: () -> InputStream,
        dest: String,
        maxSide: Int,
        quality: Int,
        knownTakenAt: Long?,
    ): Map<String, Any?> {
        val exif = try { open().use { ExifInterface(it) } } catch (e: Exception) { null }
        val takenAt = knownTakenAt ?: exif?.let { readDate(it) }
        val rotation = when (exif?.getAttributeInt(
            ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL,
        )) {
            ExifInterface.ORIENTATION_ROTATE_90 -> 90f
            ExifInterface.ORIENTATION_ROTATE_180 -> 180f
            ExifInterface.ORIENTATION_ROTATE_270 -> 270f
            else -> 0f
        }

        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        open().use { BitmapFactory.decodeStream(it, null, bounds) }
        require(bounds.outWidth > 0 && bounds.outHeight > 0) { "Not an image" }
        var sample = 1
        while (max(bounds.outWidth, bounds.outHeight) / (sample * 2) >= maxSide) sample *= 2
        var bitmap = open().use {
            BitmapFactory.decodeStream(it, null, BitmapFactory.Options().apply { inSampleSize = sample })
        } ?: throw IllegalArgumentException("Cannot decode image")

        val scale = maxSide.toFloat() / max(bitmap.width, bitmap.height)
        val matrix = Matrix()
        if (scale < 1f) matrix.postScale(scale, scale)
        if (rotation != 0f) matrix.postRotate(rotation)
        if (!matrix.isIdentity) {
            val transformed = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
            if (transformed != bitmap) bitmap.recycle()
            bitmap = transformed
        }

        val tmp = File("$dest.tmp")
        FileOutputStream(tmp).use { bitmap.compress(Bitmap.CompressFormat.JPEG, quality, it) }
        val width = bitmap.width
        val height = bitmap.height
        bitmap.recycle()
        if (!tmp.renameTo(File(dest))) throw IllegalStateException("Cannot write $dest")
        return mapOf("width" to width, "height" to height, "takenAt" to takenAt)
    }

    private fun readDate(exif: ExifInterface): Long? {
        val raw = exif.getAttribute(ExifInterface.TAG_DATETIME_ORIGINAL)
            ?: exif.getAttribute(ExifInterface.TAG_DATETIME)
            ?: return null
        return try {
            SimpleDateFormat("yyyy:MM:dd HH:mm:ss", Locale.ROOT).parse(raw)?.time
        } catch (e: Exception) {
            null
        }
    }
}
