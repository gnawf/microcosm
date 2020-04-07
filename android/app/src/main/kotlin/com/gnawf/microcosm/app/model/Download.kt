package com.gnawf.microcosm.app.model

import com.squareup.moshi.JsonClass

@JsonClass(generateAdapter = true)
data class Download(
    val url: String,
    val body: String
)
