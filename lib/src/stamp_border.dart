// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class BorderPerforation {
  static const alignInside = -1.0;
  static const alignOutside = 1.0;

  const BorderPerforation.custom({
    this.top = -1,
    this.right = -1,
    this.bottom = -1,
    this.left = -1,
  });

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

  BorderPerforation.vertical({bool inner = true})
      : this(
          right: false,
          left: false,
          inner: inner,
        );

  BorderPerforation.horizontal({bool inner = true})
      : this(
          top: false,
          bottom: false,
          inner: inner,
        );

  final double top;
  final double right;
  final double bottom;
  final double left;

  static BorderPerforation lerp(
      BorderPerforation? a, BorderPerforation? b, double t) {
    return BorderPerforation.custom(
      top: lerpDouble(a?.top, b?.top, t) ?? 0,
      right: lerpDouble(a?.right, b?.right, t) ?? 0,
      bottom: lerpDouble(a?.bottom, b?.bottom, t) ?? 0,
      left: lerpDouble(a?.left, b?.left, t) ?? 0,
    );
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'BorderPerforation')}(top:$top, right:$right, bottom:$bottom, left:$left)';
  }
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
    this.perforations = const BorderPerforation(),
  })  : minGearCount = 0,
        percentSpacing = 0,
        elliptical = 1,
        _mode = _StampBorderMode.size;

  const StampBorder.count({
    super.side,
    this.adjustCenter = true,
    this.minGearCount = 10,
    this.elliptical = 1,
    this.percentSpacing = 0.5,
    this.perforations = const BorderPerforation(),
  })  : gearRadius = Radius.zero,
        spacing = 0,
        _mode = _StampBorderMode.count;

  /// mode
  final _StampBorderMode _mode;

  /// The radius for each gear.
  final Radius gearRadius;

  /// The spacing between gears
  final double spacing;

  /// The gear count of shortest side
  final bool adjustCenter;

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
    return StampBorder(
      side: side.scale(t),
      gearRadius: gearRadius * t,
      perforations: perforations,
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is StampBorder) {
      return StampBorder(
        side: BorderSide.lerp(a.side, side, t),
        gearRadius: Radius.lerp(
          a.gearRadius,
          gearRadius,
          t,
        )!,
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
          adjustCenter: t > 0.5 ? b.adjustCenter : adjustCenter,
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

    final spacing = _mode == _StampBorderMode.size
        ? this.spacing
        : radius.x * percentSpacing;

    double toX = 0, toY = 0;

    final path = Path()..moveTo(left, top);
    if (perforations.top == 0) {
      path.lineTo(right, top);
    } else {
      while (toX < right - radius.x) {
        toX += spacing;
        path.lineTo(toX, toY);
        final topArc = math.pi * perforations.top;

        path.arcTo(
          Rect.fromLTWH(
            toX,
            toY + radius.y * perforations.top.clamp(0, 1),
            radius.x * 2,
            toY + radius.y * perforations.top.clamp(-1, 0),
          ),
          -math.pi,
          topArc,
          true,
        );

        toX += radius.x * 2;
      }
      toX = right;
      path.lineTo(right, top);
    }

    if (perforations.right == 0) {
      path.lineTo(right, bottom);
    } else {
      while (toY < bottom - radius.x) {
        toY += spacing;
        path.lineTo(toX, toY);
        final rightArc = math.pi * perforations.right;

        path.arcTo(
          Rect.fromLTWH(
            toX + radius.y * perforations.top.clamp(-1, 0),
            toY,
            toX + radius.y * perforations.top.clamp(0, 1),
            toY + radius.x * 2,
          ),
          -math.pi / 2,
          rightArc,
          true,
        );

        toX += radius.x * 2;
      }
      toY = bottom;

      path.lineTo(right, bottom);
    }

    if (perforations.bottom == 0) {
      path.lineTo(left, bottom);
    } else {
      while (toX > left + radius.x) {
        toX -= spacing;
        path.lineTo(toX, toY);
        final bottomArc = math.pi * perforations.bottom;

        path.arcTo(
          Rect.fromLTWH(
            radius.x * 2,
            toY + radius.y * perforations.bottom.clamp(-1, 0),
            toX,
            toY + radius.y * perforations.bottom.clamp(0, 1),
          ),
          0,
          bottomArc,
          true,
        );

        toX -= radius.x * 2;
      }
      toX = left;

      path.lineTo(left, bottom);
    }

    if (perforations.left == 0) {
      path.lineTo(left, top);
    } else {
      while (toY > top + radius.x) {
        toY -= spacing;
        path.lineTo(toX, toY);
        final leftArc = math.pi * perforations.left;

        path.arcTo(
          Rect.fromLTWH(
            toX + radius.y * perforations.left.clamp(0, 1),
            toY + radius.x * 2,
            toX + radius.y * perforations.left.clamp(-1, 0),
            toY,
          ),
          math.pi / 2,
          leftArc,
          true,
        );

        toX -= radius.x * 2;
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
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _getPath(rect);
  }

  Radius _getRadius(Rect rect) {
    Radius radius;
    if (_mode == _StampBorderMode.size) {
      radius = gearRadius;
    } else {
      final rx = (rect.shortestSide / minGearCount) / (1 + percentSpacing);
      if (elliptical == 1) {
        radius = Radius.circular(rx);
      } else {
        radius = Radius.elliptical(rx, rx * elliptical);
      }
    }

    if (adjustCenter) {
      // TODO(shirne) adjust radius to adapter rect
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
        adjustCenter: adjustCenter ?? this.adjustCenter,
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
        perforations,
      );

  @override
  String toString() {
    return '${objectRuntimeType(this, 'StampBorder')}($side, $_mode, $gearRadius, $spacing, $minGearCount, $elliptical, $percentSpacing, $adjustCenter,$perforations)';
  }
}
