package com.gnawf.microcosm.app.workers

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager.IMPORTANCE_NONE
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.Constraints
import androidx.work.Data
import androidx.work.ForegroundInfo
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.gnawf.microcosm.app.http.HttpClient
import com.gnawf.microcosm.app.model.Download
import com.gnawf.microcosm.app.moshi.Json
import com.gnawf.microcosm.app.util.child
import com.gnawf.microcosm.app.util.createChannel
import com.gnawf.microcosm.app.util.listTypeAdapter
import okhttp3.Request
import okio.buffer
import okio.sink
import okio.source
import java.io.File
import java.util.UUID
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.Future
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit
import java.util.concurrent.TimeUnit.MILLISECONDS
import java.util.concurrent.atomic.AtomicInteger

class DownloadWork constructor(context: Context, params: WorkerParameters) : Worker(context, params) {
  private val client = HttpClient.use()

  private val numFailuresByUrl = hashMapOf<String, Int>()

  private val downloadsDir = getDownloadsDir(context)

  private val downloadAdapter = Json.moshi.adapter(Download::class.java)

  private val numDownloadsCompleted = AtomicInteger()

  private val notificationId = System.identityHashCode(this)

  private val scheduler = Executors.newScheduledThreadPool(8)

  private val notificationManager = NotificationManagerCompat.from(applicationContext)

  private val notificationChannelId = "notifications.channels.download-worker"

  private lateinit var urls: List<String>

  override fun doWork(): Result {
    // Read input data
    val requestFilePath = inputData.getString(REQUEST_FILE_PATH) ?: throw NullPointerException("No request file")
    urls = readWorkRequest(requestFilePath)

    // Setup service
    createNotificationChannel()
    setForegroundAsync()

    // Submit all the jobs
    for (url in urls) {
      scheduler.download(url)
    }

    // Wait for jobs to finish
    scheduler.shutdown()
    scheduler.awaitTermination(urls.size, TimeUnit.MINUTES)

    return Result.success()
  }

  override fun onStopped() {
    super.onStopped()
    scheduler.shutdownNow()
  }

  private fun ScheduledExecutorService.download(url: String): Future<*> {
    return submit {
      val request = Request.Builder().url(url).build()
      val bodyString = client.newCall(request).execute().use { response ->
        // Response handling
        if (!response.isSuccessful) {
          val numFailures = numFailuresByUrl[url] ?: 0
          if (numFailures <= 3) {
            scheduleLater(url, 1000)
            numFailuresByUrl[url] = numFailures + 1
          }
          return@submit
        }

        response.body?.string() ?: throw NullPointerException("No body to read from")
      }

      // Save the response as a Download object
      val download = Download(url, bodyString)
      val json = downloadAdapter.toJson(download)

      // Save to disk
      val fileName = UUID.randomUUID().toString()
      val file = File(downloadsDir, fileName).also { it.createNewFile() }
      file.sink().buffer().use { it.writeUtf8(json) }

      onFinishDownload()
    }
  }

  private fun onFinishDownload() {
    val progress = numDownloadsCompleted.incrementAndGet()
    val data = Data.Builder()
        .putInt("numDownloaded", progress)
        .putInt("totalChapters", urls.size)
        .build()
    setProgressAsync(data)
    updateNotification()
  }

  private fun updateNotification() {
    val notification = newNotification()
    notificationManager.notify(notificationId, notification)
  }

  private fun newNotification(): Notification {
    val cancelIntent = WorkManager.getInstance(applicationContext).createCancelPendingIntent(id)
    val max = urls.size
    val progress = numDownloadsCompleted.get()
    return NotificationCompat.Builder(applicationContext, notificationChannelId)
        .setSmallIcon(android.R.drawable.stat_sys_download)
        .setContentTitle(applicationContext.packageManager.getApplicationLabel(applicationContext.applicationInfo))
        .setContentText("Downloading")
        .setOngoing(true)
        .setProgress(max, progress, false)
        .addAction(android.R.drawable.ic_delete, "Cancel", cancelIntent)
        .setOnlyAlertOnce(true)
        .build()
  }

  private fun setForegroundAsync() {
    val notification = newNotification()
    val info = ForegroundInfo(notificationId, notification)
    super.setForegroundAsync(info)
  }

  private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      notificationManager.createChannel(notificationChannelId) { id ->
        NotificationChannel(id, "Download Progress", IMPORTANCE_NONE)
      }
    }
  }

  private fun ScheduledExecutorService.scheduleLater(url: String, delay: Long, unit: TimeUnit = MILLISECONDS) {
    schedule({ download(url) }, delay, unit)
  }

  private fun ExecutorService.awaitTermination(delay: Int, unit: TimeUnit): Boolean {
    return awaitTermination(delay.toLong(), unit)
  }

  companion object {
    private const val REQUEST_FILE_PATH = "work-request-file-path"
    const val TAG = "chapter-download"

    fun newOneTimeWorkRequest(context: Context, urls: List<String>): OneTimeWorkRequest {
      val workRequestDir = getWorkRequestsDir(context)
      val workRequestFilePath = writeWorkRequest(workRequestDir, urls)

      val inputData = Data.Builder()
          .putString(REQUEST_FILE_PATH, workRequestFilePath)
          .build()
      val constraints = Constraints.Builder()
          .setRequiresStorageNotLow(true)
          .setRequiredNetworkType(NetworkType.CONNECTED)
          .build()
      return OneTimeWorkRequest.Builder(DownloadWork::class.java)
          .setConstraints(constraints)
          .setInputData(inputData)
          .addTag(TAG)
          .build()
    }

    fun getDownloadsDir(context: Context): File {
      return context.cacheDir.child("downloads").also { it.mkdir() }
    }

    private fun readWorkRequest(path: String): List<String> {
      val file = File(path)
      val content = file.source().buffer().use { it.readUtf8() }
      file.delete()
      return Json.moshi.listTypeAdapter<String>().fromJson(content) ?: throw NullPointerException("No work data")
    }

    private fun writeWorkRequest(directory: File, urls: List<String>): String {
      val workRequestFile = directory.child("${UUID.randomUUID()}")
      val json = Json.moshi.listTypeAdapter<String>().toJson(urls)
      workRequestFile.sink().buffer().use { it.writeUtf8(json) }
      return workRequestFile.absolutePath
    }

    private fun getWorkRequestsDir(context: Context): File {
      return context.cacheDir.child("download-work-requests").also { it.mkdir() }
    }
  }
}
