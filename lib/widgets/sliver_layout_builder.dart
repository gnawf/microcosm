import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:meta/meta.dart";

typedef Widget LayoutWidgetBuilder(
  BuildContext context,
  SliverConstraints constraints,
);

class SliverLayoutBuilder extends RenderObjectWidget {
  const SliverLayoutBuilder({Key key, @required this.builder})
      : assert(builder != null),
        super(key: key);

  final LayoutWidgetBuilder builder;

  @override
  _LayoutBuilderElement createElement() {
    return new _LayoutBuilderElement(this);
  }

  @override
  _RenderLayoutBuilder createRenderObject(BuildContext context) {
    return new _RenderLayoutBuilder();
  }
}

class _LayoutBuilderElement extends RenderObjectElement {
  _LayoutBuilderElement(SliverLayoutBuilder widget) : super(widget);

  @override
  SliverLayoutBuilder get widget => super.widget;

  @override
  _RenderLayoutBuilder get renderObject => super.renderObject;

  Element _child;

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_child != null) {
      visitor(_child);
    }
  }

  @override
  void forgetChild(Element child) {
    assert(child == _child);
    _child = null;
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    super.mount(parent, newSlot); // Creates the renderObject.
    renderObject.callback = _layout;
  }

  @override
  void update(SliverLayoutBuilder newWidget) {
    assert(widget != newWidget);
    super.update(newWidget);
    assert(widget == newWidget);
    renderObject.callback = _layout;
    renderObject.markNeedsLayout();
  }

  @override
  void performRebuild() {
    // This gets called if markNeedsBuild() is called on us.
    // That might happen if, e.g., our builder uses Inherited widgets.
    renderObject.markNeedsLayout();
    // Calls widget.updateRenderObject (a no-op in this case).
    super.performRebuild();
  }

  @override
  void unmount() {
    renderObject.callback = null;
    super.unmount();
  }

  void _layout(SliverConstraints constraints) {
    owner.buildScope(this, () {
      Widget built;
      if (widget.builder != null) {
        try {
          built = widget.builder(this, constraints);
          debugWidgetBuilderValue(widget, built);
        } catch (e, stack) {
          built = ErrorWidget
              .builder(_debugReportException('building $widget', e, stack));
        }
      }
      try {
        _child = updateChild(_child, built, null);
        assert(_child != null);
      } catch (e, stack) {
        built = ErrorWidget
            .builder(_debugReportException('building $widget', e, stack));
        _child = updateChild(null, built, slot);
      }
    });
  }

  @override
  void insertChildRenderObject(RenderObject child, dynamic slot) {
    final RenderObjectWithChildMixin<RenderObject> renderObject =
        this.renderObject;
    assert(slot == null);
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
    assert(renderObject == this.renderObject);
  }

  @override
  void moveChildRenderObject(RenderObject child, dynamic slot) {
    assert(false);
  }

  @override
  void removeChildRenderObject(RenderObject child) {
    final _RenderLayoutBuilder renderObject = this.renderObject;
    assert(renderObject.child == child);
    renderObject.child = null;
    assert(renderObject == this.renderObject);
  }
}

class _RenderLayoutBuilder extends RenderSliver
    with RenderObjectWithChildMixin<RenderSliver> {
  _RenderLayoutBuilder({
    LayoutCallback<SliverConstraints> callback,
  })
      : _callback = callback;

  LayoutCallback<SliverConstraints> get callback => _callback;
  LayoutCallback<SliverConstraints> _callback;

  set callback(LayoutCallback<SliverConstraints> value) {
    if (value == _callback) {
      return;
    }
    _callback = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = new SliverPhysicalParentData();
    }
  }

  @override
  void performLayout() {
    assert(callback != null);
    invokeLayoutCallback(callback);
    assert(child != null);
    child.layout(constraints, parentUsesSize: true);
    geometry = child.geometry;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    assert(child != null);
    assert(child == this.child);
    final SliverPhysicalParentData childParentData = child.parentData;
    childParentData.applyPaintTransform(transform);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && child.geometry.visible) {
      final SliverPhysicalParentData childParentData = child.parentData;
      context.paintChild(child, offset + childParentData.paintOffset);
    }
  }

  @override
  bool hitTestChildren(HitTestResult result,
      {@required double mainAxisPosition, @required double crossAxisPosition}) {
    if (child != null) {
      return child.hitTest(
        result,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );
    }
    return false;
  }
}

FlutterErrorDetails _debugReportException(
  String context,
  dynamic exception,
  StackTrace stack,
) {
  final FlutterErrorDetails details = new FlutterErrorDetails(
      exception: exception,
      stack: stack,
      library: 'widgets library',
      context: context);
  FlutterError.reportError(details);
  return details;
}
