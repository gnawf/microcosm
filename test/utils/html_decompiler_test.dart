import "package:app/utils/html_decompiler.dart";
import "package:test/test.dart";

void main() {
  test("it unwraps paragraphs", () {
    final html = """<p>Hello<p>Why</p><div>test</div>Why <p>xD</p></p>""";
    expect(decompile(html), equals("Hello\n\nWhy\n\ntest\n\nWhy\n\nxD"));
  });
}
