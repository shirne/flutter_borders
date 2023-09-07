// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class BorderPerforation {
  const BorderPerforation({
    bool top = true,
    bool right = true,
    bool bottom = true,
    bool left = true,
    bool inner = true,
  }) : this.custom(
          top: top
              ? inner
                  ? alignInside
                  : alignOutside
              : 0,
          right: right
              ? inner
                  ? alignInside
                  : alignOutside
              : 0,
          bottom: bottom
              ? inner
                  ? alignInside
                  : alignOutside
              : 0,
          left: left
              ? inner
                  ? alignInside
                  : alignOutside
              : 0,
        );

  const BorderPerforation.custom({
    this.top = -1,
    this.right = -1,
    this.bottom = -1,
    this.left = -1,
  });

  const BorderPerforation.only({
    bool top = false,
    bool right = false,
    bool bottom = false,
    bool left = false,
    bool inner = true,
  }) : this(
          top: top,
          right: right,
          bottom: bottom,
          left: left,
          inner: inner,
        );

  const BorderPerforation.vertical({bool inner = true})
      : this(
          right: false,
          left: false,
          inner: inner,
        );

  const BorderPerforation.horizontal({bool inner = true})
      : this(
          top: false,
          bottom: false,
          inner: inner,
        );
  static const alignInside = -1.0;
  static const alignOutside = 1.0;

  final double top;
  final double right;
  final double bottom;
  final double left;

  static BorderPerforation lerp(
    BorderPerforation? a,
    BorderPerforation? b,
    double t,
  ) =>
      BorderPerforation.custom(
        top: lerpDouble(a?.top, b?.top, t) ?? 0,
        right: lerpDouble(a?.right, b?.right, t) ?? 0,
        bottom: lerpDouble(a?.bottom, b?.bottom, t) ?? 0,
        left: lerpDouble(a?.left, b?.left, t) ?? 0,
      );

  @override
  String toString() => '${objectRuntimeType(this, 'BorderPerforation')}'
      '(top:$top, right:$right, bottom:$bottom, left:$left)';
}

enum _StampBorderMode {
  size,
  count,
}

/// rectangular toothed border, similar to the border of a stamp
///
/// {@tool snippet}
/// ```dart
/// Widget build(BuildContext context) {
///   return Material(
///     shape: StampBorder(
///       gearRadius: Radius.circular(5.0),
///       perforations: BorderPerforation.only(top: true),
///     ),
///   );
/// }
/// ```
/// {@end-tool}
class StampBorder extends OutlinedBorder {
  /// The arguments must not be null.
  const StampBorder({
    super.side,
    this.gearRadius = const Radius.circular(5),
    this.spacing = 5,
    this.adjustCenter = true,
    this.adjustSpacing = true,
    this.perforations = const BorderPerforation(),
  })  : minGearCount = 0,
        percentSpacing = 0,
        elliptical = 1,
        _mode = _StampBorderMode.size;

  const StampBorder.count({
    super.side,
    this.minGearCount = 10,
    this.elliptical = 1,
    this.percentSpacing = 0.5,
    this.perforations = const BorderPerforation(),
  })  : gearRadius = Radius.zero,
        spacing = 0,
        adjustSpacing = false,
        adjustCenter = false,
        _mode = _StampBorderMode.count;

  /// mode
  final _StampBorderMode _mode;

  /// The radius for each gear.
  final Radius gearRadius;

  /// The spacing between gears
  final double spacing;

  /// Auto adjust begining spacing and end spacing at a side
  final bool adjustCenter;

  /// Auto adjust spacing to fit size
  final bool adjustSpacing;

  /// The gear count of shortest side
  final int minGearCount;

  final double elliptical;

  /// The spacing between gears
  final double percentSpacing;

