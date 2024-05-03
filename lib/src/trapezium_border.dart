import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The offset of each vertex, with positive numbers offsetting
/// outward and negative numbers offsetting inward
class BorderOffset {
  const BorderOffset({
    this.topLeft = Offset.zero,
    this.topRight = Offset.zero,
    this.bottomLeft = Offset.zero,
    this.bottomRight = Offset.zero,
  });

  const BorderOffset.all(
    Offset offset,
  ) : this(
          topLeft: offset,
          topRight: offset,
          bottomLeft: offset,
          bottomRight: offset,
        );
  const BorderOffset.diagonal({
    Offset tlbr = Offset.zero,
    Offset trbl = Offset.zero,
  }) : this(
          topLeft: tlbr,
          topRight: trbl,
          bottomLeft: trbl,
          bottomRight: tlbr,
        );

  const BorderOffset.horizontal({
    Offset left = Offset.zero,
    Offset right = Offset.zero,
  }) : this(
          topLeft: left,
          topRight: right,
          bottomLeft: left,
          bottomRight: right,
        );

  const BorderOffset.vertical({
    Offset top = Offset.zero,
    Offset bottom = Offset.zero,
  }) : this(
          topLeft: top,
          topRight: top,
          bottomLeft: bottom,
          bottomRight: bottom,
        );

  final Offset topLeft;
  final Offset topRight;
  final Offset bottomLeft;
  final Offset bottomRight;

  BorderOffset scale(double t) => BorderOffset(
        topLeft: topLeft * t,
        topRight: topRight * t,
        bottomLeft: bottomLeft * t,
        bottomRight: bottomRight * t,
      );

  @override
  String toString() => '${objectRuntimeType(this, 'BorderOffset')}'
      '(topLeft:$topLeft, topRight:$topRight, bottomLeft:$bottomLeft, bottomRight:$bottomRight)';

  static BorderOffset lerp(BorderOffset? a, BorderOffset? b, double t) =>
      BorderOffset(
        topLeft: Offset.lerp(a?.topLeft, b?.topLeft, t) ?? Offset.zero,
        topRight: Offset.lerp(a?.topRight, b?.topRight, t) ?? Offset.zero,
        bottomLeft: Offset.lerp(a?.bottomLeft, b?.bottomLeft, t) ?? Offset.zero,
        bottomRight:
            Offset.lerp(a?.bottomRight, b?.bottomRight, t) ?? Offset.zero,
      );
}

/// Irregular quadrilateral border, such as trapezoid,prisms
///
/// {@tool snippet}
/// ```dart
/// Widget build(BuildContext context) {
///   return Material(
///     shape: TrapeziumBorder(
///       borderRadius: BorderRadius.circular(28.0),
///       borderChamfer: BorderChamfer.vertical(top: Offset(-10, 0)),
///     ),
///   );
/// }
/// ```
/// {@end-tool}
class TrapeziumBorder extends OutlinedBorder {
  const TrapeziumBorder({
    this.borderOffset = const BorderOffset(),
    this.borderRadius = BorderRadius.zero,
    super.side,
  });

  final BorderOffset borderOffset;
  final BorderRadiusGeometry borderRadius;

  @override
  TrapeziumBorder copyWith({BorderSide? side, BorderOffset? borderOffset}) =>
      TrapeziumBorder(
        borderOffset: borderOffset ?? this.borderOffset,
        side: side ?? this.side,
      );

