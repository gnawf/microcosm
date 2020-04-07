package com.gnawf.microcosm.app.util

import com.squareup.moshi.JsonAdapter
import com.squareup.moshi.Moshi
import com.squareup.moshi.Types

inline fun <reified T> Moshi.adapter(): JsonAdapter<T> {
  return adapter(T::class.java)
}

inline fun <reified T> Moshi.listTypeAdapter(): JsonAdapter<List<T>> {
  val type = Types.newParameterizedType(List::class.java, T::class.java)
  return adapter(type)
}