  /// specify which borders should apply the rectangular toothed attribute
  final BorderPerforation perforations;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) {
    if (_mode == _StampBorderMode.count) {
      return StampBorder.count(
        side: side.scale(t),
        minGearCount: minGearCount,
        elliptical: elliptical,
        percentSpacing: percentSpacing,
        perforations: perforations,
      );
    }
    return StampBorder(
      side: side.scale(t),
      gearRadius: gearRadius * t,
      spacing: spacing * t,
      adjustCenter: adjustCenter,
      adjustSpacing: adjustSpacing,
      perforations: perforations,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is StampBorder) {
      final mode = t > 0.5 ? _mode : a._mode;
      if (mode == _StampBorderMode.count) {
        return StampBorder.count(
          side: BorderSide.lerp(a.side, side, t),
          minGearCount:
              lerpDouble(a.minGearCount.toDouble(), minGearCount.toDouble(), t)!
                  .round(),
          elliptical: lerpDouble(a.elliptical, elliptical, t)!,
          percentSpacing: lerpDouble(a.percentSpacing, percentSpacing, t)!,
          perforations: BorderPerforation.lerp(a.perforations, perforations, t),
        );
      }
      return StampBorder(
        side: BorderSide.lerp(a.side, side, t),
        gearRadius: Radius.lerp(
          a.gearRadius,
          gearRadius,
          t,
        )!,
        spacing: lerpDouble(a.spacing, spacing, t)!,
        adjustCenter: t > 0.5 ? adjustCenter : a.adjustCenter,
        adjustSpacing: t > 0.5 ? adjustSpacing : a.adjustSpacing,
        perforations: BorderPerforation.lerp(a.perforations, perforations, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is StampBorder) {
      final mode = t > 0.5 ? b._mode : _mode;
      if (mode == _StampBorderMode.count) {
        return StampBorder.count(
          side: BorderSide.lerp(side, b.side, t),
          minGearCount:
              lerpDouble(minGearCount.toDouble(), b.minGearCount.toDouble(), t)!
                  .round(),
          elliptical: lerpDouble(elliptical, b.elliptical, t)!,
          percentSpacing: lerpDouble(percentSpacing, b.percentSpacing, t)!,
          perforations: BorderPerforation.lerp(perforations, b.perforations, t),
        );
      }
      return StampBorder(
        side: BorderSide.lerp(side, b.side, t),
        gearRadius: Radius.lerp(
          gearRadius,
          b.gearRadius,
          t,
        )!,
        spacing: lerpDouble(spacing, b.spacing, t)!,
        adjustCenter: t > 0.5 ? b.adjustCenter : adjustCenter,
        adjustSpacing: t > 0.5 ? b.adjustSpacing : adjustSpacing,
        perforations: BorderPerforation.lerp(perforations, b.perforations, t),
      );
    }
    return super.lerpTo(b, t);
  }

  Path _getPath(Rect rect, {TextDirection? textDirection}) {
    final double left = rect.left;
    final double right = rect.right;
    final double top = rect.top;
    final double bottom = rect.bottom;

    final radius = _getRadius(rect);

    double spacing = _mode == _StampBorderMode.size
        ? this.spacing
        : radius.x * percentSpacing;

    double toX = rect.left, toY = rect.top;
    double vOffset = 0, hOffset = 0;

    if (_mode == _StampBorderMode.count) {
      vOffset = spacing;
      hOffset = spacing;
    } else {
      double oneEm = spacing + radius.x * 2;
      final vCount = (rect.height - spacing) ~/ oneEm;
      final hCount = (rect.width - spacing) ~/ oneEm;
      if (adjustSpacing) {
        final hs = (rect.width - hCount * oneEm - spacing) / (hCount + 1);
        final vs = (rect.height - vCount * oneEm - spacing) / (vCount + 1);
        spacing += math.min(hs, vs);
      }

      if (adjustCenter) {
        oneEm = spacing + radius.x * 2;
        vOffset = (rect.height - vCount * oneEm - spacing) / 2;
        hOffset = (rect.width - hCount * oneEm - spacing) / 2;
      }
    }

    if (adjustCenter || _mode == _StampBorderMode.count) {
      final oneEm = spacing + radius.x * 2;
      final vCount = (rect.height - spacing) ~/ oneEm;
      final hCount = (rect.width - spacing) ~/ oneEm;
      vOffset = (rect.height - vCount * oneEm - spacing) / 2;
      hOffset = (rect.width - hCount * oneEm - spacing) / 2;
    }

    final path = Path()..moveTo(left, top);
    if (perforations.top == 0) {
      path.lineTo(right, top);
    } else {
      toX += hOffset;
      final topRadius = radius / perforations.top.abs();
      while (toX < right - radius.x - spacing) {
        toX += spacing;
        path.lineTo(toX, toY);

        toX += radius.x * 2;
        path.arcToPoint(
          Offset(toX, toY),
          radius: topRadius,
          clockwise: perforations.top > 0 ? true : false,
        );
      }

      path.lineTo(right, top);
    }
    toX = right;

    if (perforations.right == 0) {
      path.lineTo(right, bottom);
    } else {
      toY += vOffset;
      final rightRadius = radius / perforations.right.abs();

      while (toY < bottom - radius.x - spacing) {
        toY += spacing;
        path.lineTo(toX, toY);

        toY += radius.x * 2;
        path.arcToPoint(
          Offset(toX, toY),
          radius: rightRadius,
          clockwise: perforations.right > 0 ? true : false,
        );
      }

      path.lineTo(right, bottom);
    }
    toY = bottom;

    if (perforations.bottom == 0) {
      path.lineTo(left, bottom);
    } else {
      toX -= hOffset;
      final bottomRadius = radius / perforations.bottom.abs();
      while (toX > left + radius.x + spacing) {
        toX -= spacing;
        path.lineTo(toX, toY);

        toX -= radius.x * 2;
        path.arcToPoint(
          Offset(toX, toY),
          radius: bottomRadius,
          clockwise: perforations.bottom > 0 ? true : false,
        );
      }

      path.lineTo(left, bottom);
    }
    toX = left;

    if (perforations.left == 0) {
      path.lineTo(left, top);
    } else {
      toY -= vOffset;
      final leftRadius = radius / perforations.left.abs();
      while (toY > top + radius.x + spacing) {
        toY -= spacing;
        path.lineTo(toX, toY);

        toY -= radius.x * 2;
        path.arcToPoint(
          Offset(toX, toY),
          radius: leftRadius,
          clockwise: perforations.left > 0 ? true : false,
        );
      }
    }

    path.close();
    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final trans = Matrix4.identity()..translate(side.strokeInset);
    final path = _getPath(rect, textDirection: textDirection)
      ..transform(trans.storage);
    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _getPath(rect);

  Radius _getRadius(Rect rect) {
    Radius radius;
    if (_mode == _StampBorderMode.size) {
      radius = gearRadius;
    } else {
      final rx = rect.shortestSide /
          (minGearCount * 2 + percentSpacing * (minGearCount + 1));
      if (elliptical == 1) {
        radius = Radius.circular(rx);
      } else {
        radius = Radius.elliptical(rx, rx * elliptical);
      }
    }

    return radius;
  }

  @override
  StampBorder copyWith({
    BorderSide? side,
    Radius? gearRadius,
    double? spacing,
    int? minGearCount,
    double? elliptical,
    double? percentSpacing,
    bool? adjustCenter,
    bool? adjustSpacing,
    BorderPerforation? perforations,
  }) {
    if (_mode == _StampBorderMode.count) {
      assert(
        gearRadius == null && spacing == null,
        'StampBorder count mode can\'t copy to size mode',
      );
      return StampBorder.count(
        side: side ?? this.side,
        minGearCount: minGearCount ?? this.minGearCount,
        elliptical: elliptical ?? this.elliptical,
        percentSpacing: percentSpacing ?? this.percentSpacing,
        perforations: perforations ?? this.perforations,
      );
    }
    assert(
      minGearCount == null && percentSpacing == null && elliptical == null,
      'StampBorder size mode can\'t copy to count mode',
    );
    return StampBorder(
      side: side ?? this.side,
      gearRadius: gearRadius ?? this.gearRadius,
      spacing: spacing ?? this.spacing,
      adjustCenter: adjustCenter ?? this.adjustCenter,
      adjustSpacing: adjustSpacing ?? this.adjustSpacing,
      perforations: perforations ?? this.perforations,
    );
  }

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
    return other is StampBorder &&
        other.side == side &&
        other._mode == _mode &&
        other.gearRadius == gearRadius &&
        other.spacing == spacing &&
        other.minGearCount == minGearCount &&
        other.elliptical == elliptical &&
        other.percentSpacing == percentSpacing &&
        other.adjustCenter == adjustCenter &&
        other.adjustSpacing == adjustSpacing &&
        other.perforations == perforations;
  }

  @override
  int get hashCode => Object.hash(
        side,
        _mode,
        gearRadius,
        spacing,
        minGearCount,
        elliptical,
        percentSpacing,
        adjustCenter,
        adjustSpacing,
        perforations,
      );

  @override
  String toString() => '${objectRuntimeType(this, 'StampBorder')}'
      '($side, $_mode, $gearRadius, $spacing, $minGearCount,'
      ' $elliptical, $percentSpacing, $adjustCenter, $adjustSpacing, $perforations)';
}
