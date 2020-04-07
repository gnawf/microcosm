package com.gnawf.microcosm.app.util

import java.io.File

fun File.child(name: String): File {
  return File(this, name)
}
