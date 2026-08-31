package com.example.klasio

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager

/** Gestor de versiones de la aplicación para detectar actualizaciones. */
class AppVersionManager(private val context: Context) {

    private val prefs = context.getSharedPreferences("app_version", Context.MODE_PRIVATE)

    private val KEY_LAST_VERSION = "last_version_code"

    /**
     * Verifica si hay una actualización de la aplicación.
     * @return UpdateInfo indicando el estado de la versión
     */
    fun checkForUpdate(): UpdateInfo {

        val (currentVersionName, currentVersionCode) = getCurrentAppVersion()

        val savedVersionCode = prefs.getLong(KEY_LAST_VERSION, -1)

        return when {
            savedVersionCode == -1L -> {

                saveCurrentVersion(currentVersionCode)

                UpdateInfo.FirstInstall(currentVersionName, currentVersionCode)
            }
            savedVersionCode < currentVersionCode -> {

                val oldVersion = savedVersionCode

                saveCurrentVersion(currentVersionCode)

                UpdateInfo.Updated(currentVersionName, currentVersionCode, oldVersion)
            }
            else -> {

                UpdateInfo.SameVersion(currentVersionName, currentVersionCode)
            }
        }
    }

    /**
     * Guarda la versión actual en las preferencias.
     * @param versionCode Código de versión a guardar
     */
    private fun saveCurrentVersion(versionCode: Long) {

        prefs.edit().putLong(KEY_LAST_VERSION, versionCode).apply()
    }

    /**
     * Obtiene la versión actual de la aplicación.
     * @return Par con el nombre de la versión y el código de versión
     */
    fun getCurrentAppVersion(): Pair<String, Long> {

        return try {

            val packageInfo: PackageInfo =
                    context.packageManager.getPackageInfo(context.packageName, 0)

            val versionName = packageInfo.versionName ?: "Unknown"

            val versionCode =
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {

                        packageInfo.longVersionCode
                    } else {

                        packageInfo.versionCode.toLong()
                    }

            Pair(versionName, versionCode)
        } catch (e: PackageManager.NameNotFoundException) {

            Pair("Unknown", -1L)
        }
    }
}

/** Clase sellada que representa el estado de actualización de la aplicación. */
sealed class UpdateInfo {

    /** Primera instalación de la aplicación. */
    data class FirstInstall(val version: String, val versionCode: Long) : UpdateInfo()

    /** La aplicación fue actualizada. */
    data class Updated(val version: String, val versionCode: Long, val oldVersionCode: Long) :
            UpdateInfo()

    /** La aplicación está en la misma versión. */
    data class SameVersion(val version: String, val versionCode: Long) : UpdateInfo()
}
