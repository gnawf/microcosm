import "dart:async";
import "dart:convert";
import "dart:io";

import "package:app/platform/microcosm.platform.dart" as platform;
import "package:app/sources/database/chapter_dao.dart";
import "package:app/sources/sources.dart";

const _defaultCheckPeriod = const Duration(seconds: 1);

class DownloadsManager {
  DownloadsManager({
    ChapterDao chapterDao,
  })  : assert(chapterDao != null),
        _chapterDao = chapterDao {
    _startTimer();
  }

  final ChapterDao _chapterDao;

  bool _isProcessing = false;

  Timer _timer;

  void check() {
    _startTimer();
  }

  Future<String> downloadUrls(List<String> urls) async {
    final jobId = await platform.downloadUrls(urls);
    _startTimer();
    return jobId;
  }

  void _startTimer([Duration period = _defaultCheckPeriod]) {
    if (_timer?.isActive == true) {
      return;
    }

    _timer = Timer.periodic(period, (timer) async {
      if (!_isProcessing) {
        if (!await platform.hasActiveDownloads()) {
          timer.cancel();
        }

        _process();
      }
    });
  }

  Future<void> _process() async {
    _isProcessing = true;

    try {
      final downloadsDirPath = await platform.getDownloadsDir();
      final downloadsDir = Directory(downloadsDirPath);
      await for (final file in downloadsDir.list()) {
        if (file is File) {
          final content = await file.readAsString();
          final download = jsonDecode(content);
          if (download is Map<String, dynamic>) {
            await _save(download);
          }
        }
        await file.delete();
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _save(Map<String, dynamic> json) async {
    await null;

    final url = Uri.parse(json["url"]);
    final body = json["body"];

    final source = useSource(url: url);
    final chapter = await source.chapters.parseGet(url, body);
    await _chapterDao.upsert(chapter);
    print("Upserted ${chapter.title}");
  }
}
