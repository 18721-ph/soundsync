package com.example.soundsync

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var audio: AudioAdapter? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        audio = AudioAdapter(this, MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "soundsync/audio"))
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (audio?.onActivityResult(requestCode, resultCode, data) != true) {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }
    override fun onStop() {
        audio?.pause()
        super.onStop()
    }
    override fun onDestroy() {
        audio?.close()
        audio = null
        super.onDestroy()
    }
}
