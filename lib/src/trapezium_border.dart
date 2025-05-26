import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

bool _isDebug = false;

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

/// Irregular quadrilateral border, such as trapezoid,prisms.
/// [Offset] four vertices based on [Rect].
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
  TrapeziumBorder({
    this.borderOffset = const BorderOffset(),
    this.borderRadius = BorderRadius.zero,
    super.side,
  });

  static set isDebug(bool d) => _isDebug = d;

  final BorderOffset borderOffset;
  final BorderRadiusGeometry borderRadius;

  @override
  TrapeziumBorder copyWith({BorderSide? side, BorderOffset? borderOffset}) =>
      TrapeziumBorder(
        borderOffset: borderOffset ?? this.borderOffset,
        side: side ?? this.side,
      );

  BorderOffset getOffsets(Rect rect) => BorderOffset(
        topLeft: Offset(
          rect.left - borderOffset.topLeft.dx,
          rect.top - borderOffset.topLeft.dy,
        ),
        topRight: Offset(
          rect.right + borderOffset.topRight.dx,
          rect.top - borderOffset.topRight.dy,
        ),
        bottomRight: Offset(
          rect.right + borderOffset.bottomRight.dx,
          rect.bottom + borderOffset.bottomRight.dy,
        ),
        bottomLeft: Offset(
          rect.left - borderOffset.bottomLeft.dx,
          rect.bottom + borderOffset.bottomLeft.dy,
        ),
      );

  /// for debug
  final path3 = Path();
  final cpoints = <String, Offset>{};

  Path _getPath(Rect rect, {TextDirection? textDirection}) {
    final br = borderRadius.resolve(textDirection);
    final tlRadius = br.topLeft.clamp(minimum: Radius.zero);
    final trRadius = br.topRight.clamp(minimum: Radius.zero);
    final brRadius = br.bottomRight.clamp(minimum: Radius.zero);
    final blRadius = br.bottomLeft.clamp(minimum: Radius.zero);

    final offsets = getOffsets(rect);

    final tSlope = math.atan2(
      offsets.topRight.dy - offsets.topLeft.dy,
      offsets.topRight.dx - offsets.topLeft.dx,
    );
    final rSlope = math.atan2(
      offsets.bottomRight.dy - offsets.topRight.dy,
      offsets.bottomRight.dx - offsets.topRight.dx,
    );
    final bSlope = math.atan2(
      offsets.bottomLeft.dy - offsets.bottomRight.dy,
      offsets.bottomLeft.dx - offsets.bottomRight.dx,
    );
    final lSlope = math.atan2(
      offsets.topLeft.dy - offsets.bottomLeft.dy,
      offsets.topLeft.dx - offsets.bottomLeft.dx,
    );

    final path = Path();
    if (_isDebug) {
      path3.reset();
      cpoints.clear();
    }

    if (tlRadius == Radius.zero || tSlope == lSlope) {
      path.moveTo(offsets.topLeft.dx, offsets.topLeft.dy);
      if (_isDebug) path3.moveTo(offsets.topLeft.dx, offsets.topLeft.dy);
    } else {
      final ptl = getPoints(
        tlRadius,
        offsets.topLeft,
        lSlope,
        tSlope,
      );

      path.moveTo(ptl.start.dx, ptl.start.dy);
      path.arcToPoint(ptl.stop, radius: tlRadius, largeArc: ptl.isLarge);
      if (_isDebug) {
        path3.moveTo(ptl.center.dx, ptl.center.dy);
        cpoints['top-left'] = ptl.center;
      }
    }

    if (trRadius == Radius.zero || tSlope == rSlope) {
      path.lineTo(offsets.topRight.dx, offsets.topRight.dy);
      if (_isDebug) path3.lineTo(offsets.topRight.dx, offsets.topRight.dy);
    } else {
      final ptr = getPoints(
        trRadius,
        offsets.topRight,
        tSlope,
        rSlope,
      );

      path.lineTo(ptr.start.dx, ptr.start.dy);
      path.arcToPoint(ptr.stop, radius: trRadius, largeArc: ptr.isLarge);
      if (_isDebug) {
        path3.lineTo(ptr.center.dx, ptr.center.dy);
        cpoints['top-right'] = ptr.center;
      }
    }

    if (brRadius == Radius.zero || bSlope == rSlope) {
      path.lineTo(offsets.bottomRight.dx, offsets.bottomRight.dy);
      if (_isDebug) {
        path3.lineTo(offsets.bottomRight.dx, offsets.bottomRight.dy);
      }
    } else {
      final pbr = getPoints(
        brRadius,
        offsets.bottomRight,
        rSlope,
        bSlope,
      );

      path.lineTo(pbr.start.dx, pbr.start.dy);
      path.arcToPoint(pbr.stop, radius: brRadius, largeArc: pbr.isLarge);
      if (_isDebug) {
        path3.lineTo(pbr.center.dx, pbr.center.dy);
        cpoints['bottom-right'] = pbr.center;
      }
    }

    if (blRadius == Radius.zero || bSlope == lSlope) {
      path.lineTo(offsets.bottomLeft.dx, offsets.bottomLeft.dy);
      if (_isDebug) path3.lineTo(offsets.bottomLeft.dx, offsets.bottomLeft.dy);
    } else {
      final pbl = getPoints(
        blRadius,
        offsets.bottomLeft,
        bSlope,
        lSlope,
      );

      path.lineTo(pbl.start.dx, pbl.start.dy);
      path.arcToPoint(pbl.stop, radius: blRadius, largeArc: pbl.isLarge);
      if (_isDebug) {
        path3.lineTo(pbl.center.dx, pbl.center.dy);
        cpoints['bottom-left'] = pbl.center;
      }
    }

    path.close();
    if (_isDebug) path3.close();

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

        //  for debug
        if (_isDebug) {
          final offsets = getOffsets(rect);
          final path = Path()
            ..moveTo(offsets.topLeft.dx, offsets.topLeft.dy)
            ..lineTo(offsets.topRight.dx, offsets.topRight.dy)
            ..lineTo(offsets.bottomRight.dx, offsets.bottomRight.dy)
            ..lineTo(offsets.bottomLeft.dx, offsets.bottomLeft.dy)
            ..close();

          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.fill
              ..color = const Color(0x20FF0000),
          );
          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = const Color(0xA0FF0000),
          );

          if (!path3.getBounds().isEmpty) {
            canvas.drawPath(
              path3,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1
                ..color = const Color(0xA00000FF),
            );
          }
          final radius = borderRadius.resolve(textDirection);
          for (final e in cpoints.entries) {
            double r = radius.topLeft.x;
            if (e.key == 'top-right') {
              r = radius.topRight.x;
            } else if (e.key == 'bottom-left') {
              r = radius.bottomLeft.x;
            } else if (e.key == 'bottom-right') {
              r = radius.bottomRight.x;
            }
            canvas.drawCircle(
              e.value,
              r,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1
                ..color = const Color(0xA0FF0000),
            );
          }
        }
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
  CornerRadius(this.start, this.stop, this.center, [this.isLarge = false]);

  final Offset start;
  final Offset stop;
  final Offset center;
  final bool isLarge;

  @override
  String toString() => 'CornerRadius($start, $stop, $center, $isLarge)';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CornerRadius &&
        other.start == start &&
        other.stop == stop &&
        other.center == center &&
        other.isLarge == isLarge;
  }

  @override
  int get hashCode => Object.hash(start, stop, center, isLarge);
}

/// caculate the tangent point of the corner and the radius
@visibleForTesting
CornerRadius getPoints(
  Radius radius,
  Offset corner,
  double k1,
  double k2,
) {
  if (radius.x != radius.y) {
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'Unsupported elliptical radius yet.',
      ),
      ErrorDescription('The following is not circle radius:'),
    ]);
  }

  double? x1;
  double? x2;
  double? y1;
  double? y2;

  /// 切圆的圆心
  double? h;
  double? k;

  final c = (k2 + k1) / 2;
  final r = radius.x / math.cos(c - k1);
  final d = radius.x * math.tan(c - k1).abs();

  h = corner.dx - math.sin(c) * r;
  k = corner.dy + math.cos(c) * r;

  x1 = corner.dx - math.cos(k1) * d;
  y1 = corner.dy - math.sin(k1) * d;
  x2 = corner.dx + math.cos(k2) * d;
  y2 = corner.dy + math.sin(k2) * d;

  return CornerRadius(Offset(x1, y1), Offset(x2, y2), Offset(h, k));
}
