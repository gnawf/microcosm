package com.gnawf.microcosm.app.util

import android.app.NotificationChannel
import androidx.core.app.NotificationManagerCompat

/**
 * Creates a notification channel if it doesn't exist
 */
inline fun NotificationManagerCompat.createChannel(id: String, builder: (String) -> NotificationChannel) {
  val channel = getNotificationChannel(id)
  if (channel == null) {
    builder(id).also(this::createNotificationChannel)
  }
}
