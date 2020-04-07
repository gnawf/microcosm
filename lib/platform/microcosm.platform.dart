import "package:flutter/services.dart";

const _platform = const MethodChannel("microcosm");

Future<bool> hasActiveDownloads() {
  try {
    return _platform.invokeMethod("hasActiveDownloads");
  } on PlatformException catch (e, s) {
    print(e);
    print(s);
    rethrow;
  }
}

Future<Map<String, dynamic>> getDownloadProgress(String id) {
  try {
    return _platform.invokeMethod("getDownloadProgress", id);
  } on PlatformException catch (e, s) {
    print(e);
    print(s);
    rethrow;
  }
}

Future<String> getDownloadsDir() {
  try {
    return _platform.invokeMethod("getDownloadsDir");
  } on PlatformException catch (e, s) {
    print(e);
    print(s);
    rethrow;
  }
}

/// Starts a download job to fetch all of the URLs, returns the job id
Future<String> downloadUrls(List<String> urls) async {
  try {
    return await _platform.invokeMethod("downloadUrls", {"urls": urls});
  } on PlatformException catch (e, s) {
    print(e);
    print(s);
    rethrow;
  }
}
