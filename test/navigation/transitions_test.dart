import "package:app/navigation/transitions.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  testWidgets("swipe back gesture is global", (tester) async {
    await tester.pumpWidget(
      new MaterialApp(
        onGenerateRoute: (RouteSettings settings) {
          return new CupertinoPageRoute(
            builder: (BuildContext context) => const Scaffold(),
          );
        },
      ),
    );

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    navigator.pushNamed("child");

    await tester.pump(); // start transition animation
    await tester.pump(const Duration(seconds: 1)); // end transition animation

    expect(navigator.canPop(), isTrue);

    // Drag from the center of the screen
    final center = tester.getCenter(find.byType(MaterialApp));
    await tester.dragFrom(
      new Offset(center.dx - 10.0, 0.0),
      new Offset(center.dx + 10.0, 0.0),
    );

    await tester.pump(); // start fling animation
    await tester.pump(const Duration(seconds: 1)); // end fling animation

    expect(navigator.canPop(), isFalse);
  });

  testWidgets("can access drawer", (tester) async {
    await tester.pumpWidget(
      new MaterialApp(
        onGenerateRoute: (RouteSettings settings) {
          return new CupertinoPageRoute(
            builder: (BuildContext context) => const Scaffold(
                  drawer: const Drawer(),
                ),
          );
        },
      ),
    );

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    navigator.pushNamed("child");

    await tester.pump(); // start transition animation
    await tester.pump(const Duration(seconds: 1)); // end transition animation

    expect(find.byType(Drawer), findsNothing);

    // Drag from the left to open the drawer
    final center = tester.getCenter(find.byType(MaterialApp));
    final centerLeft = new Offset(0.0, center.dy);
    await tester.dragFrom(centerLeft, const Offset(100.0, 0.0));

    await tester.pump();

    expect(find.byType(Drawer), findsOneWidget);
  });

  testWidgets("lets horizontal scroll views scroll", (tester) async {
    final scrollController = new ScrollController();

    await tester.pumpWidget(
      new MaterialApp(
        onGenerateRoute: (RouteSettings settings) {
          return new CupertinoPageRoute(
            builder: (BuildContext context) => settings.name == "child"
                ? new Scaffold(
                    body: new ListView(
                      scrollDirection: Axis.horizontal,
                      children: new List.filled(100, null)
                          .map((e) => new Container(width: 100.0))
                          .toList(),
                      controller: scrollController,
                    ),
                  )
                : const Scaffold(),
          );
        },
      ),
    );

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));

    expect(navigator.canPop(), isFalse);

    navigator.pushNamed("child");

    await tester.pump(); // start transition animation
    await tester.pump(const Duration(seconds: 1)); // end transition animation

    expect(scrollController.offset, isZero);

    // Drag to scroll horizontally
    await tester.drag(find.byType(ListView), const Offset(-50.0, 0.0));

    await tester.pump(); // start fling animation
    await tester.pump(const Duration(seconds: 1)); // end fling animation

    expect(navigator.canPop(), isTrue);
    expect(scrollController.offset, isNonZero);
  });
}
