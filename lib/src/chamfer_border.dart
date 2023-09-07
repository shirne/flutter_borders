// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class BorderChamfer {
  const BorderChamfer({
    bool topLeft = true,
    bool topRight = true,
    bool bottomLeft = true,
    bool bottomRight = true,
  }) : this.custom(
          topLeft: topLeft ? 1 : -1,
          topRight: topRight ? 1 : -1,
          bottomLeft: bottomLeft ? 1 : -1,
          bottomRight: bottomRight ? 1 : -1,
        );

  const BorderChamfer.custom({
    this.topLeft = 1,
    this.topRight = 1,
    this.bottomLeft = 1,
    this.bottomRight = 1,
  });

  const BorderChamfer.only({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) : this(
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        );

  BorderChamfer.vertical({bool top = false, bool bottom = false})
      : this(
          topLeft: top,
          topRight: top,
          bottomLeft: bottom,
          bottomRight: bottom,
        );

  BorderChamfer.horizontal({bool left = false, bool right = false})
      : this(
          topLeft: left,
          topRight: right,
          bottomLeft: left,
          bottomRight: right,
        );

  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  static BorderChamfer lerp(BorderChamfer? a, BorderChamfer? b, double t) =>
      BorderChamfer.custom(
        topLeft: lerpDouble(a?.topLeft, b?.topLeft, t) ?? 0,
        topRight: lerpDouble(a?.topRight, b?.topRight, t) ?? 0,
        bottomLeft: lerpDouble(a?.bottomLeft, b?.bottomLeft, t) ?? 0,
        bottomRight: lerpDouble(a?.bottomRight, b?.bottomRight, t) ?? 0,
      );

  @override
  String toString() => '${objectRuntimeType(this, 'BorderChamfer')}'
      '(topLeft:$topLeft, topRight:$topRight, bottomLeft:$bottomLeft, bottomRight:$bottomRight)';
}

/// A Concave Corner Border
///
/// {@tool snippet}
/// ```dart
/// Widget build(BuildContext context) {
///   return Material(
///     shape: ChamferBorder(
///       borderRadius: BorderRadius.circular(28.0),
///       borderChamfer: BorderChamfer.vertical(top: true),
///     ),
///   );
/// }
/// ```
/// {@end-tool}
class ChamferBorder extends OutlinedBorder {
  /// The arguments must not be null.
  const ChamferBorder({
    super.side,
    this.borderRadius = BorderRadius.zero,
    this.borderChamfer = const BorderChamfer(),
  });

  /// The radius for each corner.
  ///
  /// Negative radius values are clamped to 0.0 by [getInnerPath] and
  /// [getOuterPath].
  final BorderRadiusGeometry borderRadius;

