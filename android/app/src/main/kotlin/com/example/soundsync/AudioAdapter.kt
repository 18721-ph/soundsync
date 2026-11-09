package com.example.soundsync

import android.app.Activity
import android.content.Intent
import android.media.*
import android.media.audiofx.Equalizer
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.math.pow

/** Owns only Sound Sync's session. Control and lifecycle calls run on main. */
class AudioAdapter(private val activity: Activity, private val channel: MethodChannel) {
    companion object { const val PICK_AUDIO = 7101 }
    private val manager = activity.getSystemService(AudioManager::class.java)
    private val handler = Handler(Looper.getMainLooper())
    private val attributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_MEDIA)
        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build()
    private var player: MediaPlayer? = null
    private var equalizer: Equalizer? = null
    private var ready = false
    private var picking: MethodChannel.Result? = null
    private var error: String? = null
    private var message = "Choose an audio file to begin."
    private var bass = 0.0
    private var midrange = 0.0
    private var treble = 0.0
    private var volume = 0.5
    private var bypass = false
    private var closed = false
    private val focusListener = AudioManager.OnAudioFocusChangeListener { change ->
        if (change != AudioManager.AUDIOFOCUS_GAIN) pause("Paused after audio focus changed.")
    }
    private val focusRequest = if (Build.VERSION.SDK_INT >= 26) {
        AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .setAudioAttributes(attributes).setOnAudioFocusChangeListener(focusListener).build()
    } else null
    private val devices = object : AudioDeviceCallback() {
        override fun onAudioDevicesAdded(added: Array<out AudioDeviceInfo>) { publish() }
        override fun onAudioDevicesRemoved(removed: Array<out AudioDeviceInfo>) {
            // Conservative: do not unexpectedly move playback to a loudspeaker.
            if (removed.any { it.isSink }) pause("Output disconnected. Select a route and press Play.")
            publish()
        }
    }
    init {
        manager.registerAudioDeviceCallback(devices, handler)
        channel.setMethodCallHandler(::handle)
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "status" -> Unit
                "chooseFile" -> {
                    check(picking == null) { "A file picker is already open." }
                    pause("Choose an audio file.")
                    picking = result
                    try {
                        activity.startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                            type = "audio/*"
                            addCategory(Intent.CATEGORY_OPENABLE)
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }, PICK_AUDIO)
                    } catch (e: Exception) {
                        picking = null
                        throw e
                    }
                    return
                }
                "play" -> {
                    check(ready) { "Choose a playable audio file first." }
                    val focus = if (Build.VERSION.SDK_INT >= 26) {
                        manager.requestAudioFocus(focusRequest!!)
                    } else {
                        @Suppress("DEPRECATION")
                        manager.requestAudioFocus(focusListener, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN)
                    }
                    check(focus == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) { "Audio focus is unavailable." }
                    player!!.start()
                    message = "Playing selected file. Output routing is managed by Android."
                    handler.postDelayed({ if (!closed) publish() }, 300)
                }
                "pause" -> pause("Paused.")
                "configure" -> {
                    // Validate the whole update before changing any stored settings.
                    val b = number(call, "bass", -12.0, 12.0)
                    val m = number(call, "midrange", -12.0, 12.0)
                    val t = number(call, "treble", -12.0, 12.0)
                    val v = number(call, "volume", 0.0, 1.0)
                    bass = b; midrange = m; treble = t; volume = v
                    bypass = call.argument<Boolean>("bypass") ?: false
                    applySettings()
                }
                "release" -> releasePlayer()
                else -> { result.notImplemented(); return }
            }
            result.success(state())
        } catch (e: Exception) {
            if (call.method == "configure") {
                // A partly applied effect must not be advertised as working.
                equalizer?.release()
                equalizer = null
                pause("Settings could not be applied. Playback paused.")
            }
            error = e.message ?: "Audio operation failed."
            publish()
            result.error("audio_error", error, null)
        }
    }

    private fun number(call: MethodCall, key: String, min: Double, max: Double): Double {
        val value = call.argument<Number>(key)?.toDouble()
        require(value != null && value.isFinite()) { "Invalid $key value." }
        return value.coerceIn(min, max)
    }

    fun onActivityResult(request: Int, result: Int, data: Intent?): Boolean {
        if (request != PICK_AUDIO) return false
        val pending = picking
        picking = null
        val uri = data?.data
        if (result != Activity.RESULT_OK || uri == null) {
            message = "File selection cancelled."
            pending?.success(state())
            return true
        }
        releasePlayer()
        error = null
        val next = MediaPlayer()
        player = next
        try {
            next.setAudioAttributes(attributes)
            next.setOnPreparedListener {
                if (player !== it || closed) return@setOnPreparedListener
                ready = true
                try {
                    equalizer = Equalizer(0, it.audioSessionId)
                    equalizer!!.setControlStatusListener { effect, control ->
                        if (!closed && effect === equalizer && !control) {
                            equalizer?.release()
                            equalizer = null
                            error = "Equalizer control was lost; playback is unprocessed."
                            publish()
                        }
                    }
                    applySettings()
                } catch (e: Exception) {
                    equalizer?.release()
                    equalizer = null
                    it.setVolume(volume.toFloat(), volume.toFloat())
                    error = "Session equalizer unavailable: ${e.message}"
                }
                message = "File ready. Press Play. EQ availability depends on the device."
                publish()
            }
            next.setOnCompletionListener {
                if (player !== it || closed) return@setOnCompletionListener
                abandonFocus()
                message = "Playback finished."
                publish()
            }
            next.setOnErrorListener { failed, what, extra ->
                if (player !== failed || closed) return@setOnErrorListener true
                releasePlayer()
                error = "Unable to play this file (media error $what/$extra)."
                publish()
                true
            }
            if (Build.VERSION.SDK_INT >= 24) {
                next.addOnRoutingChangedListener({ publish() }, handler)
            }
            next.setDataSource(activity, uri)
            message = "Preparing audio..."
            next.prepareAsync()
            pending?.success(state())
        } catch (e: Exception) {
            releasePlayer()
            error = "Cannot open audio: ${e.message}"
            pending?.success(state())
        }
        publish()
        return true
    }

    private fun applySettings() {
        if (!ready) return
        val eq = equalizer
        if (eq != null) {
            val range = eq.bandLevelRange
            for (i in 0 until eq.numberOfBands.toInt()) {
                val band = i.toShort()
                val hz = eq.getCenterFreq(band) / 1000.0
                val gain = if (hz < 250) bass else if (hz < 4000) midrange else treble
                eq.setBandLevel(band, (gain * 100).toInt().coerceIn(range[0].toInt(), range[1].toInt()).toShort())
            }
            check(eq.setEnabled(!bypass) == 0) { "Could not change equalizer state." }
        }
        // Reserve output headroom; this is not a measured pre-EQ gain or limiter.
        val boost = if (eq != null && !bypass) maxOf(0.0, bass, midrange, treble) else 0.0
        val gain = (volume * 10.0.pow(-boost / 20.0)).toFloat()
        player?.setVolume(gain, gain)
    }

    fun pause(reason: String = "Paused while app is in the background.") {
        if (ready && player?.isPlaying == true) player?.pause()
        abandonFocus()
        message = reason
        publish()
    }

    @Suppress("DEPRECATION")
    private fun abandonFocus() {
        if (Build.VERSION.SDK_INT >= 26) manager.abandonAudioFocusRequest(focusRequest!!)
        else manager.abandonAudioFocus(focusListener)
    }

    private fun releasePlayer() {
        ready = false
        equalizer?.release()
        equalizer = null
        player?.release()
        player = null
        abandonFocus()
        message = "Choose an audio file to begin."
    }

    private fun deviceLabel(device: AudioDeviceInfo): String {
        val kind = when (device.type) {
            AudioDeviceInfo.TYPE_BLUETOOTH_A2DP, AudioDeviceInfo.TYPE_BLUETOOTH_SCO -> "Bluetooth"
            AudioDeviceInfo.TYPE_WIRED_HEADSET, AudioDeviceInfo.TYPE_WIRED_HEADPHONES, AudioDeviceInfo.TYPE_LINE_ANALOG -> "Wired"
            AudioDeviceInfo.TYPE_USB_DEVICE, AudioDeviceInfo.TYPE_USB_HEADSET, AudioDeviceInfo.TYPE_USB_ACCESSORY -> "USB"
            AudioDeviceInfo.TYPE_BUILTIN_SPEAKER -> "Speaker"
            AudioDeviceInfo.TYPE_BUILTIN_EARPIECE -> "Earpiece"
            26, 27, 30 -> "Bluetooth LE"
            else -> "Audio output"
        }
        return "$kind: ${device.productName}"
    }

    private fun state(): Map<String, Any?> {
        val playing = ready && player?.isPlaying == true
        val route = if (playing && Build.VERSION.SDK_INT >= 24) player?.routedDevice else null
        return mapOf(
            "ready" to ready, "playing" to playing,
            "eqAvailable" to (equalizer != null), "bypass" to bypass,
            "route" to (route?.let(::deviceLabel) ?: "No active playback route"),
            "outputs" to manager.getDevices(AudioManager.GET_DEVICES_OUTPUTS).map(::deviceLabel),
            "message" to message, "error" to error
        )
    }
    private fun publish() { if (!closed) channel.invokeMethod("state", state()) }
    fun close() {
        closed = true
        manager.unregisterAudioDeviceCallback(devices)
        handler.removeCallbacksAndMessages(null)
        picking?.error("closed", "Activity closed during file selection.", null)
        picking = null
        releasePlayer()
        channel.setMethodCallHandler(null)
    }
}
