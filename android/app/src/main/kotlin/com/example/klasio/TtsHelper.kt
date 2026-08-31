package com.example.klasio

import android.content.Context
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import java.util.Locale

class TtsHelper(private val context: Context) : TextToSpeech.OnInitListener {
    private val TAG = "TtsHelper"

    private var tts: TextToSpeech? = null
    private var isInitialized = false
    private var pendingText: String? = null

    init {
        try {
            tts = TextToSpeech(context.applicationContext, this)
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing TextToSpeech", e)
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            isInitialized = true
            setLanguage("es")

            tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                override fun onStart(utteranceId: String?) {
                    Log.d(TAG, "TTS onStart: $utteranceId")
                }

                override fun onDone(utteranceId: String?) {
                    Log.d(TAG, "TTS onDone: $utteranceId")
                }

                @Deprecated("Deprecated in Java", ReplaceWith("onError(utteranceId, -1)"))
                override fun onError(utteranceId: String?) {
                    Log.e(TAG, "TTS onError: $utteranceId")
                }

                override fun onError(utteranceId: String?, errorCode: Int) {
                    Log.e(TAG, "TTS onError code $errorCode: $utteranceId")
                }
            })

            pendingText?.let {
                speak(it)
                pendingText = null
            }
        } else {
            Log.e(TAG, "Failed to initialize TextToSpeech, status: $status")
        }
    }

    fun setLanguage(langCode: String) {
        try {
            val locale = if (langCode.contains("_") || langCode.contains("-")) {
                val parts = langCode.replace("-", "_").split("_")
                if (parts.size >= 2) Locale(parts[0], parts[1]) else Locale(parts[0])
            } else {
                Locale(langCode)
            }

            val result = tts?.setLanguage(locale)
            if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
                Log.w(TAG, "Language $langCode not supported, falling back to Spanish or Default")
                val fallbackResult = tts?.setLanguage(Locale("es", "MX"))
                if (fallbackResult == TextToSpeech.LANG_MISSING_DATA || fallbackResult == TextToSpeech.LANG_NOT_SUPPORTED) {
                    tts?.setLanguage(Locale.getDefault())
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error setting language: $langCode", e)
        }
    }

    fun speak(
        text: String,
        langCode: String = "es",
        pitch: Float = 1.0f,
        speechRate: Float = 1.0f
    ) {
        if (!isInitialized) {
            pendingText = text
            return
        }

        try {
            setLanguage(langCode)
            tts?.setPitch(pitch)
            tts?.setSpeechRate(speechRate)

            val utteranceId = "tts_${System.currentTimeMillis()}"
            val params = Bundle()
            params.putString(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, utteranceId)

            tts?.speak(text, TextToSpeech.QUEUE_FLUSH, params, utteranceId)
        } catch (e: Exception) {
            Log.e(TAG, "Error speaking text", e)
        }
    }

    fun stop() {
        try {
            tts?.stop()
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping TTS", e)
        }
    }

    fun isSpeaking(): Boolean {
        return tts?.isSpeaking ?: false
    }

    fun shutdown() {
        try {
            tts?.stop()
            tts?.shutdown()
            tts = null
            isInitialized = false
        } catch (e: Exception) {
            Log.e(TAG, "Error shutting down TTS", e)
        }
    }
}
