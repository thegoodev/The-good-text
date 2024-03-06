import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ParentData extends ContainerBoxParentData<RenderBox> {

}

class OverFlow extends MultiChildRenderObjectWidget {

  OverFlow({
    Key key,
    this.tolerance = 0.0,
    @required this.canvasColor,
    this.clipBehavior = Clip.hardEdge,
    this.suggested = double.infinity,
    List<Widget> children = const <Widget>[],
  }) : assert(tolerance >= 0 && tolerance <= 1),
      super(key: key, children: children);

  final double suggested;

  final double tolerance;

  final Color canvasColor;

  /// {@macro flutter.widgets.Clip}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  @override
  Renderer createRenderObject(BuildContext context) {
    return Renderer(
      suggested: suggested,
      tolerance: tolerance,
      canvasColor: canvasColor,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, Renderer renderObject) {
    renderObject
      ..suggested = suggested
      ..tolerance = tolerance
      ..canvasColor = canvasColor
      ..clipBehavior = clipBehavior;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<Clip>('clipBehavior', clipBehavior, defaultValue: Clip.hardEdge));
  }
}



class Renderer extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, ParentData>,
         RenderBoxContainerDefaultsMixin<RenderBox, ParentData> {
  /// Creates a stack render object.
  ///
  /// By default, the non-positioned children of the stack are aligned by their
  /// top left corners.
  Renderer({
    this.suggested,
    Color canvasColor,
    double tolerance,
    List<RenderBox> children,
    Clip clipBehavior = Clip.hardEdge,
  }) :
       _tolerance = tolerance,
       _canvasColor = canvasColor,
       _clipBehavior = clipBehavior {
    addAll(children);
  }

  double suggested;

  bool _hasOverflow = false;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ParentData)
      child.parentData = ParentData();
  }

  /// {@macro flutter.widgets.Clip}
  ///
  /// Defaults to [Clip.hardEdge], and must not be null.
  Clip get clipBehavior => _clipBehavior;
  Clip _clipBehavior = Clip.hardEdge;
  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  double get tolerance => _tolerance;
  double _tolerance = 0;
  set tolerance(double value){
    assert(value >= 0 && value <= 1);
    if(value != _tolerance){
      _tolerance = value;
      markNeedsPaint();
      markNeedsLayout();
      markNeedsSemanticsUpdate();
    }
  }

  Color get canvasColor => _canvasColor;
  Color _canvasColor;
  set canvasColor(Color color){
    if(color != _canvasColor){
      _canvasColor = color;
      markNeedsPaint();
      markNeedsLayout();
    }
  }

  /// Helper function for calculating the intrinsics metrics of a Stack.
  static double getIntrinsicDimension(RenderBox firstChild, double mainChildSizeGetter(RenderBox child)) {
    double extent = 0.0;
    RenderBox child = firstChild;
    while (child != null) {
      final ParentData childParentData = child.parentData as ParentData;
      extent = math.max(extent, mainChildSizeGetter(child));
      assert(child.parentData == childParentData);
      child = childParentData.nextSibling;
    }
    return extent;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMinIntrinsicWidth(height));
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMaxIntrinsicWidth(height));
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return getIntrinsicDimension(firstChild, (RenderBox child) => child.getMaxIntrinsicHeight(width));
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  void performLayout() {
    BoxConstraints constraints = this.constraints;
    double maxHeight = constraints.maxHeight;
    double allocatedHeight = 0.0;
    double breakpoint = math.min(suggested, maxHeight);

    bool stop = false;
    int drawnChildren = 0;
    RenderBox child = firstChild;

    while (child != null) {
      final ParentData childParentData = child.parentData;

      /*
      double width = constraints.maxWidth;
      double maxChildHeight = child.getMaxIntrinsicHeight(width);
      double minChildHeight = child.getMinIntrinsicHeight(width);
      */

      child.layout(constraints, parentUsesSize: true);
      childParentData.offset = Offset(0, allocatedHeight);
      drawnChildren++;
      allocatedHeight += child.size.height;
      stop = allocatedHeight>breakpoint;
      if(stop){
        break;
      }
      child = childParentData.nextSibling;
    }

    _hasOverflow = (allocatedHeight>constraints.maxHeight) || (drawnChildren < childCount);

    allocatedHeight = math.min(allocatedHeight, breakpoint*(1+tolerance));
    
    size = Size(constraints.biggest.width, math.min(allocatedHeight, maxHeight));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { Offset position }) {
    // The x, y parameters have the top left of the node's box as the origin.
    RenderBox child = lastChild;
    while (child != null) {
      final ParentData childParentData = child.parentData as ParentData;
      if(child.hasSize){
        final bool isHit = result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - childParentData.offset);
            return child.hitTest(result, position: transformed);
          },
        );
        if (isHit)
          return true;
      }
      child = childParentData.previousSibling;
    }
    return false;
  }


  @override
  void paint(PaintingContext context, Offset offset) {
    //defaultPaint(context, offset);
    if (clipBehavior != Clip.none && _hasOverflow) {
      context.pushClipRect(needsCompositing, offset, Offset.zero & size, defaultPaint, clipBehavior: clipBehavior);
      double height = 24;
      Rect rect = Offset(offset.dx,offset.dy+size.height-height) & Size(size.width, height);
      LinearGradient gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_canvasColor.withOpacity(0), _canvasColor], 
        stops: [0.0, 1]
      );
      context.canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    } else {
      defaultPaint(context, offset);
    }
  }

  @override
  Rect describeApproximatePaintClip(RenderObject child) => _hasOverflow ? Offset.zero & size : null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<Clip>('clipBehavior', clipBehavior, defaultValue: Clip.hardEdge));
  }
}