  Path _getPath(Rect rect, {TextDirection? textDirection}) {
    final br = borderRadius.resolve(textDirection);
    final tlRadius = br.topLeft.clamp(minimum: Radius.zero);
    final trRadius = br.topRight.clamp(minimum: Radius.zero);
    final brRadius = br.bottomRight.clamp(minimum: Radius.zero);
    final blRadius = br.bottomLeft.clamp(minimum: Radius.zero);

    final topLeft = Offset(
      rect.left - borderOffset.topLeft.dx,
      rect.top - borderOffset.topLeft.dy,
    );
    final topRight = Offset(
      rect.right + borderOffset.topRight.dx,
      rect.top - borderOffset.topRight.dy,
    );
    final bottomRight = Offset(
      rect.right + borderOffset.bottomRight.dx,
      rect.bottom + borderOffset.bottomRight.dy,
    );
    final bottomLeft = Offset(
      rect.left - borderOffset.bottomLeft.dx,
      rect.bottom + borderOffset.bottomLeft.dy,
    );
    print(rect);
    print('$topLeft, $topRight, $bottomRight, $bottomLeft');
    final tSlope = (topRight.dy - topLeft.dy) / (topRight.dx - topLeft.dx);
    final rSlope =
        (topRight.dy - bottomRight.dy) / (topRight.dx - bottomRight.dx);
    final bSlope =
        (bottomRight.dy - bottomLeft.dy) / (bottomRight.dx - bottomLeft.dx);
    final lSlope = (topLeft.dy - bottomLeft.dy) / (topLeft.dx - bottomLeft.dx);

    print('$tSlope, $rSlope, $bSlope, $lSlope');

    final path = Path();

    if (tlRadius == Radius.zero || tSlope == lSlope) {
      path.moveTo(topLeft.dx, topLeft.dy);
    } else {
      final ptl = getPoints(
        tlRadius.x,
        tlRadius.y,
        topLeft.dx,
        topLeft.dy,
        lSlope,
        tSlope,
        Alignment.bottomRight,
      );
      print('topLeft: $ptl');
      path.moveTo(ptl.stop.dx, ptl.stop.dy);
      path.arcToPoint(ptl.start, radius: tlRadius, largeArc: ptl.isLarge);
    }

    if (trRadius == Radius.zero || tSlope == rSlope) {
      path.lineTo(topRight.dx, topRight.dy);
    } else {
      final ptr = getPoints(
        trRadius.x,
        trRadius.y,
        topRight.dx,
        topRight.dy,
        rSlope,
        tSlope,
        Alignment.bottomLeft,
      );
      print('topRight: $ptr');
      path.lineTo(ptr.start.dx, ptr.start.dy);
      path.arcToPoint(ptr.stop, radius: trRadius, largeArc: ptr.isLarge);
    }

    if (brRadius == Radius.zero || bSlope == rSlope) {
      path.lineTo(bottomRight.dx, bottomRight.dy);
    } else {
      final pbr = getPoints(
        brRadius.x,
        brRadius.y,
        bottomRight.dx,
        bottomRight.dy,
        rSlope,
        bSlope,
        Alignment.topLeft,
      );
      print('bottomRight: $pbr');
      path.lineTo(pbr.stop.dx, pbr.stop.dy);
      path.arcToPoint(pbr.start, radius: brRadius, largeArc: pbr.isLarge);
    }

    if (blRadius == Radius.zero || bSlope == lSlope) {
      path.lineTo(bottomLeft.dx, bottomLeft.dy);
    } else {
      final pbl = getPoints(
        blRadius.x,
        blRadius.y,
        bottomLeft.dx,
        bottomLeft.dy,
        lSlope,
        bSlope,
        Alignment.topRight,
      );
      print('bottomLeft: $pbl');
      path.lineTo(pbl.start.dx, pbl.start.dy);
      path.arcToPoint(pbl.stop, radius: blRadius, largeArc: pbl.isLarge);
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
    final trans = Matrix4.identity()..translate(side.strokeOutset);
    final path = _getPath(rect, textDirection: textDirection)
      ..transform(trans.storage);

    return path;
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
  TrapeziumBorder scale(double t) => TrapeziumBorder(
        side: side.scale(t),
        borderOffset: borderOffset.scale(t),
        borderRadius: borderRadius * t,
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is TrapeziumBorder) {
      return TrapeziumBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius: BorderRadiusGeometry.lerp(
          a.borderRadius,
          borderRadius,
          t,
        )!,
        borderOffset: BorderOffset.lerp(a.borderOffset, borderOffset, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is TrapeziumBorder) {
      return TrapeziumBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius: BorderRadiusGeometry.lerp(
          borderRadius,
          b.borderRadius,
          t,
        )!,
        borderOffset: BorderOffset.lerp(borderOffset, b.borderOffset, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is TrapeziumBorder &&
        other.side == side &&
        other.borderOffset == borderOffset &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(side, borderRadius, borderOffset);

  @override
  String toString() => '${objectRuntimeType(this, 'TrapeziumBorder')}'
      '($side, $borderRadius, $borderOffset)';
}

class CornerRadius {
  CornerRadius(this.start, this.stop, [this.isLarge = false]);

  final Offset start;
  final Offset stop;
  final bool isLarge;

  @override
  String toString() => 'CornerRadius($start, $stop, $isLarge)';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CornerRadius &&
        other.start == start &&
        other.stop == stop &&
        other.isLarge == isLarge;
  }

  @override
  int get hashCode => Object.hash(start, stop, isLarge);
}

/// caculate the tangent point of the corner and the radius
CornerRadius getPoints(
  double a,
  double b,
  double x,
  double y,
  double k1,
  double k2,
  Alignment align,
) {
  double? x1;
  double? x2;
  double? y1;
  double? y2;

  double? h;
  double? k;

  final isVertical = k1.abs() == double.infinity;
  final isHorizontal = k2 == 0;

  if (isHorizontal) {
    k = y + b * align.y;
  }
  if (isVertical) {
    h = x + a * align.x;
  }

  if (isHorizontal) {
    x1 = h;
    y1 = y;
  }

  // 暂不处理该情况
  assert(k1 != 0);

  if (isVertical) {
    y2 = k;
    x2 = x;
  }

  // 暂不处理该情况
  assert(k2.abs() != double.infinity);

  if (x1 == null || y1 == null || x2 == null || y2 == null) {
    double? d;
    if (a == b) {
      double? a1, a2;
      // if (h != null || k != null) {
      //   if (h == null) {
      //     final angle = (math.pi - math.atan(k1 * align.x)) / 2;
      //     d = a / math.tan(angle);
      //     h = x + d;
      //     x1 = h;
      //   }
      //   if (k == null) {
      //     final angle = (math.pi / 2 + math.atan(k2 * align.y)) / 2;
      //     d = b / math.tan(angle);
      //     k = y + d;
      //     y2 = k;
      //   }
      // }
      if (isVertical) {
        a1 = math.pi / 2 + math.pi / 2 * align.y;
      }
      if (isHorizontal) {
        a2 = math.pi / 2 + math.pi / 2 * align.x;
      }
      a1 ??= math.pi / 2 + math.atan(1 / k1);
      a2 ??= math.pi / 2 + math.atan(k2) * align.x;
      final angle = (a2 - a1).abs() / 2;

      d = a / math.tan(angle);
      print(
          'half angle:${a2 * 180 / math.pi},  ${a1 * 180 / math.pi},  ${angle * 180 / math.pi}, $d');
      if (isVertical) {
        y2 = y + d * align.y;
      }
      if (isHorizontal) {
        x1 = x + d * align.x;
      }

      print('$x1, $y1, $x2, $y2');

      x1 ??= x + math.sin(a2) * d * align.x;
      y1 ??= y - math.cos(a2) * d;

      x2 ??= x - math.cos(a1) * d * align.x;
      y2 ??= y + math.sin(a1) * d;
    } else {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'Unsupported elliptical radius yet.',
        ),
        ErrorDescription('The following is not circle radius:'),
      ]);
    }
  }

  return CornerRadius(Offset(x1, y1), Offset(x2, y2));
}
