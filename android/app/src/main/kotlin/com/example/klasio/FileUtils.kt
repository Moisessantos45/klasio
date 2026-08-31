package com.example.klasio

import android.content.Context
import android.net.Uri
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream

/** Utilidades para operaciones con archivos y directorios. */
object FileUtils {
    private const val TAG = "FileUtils"

    /**
     * Crea un archivo de salida en el directorio especificado.
     * @param context Contexto de la aplicación
     * @param dirPath Ruta del directorio (puede ser content:// o file://)
     * @param fileName Nombre del archivo a crear
     * @param mimeType Tipo MIME del archivo
     * @return Pair con el OutputStream y la ruta del archivo creado, o null si hay error
     */
    fun createOutputFile(
            context: Context,
            dirPath: String,
            fileName: String,
            mimeType: String = "application/octet-stream"
    ): Pair<OutputStream, String>? {
        return try {
            if (dirPath.startsWith("content://")) {
                val uri = Uri.parse(dirPath)

                val docFile =
                        if (uri.toString().contains("/tree/")) {
                            // Es una tree URI, usarla directamente
                            androidx.documentfile.provider.DocumentFile.fromTreeUri(context, uri)
                        } else {
                            // Es una document URI (como las subcarpetas), usar fromSingleUri
                            androidx.documentfile.provider.DocumentFile.fromSingleUri(context, uri)
                        }

                if (docFile == null || !docFile.isDirectory) {
                    Log.e(TAG, "Not a directory or cannot access: $dirPath, docFile=$docFile, isDirectory=${docFile?.isDirectory}")
                    throw IllegalArgumentException("Cannot access directory URI: $dirPath")
                }

                val newFile =
                        docFile.createFile(mimeType, fileName)
                                ?: throw IllegalArgumentException("Cannot create file: $fileName")

                val outputStream =
                        context.contentResolver.openOutputStream(newFile.uri)
                                ?: throw IllegalArgumentException(
                                        "Cannot open output stream for: ${newFile.uri}"
                                )

                Pair(outputStream, newFile.uri.toString())
            } else {
                val dir = File(dirPath)
                dir.mkdirs()

                val file = File(dir, fileName)
                Pair(FileOutputStream(file), file.absolutePath)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error creating output file: $fileName in $dirPath", e)
            null
        }
    }

    /**
     * Crea una subcarpeta dentro de un directorio padre y retorna el DocumentFile.
     * @param context Contexto de la aplicación
     * @param parentDirPath Ruta del directorio padre
     * @param folderName Nombre de la subcarpeta a crear
     * @return DocumentFile de la subcarpeta creada o null si hay error
     */
    fun createSubfolderDocumentFile(
            context: Context,
            parentDirPath: String,
            folderName: String
    ): androidx.documentfile.provider.DocumentFile? {
        return try {
            if (!parentDirPath.startsWith("content://")) {
                Log.e(TAG, "parentDirPath must be a content:// URI")
                return null
            }

            val parentUri = Uri.parse(parentDirPath)
            val parentDocFile =
                    androidx.documentfile.provider.DocumentFile.fromTreeUri(context, parentUri)
                            ?: throw IllegalArgumentException(
                                    "Cannot access parent directory URI: $parentDirPath"
                            )

            val existingFolder = parentDocFile.findFile(folderName)
            val subfolder =
                    if (existingFolder != null && existingFolder.isDirectory) {
                        existingFolder
                    } else {
                        parentDocFile.createDirectory(folderName)
                                ?: throw IllegalArgumentException(
                                        "Cannot create subfolder: $folderName"
                                )
                    }

            Log.d(TAG, "Created subfolder DocumentFile: ${subfolder.uri} for folder: $folderName")
            subfolder
        } catch (e: Exception) {
            Log.e(TAG, "Error creating subfolder: $folderName in $parentDirPath", e)
            null
        }
    }

    /**
     * Crea una subcarpeta dentro de un directorio padre.
     * @param context Contexto de la aplicación
     * @param parentDirPath Ruta del directorio padre
     * @param folderName Nombre de la subcarpeta a crear
     * @return Ruta de la subcarpeta creada o null si hay error
     */
    fun createSubfolder(context: Context, parentDirPath: String, folderName: String): String? {
        return try {
            if (parentDirPath.startsWith("content://")) {
                val subfolder = createSubfolderDocumentFile(context, parentDirPath, folderName)
                subfolder?.uri?.toString()
            } else {
                val parentDir = File(parentDirPath)
                val subfolder = File(parentDir, folderName)

                if (!subfolder.exists()) {
                    subfolder.mkdirs()
                }

                val subfolderPath = subfolder.absolutePath
                Log.d(TAG, "Created subfolder path: $subfolderPath for folder: $folderName")
                subfolderPath
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error creating subfolder: $folderName in $parentDirPath", e)
            null
        }
    }

    /**
     * Establece permisos de ejecución en un archivo.
     * @param filePath Ruta del archivo
     * @return true si se establecieron los permisos correctamente, false en caso contrario
     */
    fun setExecutable(filePath: String?): Boolean {
        return try {
            if (filePath?.startsWith("content://") == true) {
                Log.w(TAG, "Cannot set executable flag on a content URI: $filePath")
                return false
            }

            filePath?.let { path ->
                File(path).apply {
                    setExecutable(true, false)
                    setReadable(true, false)
                    setWritable(true, false)
                }

                true
            }
                    ?: false
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}

/** Extension function para eliminar un archivo de forma segura. */
fun File.deleteSafely() {
    try {
        if (exists()) delete()
    } catch (e: Exception) {
        Log.e("FileUtils", "Delete failed: $absolutePath", e)
    }
}
