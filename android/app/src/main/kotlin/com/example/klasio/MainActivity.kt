package com.example.klasio

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.core.content.FileProvider
import com.jakewharton.processphoenix.ProcessPhoenix
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity() {
    private val TAG = "MainActivity"
    private val CHANNEL = "com.example.klasio/channel"

    private lateinit var versionManager: AppVersionManager
    private lateinit var ttsHelper: TtsHelper

    private val PICK_IMAGES = 1001
    private val PICK_FOLDER = 1003
    private var pendingResult: MethodChannel.Result? = null
    private var pendingRequestCode: Int? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        versionManager = AppVersionManager(this)
        ttsHelper = TtsHelper(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "get-app-version" -> {
                    val updateInfo = versionManager.checkForUpdate()
                    when (updateInfo) {
                        is UpdateInfo.FirstInstall -> {
                            result.success(
                                mapOf(
                                    "status" to "first_install",
                                    "version" to updateInfo.version,
                                    "versionCode" to updateInfo.versionCode
                                )
                            )
                        }
                        is UpdateInfo.Updated -> {
                            result.success(
                                mapOf(
                                    "status" to "updated",
                                    "version" to updateInfo.version,
                                    "versionCode" to updateInfo.versionCode,
                                    "oldVersionCode" to updateInfo.oldVersionCode
                                )
                            )
                        }
                        is UpdateInfo.SameVersion -> {
                            result.success(
                                mapOf(
                                    "status" to "same_version",
                                    "version" to updateInfo.version,
                                    "versionCode" to updateInfo.versionCode
                                )
                            )
                        }
                    }
                }
                "optimizeImage" -> {
                    val imagePath = call.argument<String>("imagePath")
                        ?: call.argument<String>("path")
                    val quality = call.argument<Int>("quality") ?: 80
                    val maxWidth = call.argument<Int>("maxWidth") ?: 1920
                    val maxHeight = call.argument<Int>("maxHeight") ?: 2560

                    if (!imagePath.isNullOrEmpty()) {
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val optimizedPath = ImageProcessor.optimizeImage(
                                    this@MainActivity,
                                    imagePath,
                                    quality,
                                    maxWidth,
                                    maxHeight
                                )
                                withContext(Dispatchers.Main) {
                                    if (optimizedPath != null) {
                                        result.success(optimizedPath)
                                    } else {
                                        result.error(
                                            "IMG_ERROR",
                                            "No se pudo optimizar la imagen: $imagePath",
                                            null
                                        )
                                    }
                                }
                            } catch (e: Exception) {
                                Log.e(TAG, "Error in optimizeImage", e)
                                withContext(Dispatchers.Main) {
                                    result.error("IMG_ERROR", e.message ?: "Unknown error", null)
                                }
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Image path is null or empty", null)
                    }
                }
                "extractTextFromImage" -> {
                    val imagePath = call.argument<String>("imagePath")
                        ?: call.argument<String>("path")

                    if (!imagePath.isNullOrEmpty()) {
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val text = ImageProcessor.extractTextFromImage(
                                    this@MainActivity,
                                    imagePath
                                )
                                withContext(Dispatchers.Main) {
                                    if (text != null) {
                                        result.success(text)
                                    } else {
                                        result.error(
                                            "OCR_ERROR",
                                            "No se pudo extraer texto de la imagen: $imagePath",
                                            null
                                        )
                                    }
                                }
                            } catch (e: Exception) {
                                Log.e(TAG, "Error in extractTextFromImage", e)
                                withContext(Dispatchers.Main) {
                                    result.error("OCR_ERROR", e.message ?: "Unknown error", null)
                                }
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Image path is null or empty", null)
                    }
                }
                "ttsSpeak" -> {
                    val text = call.argument<String>("text") ?: ""
                    val language = call.argument<String>("language") ?: "es"
                    val pitch = (call.argument<Double>("pitch") ?: 1.0).toFloat()
                    val rate = (call.argument<Double>("rate") ?: 1.0).toFloat()

                    if (text.isNotEmpty()) {
                        ttsHelper.speak(text, language, pitch, rate)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Text is empty", null)
                    }
                }
                "ttsStop" -> {
                    ttsHelper.stop()
                    result.success(null)
                }
                "ttsIsSpeaking" -> {
                    result.success(ttsHelper.isSpeaking())
                }
                "restart_app" -> {
                    ProcessPhoenix.triggerRebirth(context)
                    result.success(null)
                }
                "installApk" -> {
                    val filePath = call.argument<String>("filePath")
                    if (!filePath.isNullOrEmpty()) {
                        installApk(filePath)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is null or empty", null)
                    }
                }
                "save-key-value" -> {
                    val argumentKey = call.argument<String>("key")
                    val value = call.argument<Boolean>("value")

                    if (!argumentKey.isNullOrEmpty() && value != null) {
                        val sharedPref = getSharedPreferences("zylix", Context.MODE_PRIVATE)
                        with(sharedPref.edit()) {
                            putBoolean(argumentKey, value)
                            apply()
                        }
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Key or value is null or empty", null)
                    }
                }
                "get-key-value" -> {
                    val argumentKey = call.argument<String>("key")

                    if (!argumentKey.isNullOrEmpty()) {
                        val sharedPref = getSharedPreferences("zylix", Context.MODE_PRIVATE)
                        val value = sharedPref.getBoolean(argumentKey, false)
                        result.success(value)
                    } else {
                        result.error("INVALID_ARGUMENT", "Key is null or empty", null)
                    }
                }
                "setExecutable" -> {
                    val filePath = call.argument<String>("path")
                    val success = FileUtils.setExecutable(filePath)
                    result.success(success)
                }
                "pickMultipleImages" -> {
                    pendingResult = result
                    pendingRequestCode = PICK_IMAGES
                    pickMultipleImagesFromGallery()
                }
                "pickFolder" -> {
                    pendingResult = result
                    pendingRequestCode = PICK_FOLDER
                    pickFolder()
                }
                "getBytesFromUri" -> {
                    val uriString = call.argument<String>("uri")
                    val bytes = UriHelper.getBytesFromUri(this, uriString)
                    result.success(bytes)
                }
                "copyUriToDirectory" -> {
                    val sourceUri = call.argument<String>("sourceUri")
                    val outputDirPath = call.argument<String>("outputDirPath")
                    val fileName = call.argument<String>("fileName")
                    if (sourceUri != null && outputDirPath != null && fileName != null) {
                        CoroutineScope(Dispatchers.IO).launch {
                            try {
                                val uri = Uri.parse(sourceUri)
                                val inputStream = contentResolver.openInputStream(uri)
                                    ?: throw Exception("Cannot open stream for $sourceUri")
                                val (outputStream, _) = FileUtils.createOutputFile(
                                    this@MainActivity, outputDirPath, fileName, "image/jpeg"
                                ) ?: throw Exception("Cannot create output file")
                                inputStream.use { inp -> outputStream.use { out -> inp.copyTo(out) } }
                                withContext(Dispatchers.Main) {
                                    result.success(null)
                                }
                            } catch (e: Exception) {
                                Log.e(TAG, "Error in copyUriToDirectory", e)
                                withContext(Dispatchers.Main) {
                                    result.error("COPY_ERROR", e.message ?: "Unknown error", null)
                                }
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Missing arguments", null)
                    }
                }
                "clearCache" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        clearAppCache()
                        withContext(Dispatchers.Main) {
                            result.success(null)
                        }
                    }
                }
                "saveImageToGallery" -> {
                    val imagePath = call.argument<String>("imagePath")
                        ?: call.argument<String>("path")
                    val title = call.argument<String>("title") ?: "captura_${System.currentTimeMillis()}"

                    if (!imagePath.isNullOrEmpty()) {
                        CoroutineScope(Dispatchers.IO).launch {
                            val success = ImageProcessor.saveImageToGallery(
                                this@MainActivity,
                                imagePath,
                                title
                            )
                            withContext(Dispatchers.Main) {
                                result.success(success)
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Image path is empty", null)
                    }
                }
                "saveTextToFile" -> {
                    val text = call.argument<String>("text") ?: ""
                    val fileName = call.argument<String>("fileName") ?: "notas_${System.currentTimeMillis()}.txt"

                    if (text.isNotEmpty()) {
                        CoroutineScope(Dispatchers.IO).launch {
                            val savedPath = ImageProcessor.saveTextToFile(
                                this@MainActivity,
                                text,
                                fileName
                            )
                            withContext(Dispatchers.Main) {
                                if (savedPath != null) {
                                    result.success(savedPath)
                                } else {
                                    result.error("SAVE_ERROR", "No se pudo guardar el archivo", null)
                                }
                            }
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Text is empty", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun pickMultipleImagesFromGallery() {
        val intent = Intent(Intent.ACTION_GET_CONTENT)
        intent.type = "image/*"
        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        startActivityForResult(Intent.createChooser(intent, "Seleccionar imágenes"), PICK_IMAGES)
    }

    private fun pickFolder() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        intent.addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
        startActivityForResult(intent, PICK_FOLDER)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        val result = pendingResult
        val expectedCode = pendingRequestCode

        if (result == null || expectedCode == null || requestCode != expectedCode) {
            return
        }

        when (requestCode) {
            PICK_IMAGES -> {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    val uris = mutableListOf<String>()
                    val clipData = data.clipData

                    if (clipData != null) {
                        for (i in 0 until clipData.itemCount) {
                            val uri = clipData.getItemAt(i).uri
                            uris.add(uri.toString())
                        }
                    } else {
                        val uri = data.data
                        if (uri != null) uris.add(uri.toString())
                    }

                    result.success(uris)
                } else {
                    result.success(emptyList<String>())
                }
            }
            PICK_FOLDER -> {
                if (resultCode == Activity.RESULT_OK && data != null) {
                    val folderUri: Uri? = data.data

                    if (folderUri != null) {
                        contentResolver.takePersistableUriPermission(
                            folderUri,
                            Intent.FLAG_GRANT_READ_URI_PERMISSION
                        )
                        result.success(folderUri.toString())
                    } else {
                        result.success(null)
                    }
                } else {
                    result.success(null)
                }
            }
        }

        pendingResult = null
        pendingRequestCode = null
    }

    private fun installApk(filePath: String) {
        val apkFile = File(filePath)
        if (!apkFile.exists()) {
            return
        }

        val intent = Intent(Intent.ACTION_VIEW)
        val apkUri: Uri =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                FileProvider.getUriForFile(this, "$packageName.fileprovider", apkFile).also {
                    intent.flags = Intent.FLAG_GRANT_READ_URI_PERMISSION
                }
            } else {
                Uri.fromFile(apkFile)
            }

        intent.setDataAndType(apkUri, "application/vnd.android.package-archive")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        ttsHelper.shutdown()
        clearAppCache()
    }

    private fun clearAppCache() {
        try {
            val cacheDir = context.cacheDir
            if (cacheDir != null && cacheDir.isDirectory) {
                deleteDir(cacheDir)
            }
            val externalCacheDir = context.externalCacheDir
            if (externalCacheDir != null && externalCacheDir.isDirectory) {
                deleteDir(externalCacheDir)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error clearing cache", e)
        }
    }

    private fun deleteDir(dir: File?): Boolean {
        if (dir != null && dir.isDirectory) {
            val children = dir.list()
            if (children != null) {
                for (i in children.indices) {
                    val success = deleteDir(File(dir, children[i]))
                    if (!success) {
                        return false
                    }
                }
            }
        }
        return dir?.delete() ?: false
    }
}