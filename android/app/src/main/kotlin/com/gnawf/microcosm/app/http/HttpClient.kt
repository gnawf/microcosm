package com.gnawf.microcosm.app.http

import okhttp3.OkHttpClient
import java.lang.ref.WeakReference

/**
 * On demand reference to an OkHttpClient that is released when it's not used
 */
object HttpClient {
  private var clientRef: WeakReference<OkHttpClient>? = null

  fun use(): OkHttpClient {
    return clientRef?.get() ?: OkHttpClient().also { clientRef = WeakReference(it) }
  }
}
