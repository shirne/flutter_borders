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
  TrapeziumBorder({
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

  /// TODO(shirne) for debug
  final path3 = Path();
  final cpoints = <String, Offset>{};

  Path _getPath(Rect rect, {TextDirection? textDirection}) {
    final br = borderRadius.resolve(textDirection);
    final tlRadius = br.topLeft.clamp(minimum: Radius.zero);
    final trRadius = br.topRight.clamp(minimum: Radius.zero);
    final brRadius = br.bottomRight.clamp(minimum: Radius.zero);
    final blRadius = br.bottomLeft.clamp(minimum: Radius.zero);

    final offsets = getOffsets(rect);

    final tSlope = (offsets.topRight.dy - offsets.topLeft.dy) /
        (offsets.topRight.dx - offsets.topLeft.dx);
    final rSlope = (offsets.topRight.dy - offsets.bottomRight.dy) /
        (offsets.topRight.dx - offsets.bottomRight.dx);
    final bSlope = (offsets.bottomRight.dy - offsets.bottomLeft.dy) /
        (offsets.bottomRight.dx - offsets.bottomLeft.dx);
    final lSlope = (offsets.topLeft.dy - offsets.bottomLeft.dy) /
        (offsets.topLeft.dx - offsets.bottomLeft.dx);

    final path = Path();
    path3.reset();
    cpoints.clear();

    if (tlRadius == Radius.zero || tSlope == lSlope) {
      path.moveTo(offsets.topLeft.dx, offsets.topLeft.dy);
      path3.moveTo(offsets.topLeft.dx, offsets.topLeft.dy);
    } else {
      final ptl = getPoints(
        tlRadius,
        offsets.topLeft,
        -lSlope,
        tSlope,
        CornerAlign.topLeft,
      );

      path.moveTo(ptl.stop.dx, ptl.stop.dy);
      path.arcToPoint(ptl.start, radius: tlRadius, largeArc: ptl.isLarge);
      path3.moveTo(ptl.center.dx, ptl.center.dy);
      cpoints['top-left'] = ptl.center;
    }

    if (trRadius == Radius.zero || tSlope == rSlope) {
      path.lineTo(offsets.topRight.dx, offsets.topRight.dy);
      path3.lineTo(offsets.topRight.dx, offsets.topRight.dy);
    } else {
      final ptr = getPoints(
        trRadius,
        offsets.topRight,
        -rSlope,
        -tSlope,
        CornerAlign.topRight,
      );

      path.lineTo(ptr.start.dx, ptr.start.dy);
      path.arcToPoint(ptr.stop, radius: trRadius, largeArc: ptr.isLarge);
      path3.lineTo(ptr.center.dx, ptr.center.dy);
      cpoints['top-right'] = ptr.center;
    }

    if (brRadius == Radius.zero || bSlope == rSlope) {
      path.lineTo(offsets.bottomRight.dx, offsets.bottomRight.dy);
      path3.lineTo(offsets.bottomRight.dx, offsets.bottomRight.dy);
    } else {
      final pbr = getPoints(
        brRadius,
        offsets.bottomRight,
        rSlope,
        -bSlope,
        CornerAlign.bottomRight,
      );

      path.lineTo(pbr.stop.dx, pbr.stop.dy);
      path.arcToPoint(pbr.start, radius: brRadius, largeArc: pbr.isLarge);
      path3.lineTo(pbr.center.dx, pbr.center.dy);
      cpoints['bottom-right'] = pbr.center;
    }

    if (blRadius == Radius.zero || bSlope == lSlope) {
      path.lineTo(offsets.bottomLeft.dx, offsets.bottomLeft.dy);
      path3.lineTo(offsets.bottomLeft.dx, offsets.bottomLeft.dy);
    } else {
      final pbl = getPoints(
        blRadius,
        offsets.bottomLeft,
        lSlope,
        bSlope,
        CornerAlign.bottomLeft,
      );

      path.lineTo(pbl.start.dx, pbl.start.dy);
      path.arcToPoint(pbl.stop, radius: blRadius, largeArc: pbl.isLarge);
      path3.lineTo(pbl.center.dx, pbl.center.dy);
      cpoints['bottom-left'] = pbl.center;
    }

    path.close();
    path3.close();

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

        // TODO(shirne) for debug
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
        var radius = borderRadius.resolve(textDirection);
        for (var e in cpoints.entries) {
          canvas.drawCircle(
            e.value,
            radius.topLeft.x,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = const Color(0xA0FF0000),
          );
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

@visibleForTesting
enum CornerAlign {
  topLeft(-1, -1),
  topRight(1, -1),
  bottomLeft(-1, 1),
  bottomRight(1, 1);

  const CornerAlign(this.x, this.y);

  final double x;
  final double y;
}

/// caculate the tangent point of the corner and the radius
@visibleForTesting
CornerRadius getPoints(
  Radius radius,
  Offset corner,
  double k1,
  double k2,
  CornerAlign align,
) {
  double? x1;
  double? x2;
  double? y1;
  double? y2;

  /// 切圆的圆心
  double? h;
  double? k;

  final isVertical = k1.abs() == double.infinity;
  final isHorizontal = k2 == 0;

  double c;
  switch (align) {
    case CornerAlign.topLeft:
      c = (math.atan(k1) - math.atan(k2)) / 2;
      break;
    case CornerAlign.topRight:
      c = -(math.atan(k1) - math.atan(k2)) / 2;
      break;
    case CornerAlign.bottomLeft:
      c = (math.atan(k2) - math.atan(k1)) / 2;
      break;
    case CornerAlign.bottomRight:
      c = -(math.atan(k2) - math.atan(k1)) / 2;
      break;
  }

  if (isHorizontal) {
    k = corner.dy - radius.y * align.y;
  }
  if (isVertical) {
    h = corner.dx - radius.x * align.x;
  }

  if (isHorizontal) {
    switch (align) {
      case CornerAlign.topLeft:
        if (k1 > 0) {
          h ??= corner.dx + radius.y * math.tan(c);
        } else {
          h ??= corner.dx - radius.y / math.tan(c);
        }
        break;
      case CornerAlign.topRight:
        if (k1 > 0) {
          h ??= corner.dx + radius.y / math.tan(c);
        } else {
          h ??= corner.dx - radius.y * math.tan(c);
        }
        break;
      case CornerAlign.bottomLeft:
        if (k1 > 0) {
          h ??= corner.dx - radius.y * math.tan(c);
        } else {
          h ??= corner.dx + radius.y / math.tan(c);
        }
        break;
      case CornerAlign.bottomRight:
        if (k1 > 0) {
          h ??= corner.dx - radius.y / math.tan(c);
        } else {
          h ??= corner.dx + radius.y * math.tan(c);
        }
        break;
    }

    x1 = h;
    y1 = corner.dy;
  }

  // 暂不处理该情况
  assert(k1 != 0);

  if (isVertical) {
    switch (align) {
      case CornerAlign.topLeft:
        k ??= corner.dy + radius.x / math.tan(c);
        break;
      case CornerAlign.topRight:
        k ??= corner.dy - radius.x / math.tan(c);
        break;
      case CornerAlign.bottomLeft:
        k ??= corner.dy - radius.x / math.tan(c);
        break;
      case CornerAlign.bottomRight:
        k ??= corner.dy + radius.x / math.tan(c);
        break;
    }

    y2 = k;
    x2 = corner.dx;
  }

  // 暂不处理该情况
  assert(k2.abs() != double.infinity);

  if (x1 == null && y1 == null && x2 != null && y2 != null) {
    final yd = (y2 - corner.dy).abs() * math.sin(math.atan(k2.abs()));
    switch (align) {
      case CornerAlign.topLeft:
        if (k2 > 0) {
          y1 = corner.dy + yd;
          x1 = corner.dx + yd / k2;
        } else {
          y1 = corner.dy - yd;
          x1 = corner.dx - yd / k2;
        }
        break;
      case CornerAlign.topRight:
        if (k2 > 0) {
          y1 = corner.dy + yd;
          x1 = corner.dx - yd / k2;
        } else {
          y1 = corner.dy - yd;
          x1 = corner.dx + yd / k2;
        }
        break;
      case CornerAlign.bottomLeft:
        if (k2 > 0) {
          y1 = corner.dy + yd;
          x1 = corner.dx + yd / k2;
        } else {
          y1 = corner.dy - yd;
          x1 = corner.dx - yd / k2;
        }
        break;
      case CornerAlign.bottomRight:
        if (k2 > 0) {
          y1 = corner.dy + yd;
          x1 = corner.dx - yd / k2;
        } else {
          y1 = corner.dy - yd;
          x1 = corner.dx + yd / k2;
        }
        break;
    }
  } else if (x1 != null && y1 != null && x2 == null && y2 == null) {
    final xd = (x1 - corner.dx).abs() * math.cos(math.atan(k1.abs()));
    switch (align) {
      case CornerAlign.topLeft:
        if (k1 > 0) {
          x2 = corner.dx - xd;
          y2 = corner.dy + xd * k1;
        } else {
          x2 = corner.dx + xd;
          y2 = corner.dy - xd * k1;
        }
        break;
      case CornerAlign.topRight:
        if (k1 > 0) {
          x2 = corner.dx - xd;
          y2 = corner.dy + xd * k1;
        } else {
          x2 = corner.dx + xd;
          y2 = corner.dy - xd * k1;
        }
        break;
      case CornerAlign.bottomLeft:
        if (k1 > 0) {
          x2 = corner.dx - xd;
          y2 = corner.dy - xd * k1;
        } else {
          x2 = corner.dx + xd;
          y2 = corner.dy + xd * k1;
        }
        break;
      case CornerAlign.bottomRight:
        if (k1 > 0) {
          x2 = corner.dx - xd;
          y2 = corner.dy - xd * k1;
        } else {
          x2 = corner.dx + xd;
          y2 = corner.dy + xd * k1;
        }
        break;
    }
  }

  if (x1 == null || y1 == null || x2 == null || y2 == null) {
    double? d;
    if (radius.x == radius.y) {
      // a1 -90~90  a2 0~180
      double? a1, a2;

      a1 = math.atan(k1);
      a2 = math.atan(k2);

      if (k1 * k2 > 0) {
        d = radius.x * math.tan(c);
      } else {
        d = radius.x / math.tan(c);
      }

      switch (align) {
        case CornerAlign.topLeft:
          if (k2 > 0) {
            if (k1 > 0) {
              x1 = corner.dx + math.cos(a2) * d;
              y1 = corner.dy + math.sin(a2) * d;
            } else {
              x1 = corner.dx - math.cos(a2) * d;
              y1 = corner.dy - math.sin(a2) * d;
            }
          } else {
            if (k1 > 0) {
              x1 = corner.dx + math.cos(a2) * d;
              y1 = corner.dy + math.sin(a2) * d;
            } else {
              x1 = corner.dx - math.cos(a2) * d;
              y1 = corner.dy + math.sin(a2) * d;
            }
          }

          x2 = corner.dx - math.cos(a1) * d;
          y2 = corner.dy + math.sin(a1) * d;

          break;
        case CornerAlign.topRight:
          if (k2 > 0) {
            if (k1 > 0) {
              x1 = corner.dx + math.cos(a2) * d;
              y1 = corner.dy - math.sin(a2) * d;
            } else {
              x1 = corner.dx - math.cos(a2) * d;
              y1 = corner.dy + math.sin(a2) * d;
            }
          } else {
            if (k1 > 0) {
              x1 = corner.dx + math.cos(a2) * d;
              y1 = corner.dy - math.sin(a2) * d;
            } else {
              x1 = corner.dx - math.cos(a2) * d;
              y1 = corner.dy + math.sin(a2) * d;
            }
          }
          x2 = corner.dx + math.cos(a1) * d;
          y2 = corner.dy - math.sin(a1) * d;
          break;
        case CornerAlign.bottomLeft:
          if (k2 > 0) {
            if (k1 > 0) {
              x1 = corner.dx - math.cos(a2) * d;
              y1 = corner.dy - math.sin(a2) * d;
            } else {
              x1 = corner.dx + math.cos(a2) * d;
              y1 = corner.dy + math.sin(a2) * d;
            }
          } else {
            if (k1 > 0) {
              x1 = corner.dx - math.cos(a2) * d;
              y1 = corner.dy + math.sin(a2) * d;
            } else {
              x1 = corner.dx + math.cos(a2) * d;
              y1 = corner.dy + math.sin(a2) * d;
            }
          }
          x2 = corner.dx + math.cos(a1) * d;
          y2 = corner.dy + math.sin(a1) * d;
          break;
        case CornerAlign.bottomRight:
          if (k2 > 0) {
            if (k1 > 0) {
              x1 = corner.dx - math.cos(a2) * d;
              y1 = corner.dy + math.sin(a2) * d;
            } else {
              x1 = corner.dx + math.cos(a2) * d;
              y1 = corner.dy - math.sin(a2) * d;
            }
          } else {
            if (k1 > 0) {
              x1 = corner.dx - math.cos(a2) * d;
              y1 = corner.dy + math.sin(a2) * d;
            } else {
              x1 = corner.dx + math.cos(a2) * d;
              y1 = corner.dy - math.sin(a2) * d;
            }
          }

          x2 = corner.dx - math.cos(a1) * d;
          y2 = corner.dy - math.sin(a1) * d;
          break;
        default:
          throw Exception('align error');
      }
    } else {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'Unsupported elliptical radius yet.',
        ),
        ErrorDescription('The following is not circle radius:'),
      ]);
    }
  }

  return CornerRadius(Offset(x1, y1), Offset(x2, y2), Offset(h ?? 0, k ?? 0));
}
