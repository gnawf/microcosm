import "package:app/utils/html_decompiler.dart";
import "package:test/test.dart";

void main() {
  // Zero width joiner character
  final zwj = new String.fromCharCode(8205);

  test("it unwraps paragraphs", () {
    final html = """<p>Hello<p>Why</p><div>test</div>Why <p>xD</p></p>""";
    expect(decompile(html), equals("Hello\n\nWhy\n\ntest\n\nWhy\n\nxD"));
  });
  test("it decompiles anchors", () {
    final html = """<a href="xd">test</a>""";
    expect(decompile(html), equals("[test](xd)"));
  });
  test("it decompiles break line elements", () {
    final html = """hello<br/>test""";
    expect(decompile(html), equals("hello\n\ntest"));
  });
  test("it decompiles italic text", () {
    final html = """hello<em>there</em>test""";
    expect(decompile(html), equals("hello${zwj}_there_${zwj}test"));
  });
  test("it decompiles bold text", () {
    final html = """<strong>xd</strong>""";
    expect(decompile(html), equals("${zwj}__xd__$zwj"));
  });
  test("it decompiles nested formatting", () {
    final html = """<strong><span>xd 2</span></strong>""";
    expect(decompile(html), equals("${zwj}__xd 2__$zwj"));
  });
  test("it decompiles ordered lists", () {
    final html = """hello<ol><li>hello</li><li>there</li></ol>test""";
    expect(decompile(html), equals("hello\n\n1. hello2. there\n\ntest"));
  });
  test("it decompiles unordered lists", () {
    final html = """hello<ul><li>hello</li><li>there</li></ul>test""";
    expect(decompile(html), equals("hello\n\n* hello* there\n\ntest"));
  });
  test("it removes consecutive spaces", () {
    final html = """<p>hello there     my name is</p>""";
    expect(decompile(html), equals("hello there my name is"));
  });
  test("trim ignores formatting", () {
    final html = """<p><em>  hello there</em>     my name is</p>""";
    expect(decompile(html), equals("${zwj}_hello there_$zwj my name is"));
  });
  test("decompiles anchors with multiline text", () {
    final html = """<a href="/test">
Previous Chapter
</a>""";
    expect(decompile(html), equals("[Previous Chapter](/test)"));
  });
  test("resolves relative urls", () {
    final html = """<a href="/test">
Previous Chapter
</a>""";
    final url = new Uri(scheme: "https", host: "test.com");
    expect(
      decompile(html, url),
      equals("[Previous Chapter](https://test.com/test)"),
    );
  });
}
