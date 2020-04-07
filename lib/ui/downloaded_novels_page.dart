import "package:app/hooks/use_daos.hook.dart";
import "package:app/models/novel.dart";
import "package:app/resource/paginated_resource.dart";
import "package:app/resource/resource.hooks.dart";
import "package:app/sources/sources.dart";
import "package:app/ui/router.hooks.dart";
import "package:app/widgets/image_view.dart";
import "package:app/widgets/resource_builder.dart";
import "package:app/widgets/settings_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

part "downloaded_novels_page.hooks.dart";

class DownloadedNovelsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: const Text("Downloads"),
        centerTitle: false,
        actions: const [
          SettingsIconButton(),
        ],
      ),
      body: _Body(),
    );
  }
}

class _Body extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final novels = _useDownloadedNovels();

    return ResourceBuilder(
      resource: novels,
      doneBuilder: (BuildContext context, List<Novel> novels) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
          ),
          itemBuilder: (BuildContext context, int index) {
            return _NovelListTile(novel: novels[index]);
          },
          itemCount: novels.length,
        );
      },
    );
  }
}

class _NovelListTile extends HookWidget {
  _NovelListTile({
    Key key,
    @required this.novel,
  })  : assert(novel != null),
        super(key: key);

  final Novel novel;

  @override
  Widget build(BuildContext context) {
    final router = useRouter();
    final source = useSource(id: novel.source);

    return ListTile(
      onTap: () {
        router.push().downloadedChapters(novel.source, novel.slug);
      },
      leading: Container(
        constraints: const BoxConstraints(
          maxWidth: 40.0,
          maxHeight: 60.0,
        ),
        child: ImageView(
          image: novel?.posterImage,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(novel.name),
      subtitle: Text(source.name),
    );
  }
}
