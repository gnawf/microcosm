Current fork is from Flutter commit `e8aa40eddd3b91ba1a2d0c2c1e34db0f38e4290e`

Forked `flutter/src/cupertino/route.dart` to enable global swipe back instead of edge only

Here is a patch for the current changes:

```
@@ -406,6 +406,33 @@ class _CupertinoBackGestureDetector extends StatefulWidget {
       new _CupertinoBackGestureDetectorState();
 }

+/// A horizontal drag gesture detector that delays the recognition of horizontal
+/// drag gestures to allow underlying gesture detectors to snatch up the gesture
+/// before this does.
+///
+/// This is used by the back gesture detector to give priority to the underlying
+/// horizontal scroll views.
+class _HorizontalDragGestureRecognizer extends HorizontalDragGestureRecognizer {
+  _HorizontalDragGestureRecognizer({Object debugOwner})
+      : super(debugOwner: debugOwner);
+
+  bool _rejected = false;
+
+  @override
+  void resolve(GestureDisposition disposition) {
+    // Deny the first attempt to accept the horizontal drag gesture
+    // This allows the child horizontal drag gesture detectors to accept it
+    // This will be invoked again with `accepted` on the next pointer event
+    // So the delay in gesture detection is minuscule but lowers the detection
+    // priority of this gesture detector
+    _rejected = disposition == GestureDisposition.accepted && !_rejected;
+
+    if (!_rejected) {
+      super.resolve(disposition);
+    }
+  }
+}
+
 class _CupertinoBackGestureDetectorState
     extends State<_CupertinoBackGestureDetector> {
   _CupertinoBackGestureController _backGestureController;
@@ -415,7 +442,7 @@ class _CupertinoBackGestureDetectorState
   @override
   void initState() {
     super.initState();
-    _recognizer = new HorizontalDragGestureRecognizer(debugOwner: this)
+    _recognizer = new _HorizontalDragGestureRecognizer(debugOwner: this)
       ..onStart = _handleDragStart
       ..onUpdate = _handleDragUpdate
       ..onEnd = _handleDragEnd
@@ -478,11 +505,10 @@ class _CupertinoBackGestureDetectorState
       fit: StackFit.passthrough,
       children: <Widget>[
         widget.child,
-        new PositionedDirectional(
-          start: 0.0,
-          width: _kBackGestureWidth,
-          top: 0.0,
-          bottom: 0.0,
+        new Container(
+          margin: const EdgeInsets.only(
+            left: _kBackGestureWidth,
+          ),
           child: new Listener(
             onPointerDown: _handlePointerDown,
             behavior: HitTestBehavior.translucent,
```
