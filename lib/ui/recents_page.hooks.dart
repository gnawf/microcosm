part of "recents_page.dart";

Resource<List<Chapter>> _useRecents() {
  final recents = useResource<List<Chapter>>();
  final dao = useChapterDao();

  useEffect(() {
    dao.recents().then((value) {
      recents.value = Resource.data(value);
    }).catchError((error, stacktrace) {
      recents.value = Resource.error(error);
      print(error);
      print(stacktrace);
    });

    return () {};
  }, []);

  return recents.value;
}

Resource<Chapter> _useChapter(Chapter chapter) {
  final resource = useResource<Chapter>();
  final novel = useNovel(chapter.novelSource, chapter.novelSlug);

  useEffect(() {
    print(novel.data);
    resource.value = Resource.data(chapter.copyWith(novel: novel.data));
    return () {};
  }, [novel.state]);

  return resource.value;
}

VoidCallback _useOpenRecent(Chapter chapter) {
  final router = useRouter();

  return () {
    router.push().reader(url: chapter.url);
  };
}
