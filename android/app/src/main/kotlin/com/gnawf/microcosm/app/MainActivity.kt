package com.gnawf.microcosm.app

import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.view.WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS
import android.view.WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION
import android.view.WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
import androidx.work.WorkManager
import com.gnawf.microcosm.app.workers.DownloadWork
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.util.concurrent.Executors

class MainActivity : FlutterActivity(), MethodCallHandler {
  private val executor = Executors.newSingleThreadExecutor()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // Set transparent status bar
    window.also {
      it.addFlags(FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
      it.addFlags(FLAG_TRANSLUCENT_NAVIGATION)
      it.clearFlags(FLAG_TRANSLUCENT_STATUS)
      it.statusBarColor = Color.TRANSPARENT
    }
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    // Register our own message channel to leverage Android system code
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "microcosm").setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "hasActiveDownloads" -> hasActiveDownloads(result)
      "getDownloadsDir" -> getDownloadsDir(result)
      "getDownloadProgress" -> getDownloadProgress(
          call.argument("id") ?: throw NullPointerException("Missing value for id argument"),
          result
      )
      "downloadUrls" -> download(
          call.argument("urls") ?: throw NullPointerException("Missing value for urls argument"),
          result
      )
      else -> result.notImplemented()
    }
  }

  private fun hasActiveDownloads(result: MethodChannel.Result) {
    val workInfos = WorkManager.getInstance(this).getWorkInfosByTag(DownloadWork.TAG)
    workInfos.addListener(Runnable {
      val unfinished = workInfos.get().count { !it.state.isFinished }
      runOnMainThread { result.success(unfinished > 0) }
    }, executor)
  }

  private fun getDownloadsDir(result: MethodChannel.Result) {
    val dir = DownloadWork.getDownloadsDir(this)
    result.success(dir.absolutePath)
  }

  private fun getDownloadProgress(id: String, result: MethodChannel.Result) {
    val workInfos = WorkManager.getInstance(this).getWorkInfosByTag(id)
    workInfos.addListener(Runnable {
      val info = workInfos.get().single()
      result.success(info.progress.keyValueMap)
    }, executor)
  }

  private fun download(urls: List<String>, result: MethodChannel.Result) {
    executor.submit {
      try {
        val download = DownloadWork.newOneTimeWorkRequest(this, urls)
        WorkManager.getInstance(this).enqueue(download)
        // Notify the Flutter invocation
        runOnMainThread { result.success("${download.id}") }
      } catch (e: Exception) {
        runOnMainThread { result.error("download-error", e.message, null) }
        throw e
      }
    }
  }

  private fun runOnMainThread(task: () -> Unit) {
    Handler(mainLooper).post(task)
  }
}
