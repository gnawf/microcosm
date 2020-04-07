package com.gnawf.microcosm.app.moshi

import com.gnawf.microcosm.app.model.Download
import com.gnawf.microcosm.app.model.DownloadJsonAdapter
import com.squareup.moshi.Moshi
import java.lang.reflect.Type

object Json {
  val moshi: Moshi = Moshi.Builder().add { type: Type, annotations: Set<Annotation>, moshi: Moshi ->
    return@add when (type) {
      Download::class.java -> DownloadJsonAdapter(moshi)
      else -> null
    }
  }.build()
}
