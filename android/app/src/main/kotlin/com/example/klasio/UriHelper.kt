package com.example.klasio

import android.content.Context
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.provider.OpenableColumns
import android.util.Log
import java.io.File

object UriHelper {
    private const val TAG = "UriHelper"
    private const val UNKNOWN_FILE = "unknown_file"

    /**
     * Obtiene los bytes de un URI dado.
     * @param context Contexto de la aplicación
     * @param uriString String representando el URI
     * @return ByteArray con el contenido del archivo o null si hay error
     */
    fun getBytesFromUri(context: Context, uriString: String?): ByteArray? {
        return try {
            uriString?.let {
                val uri = Uri.parse(it)
                context.contentResolver.openInputStream(uri)?.use { input ->
                    input.readBytes()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error reading bytes from URI: $uriString", e)
            null
        }
    }

    /**
     * Obtiene el nombre de archivo desde una entrada que puede ser content://, file:// o path local.
     * @param context Contexto de la aplicación
     * @param path Ruta o URI en formato String
     * @return Nombre del archivo
     */
    fun getFileNameFromPath(context: Context, path: String): String {
        return try {
            when {
                path.startsWith("content://") -> {
                    getFileNameFromUri(context, Uri.parse(path))
                }

                path.startsWith("file://") -> {
                    File(path.removePrefix("file://")).name.ifBlank { UNKNOWN_FILE }
                }

                else -> {
                    File(path).name.ifBlank { UNKNOWN_FILE }
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error getting file name from path: $path", e)
            UNKNOWN_FILE
        }
    }

    /**
     * Obtiene el nombre de archivo desde un URI genérico.
     * Para content:// usa DISPLAY_NAME; si no existe, usa el último segmento del URI.
     * @param context Contexto de la aplicación
     * @param uri URI del archivo
     * @return Nombre del archivo
     */
    fun getFileNameFromUri(context: Context, uri: Uri): String {
        try {
            context.contentResolver.query(
                uri,
                arrayOf(OpenableColumns.DISPLAY_NAME),
                null,
                null,
                null
            )?.use { cursor ->
                val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (cursor.moveToFirst() && nameIndex >= 0) {
                    val displayName = cursor.getString(nameIndex)
                    if (!displayName.isNullOrBlank()) {
                        return displayName
                    }
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "Could not get filename from URI: $uri", e)
        }

        return uri.lastPathSegment
            ?.substringAfterLast('/')
            ?.takeIf { it.isNotBlank() }
            ?: UNKNOWN_FILE
    }

    /**
     * Obtiene un ParcelFileDescriptor desde una ruta (content://, file:// o path local).
     * @param context Contexto de la aplicación
     * @param path Ruta o URI en formato String
     * @return ParcelFileDescriptor o null si hay error
     */
    fun getFileDescriptorFromPath(context: Context, path: String): ParcelFileDescriptor? {
        return try {
            when {
                path.startsWith("content://") -> {
                    context.contentResolver.openFileDescriptor(Uri.parse(path), "r")
                }

                path.startsWith("file://") -> {
                    val file = File(path.removePrefix("file://"))
                    ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
                }

                else -> {
                    val file = File(path)
                    ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error opening file descriptor for: $path", e)
            null
        }
    }
}