  final BorderChamfer borderChamfer;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) => ChamferBorder(
        side: side.scale(t),
        borderRadius: borderRadius * t,
        borderChamfer: borderChamfer,
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is ChamferBorder) {
      return ChamferBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius: BorderRadiusGeometry.lerp(
          a.borderRadius,
          borderRadius,
          t,
        )!,
        borderChamfer: BorderChamfer.lerp(a.borderChamfer, borderChamfer, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is ChamferBorder) {
      return ChamferBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius: BorderRadiusGeometry.lerp(
          borderRadius,
          b.borderRadius,
          t,
        )!,
        borderChamfer: BorderChamfer.lerp(borderChamfer, b.borderChamfer, t),
      );
    }
    return super.lerpTo(b, t);
  }

  double _clampToShortest(RRect rrect, double value) =>
      value > rrect.shortestSide ? rrect.shortestSide : value;

  Path _getPath(RRect rrect) {
    final double left = rrect.left;
    final double right = rrect.right;
    final double top = rrect.top;
    final double bottom = rrect.bottom;
    //  Radii will be clamped to the value of the shortest side
    // of rrect to avoid strange tie-fighter shapes.
    final double tlRadiusX =
        math.max(0.0, _clampToShortest(rrect, rrect.tlRadiusX));
    final double tlRadiusY =
        math.max(0.0, _clampToShortest(rrect, rrect.tlRadiusY));
    final double trRadiusX =
        math.max(0.0, _clampToShortest(rrect, rrect.trRadiusX));
    final double trRadiusY =
        math.max(0.0, _clampToShortest(rrect, rrect.trRadiusY));
    final double blRadiusX =
        math.max(0.0, _clampToShortest(rrect, rrect.blRadiusX));
    final double blRadiusY =
        math.max(0.0, _clampToShortest(rrect, rrect.blRadiusY));
    final double brRadiusX =
        math.max(0.0, _clampToShortest(rrect, rrect.brRadiusX));
    final double brRadiusY =
        math.max(0.0, _clampToShortest(rrect, rrect.brRadiusY));

    final path = Path()..moveTo(left, top + tlRadiusY);
    if (borderChamfer.topLeft == 0) {
      path.lineTo(left + tlRadiusX, top);
    } else {
      path.arcToPoint(
        Offset(left + tlRadiusX, top),
        radius: Radius.elliptical(
          tlRadiusX / borderChamfer.topLeft.abs(),
          tlRadiusY / borderChamfer.topLeft.abs(),
        ),
        clockwise: borderChamfer.topLeft < 0,
      );
    }
    path.lineTo(right - trRadiusX, top);
    if (borderChamfer.topRight == 0) {
      path.lineTo(right, top + trRadiusY);
    } else {
      path.arcToPoint(
        Offset(right, top + trRadiusY),
        radius: Radius.elliptical(
          trRadiusX / borderChamfer.topRight.abs(),
          trRadiusY / borderChamfer.topRight.abs(),
        ),
        clockwise: borderChamfer.topRight < 0,
      );
    }

    path.lineTo(right, bottom - brRadiusY);

    if (borderChamfer.bottomRight == 0) {
      path.lineTo(right - brRadiusX, bottom);
    } else {
      path.arcToPoint(
        Offset(right - brRadiusX, bottom),
        radius: Radius.elliptical(
          brRadiusX / borderChamfer.bottomRight.abs(),
          brRadiusY / borderChamfer.bottomRight.abs(),
        ),
        clockwise: borderChamfer.bottomRight < 0,
      );
    }

    path.lineTo(left + blRadiusX, bottom);
    if (borderChamfer.bottomLeft == 0) {
      path.lineTo(left, bottom - blRadiusY);
    } else {
      path.arcToPoint(
        Offset(left, bottom - blRadiusY),
        radius: Radius.elliptical(
          blRadiusX / borderChamfer.bottomLeft.abs(),
          blRadiusY / borderChamfer.bottomLeft.abs(),
        ),
        clockwise: borderChamfer.bottomLeft < 0,
      );
    }

    path.close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => _getPath(
        borderRadius.resolve(textDirection).toRRect(rect).deflate(side.width),
      );

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _getPath(borderRadius.resolve(textDirection).toRRect(rect));

  @override
  ChamferBorder copyWith({
    BorderSide? side,
    BorderRadiusGeometry? borderRadius,
    BorderChamfer? borderChamfer,
  }) =>
      ChamferBorder(
        side: side ?? this.side,
        borderRadius: borderRadius ?? this.borderRadius,
        borderChamfer: borderChamfer ?? this.borderChamfer,
      );

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty) {
      return;
    }
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        canvas.drawPath(
          getOuterPath(rect, textDirection: textDirection),
          side.toPaint(),
        );
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ChamferBorder &&
        other.side == side &&
        other.borderChamfer == borderChamfer &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(side, borderRadius, borderChamfer);

  @override
  String toString() => '${objectRuntimeType(this, 'ChamferBorder')}'
      '($side, $borderRadius, $borderChamfer)';
}
