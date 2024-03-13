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

    final topAngle = topRight.dx == topLeft.dx
        ? 0.0
        : (topRight.dy - topLeft.dy) / (topRight.dx - topLeft.dx);
    final rightAngle = bottomRight.dx == topRight.dx
        ? 0.0
        : (bottomRight.dy - topRight.dy) / (bottomRight.dx - topRight.dx);
    final bottomAngle = bottomRight.dx == bottomLeft.dx
        ? 0.0
        : (bottomRight.dy - bottomLeft.dy) / (bottomRight.dx - bottomLeft.dx);
    final leftAngle = topLeft.dx == bottomLeft.dx
        ? 0.0
        : (topLeft.dy - bottomLeft.dy) / (topLeft.dx - bottomLeft.dx);

    final path = Path();

    if (tlRadius == Radius.zero) {
      path.moveTo(topLeft.dx, topLeft.dy);
    } else {
      final ptl = getPoints(
        tlRadius.x,
        tlRadius.y,
        topLeft.dx,
        topLeft.dy,
        topAngle,
        leftAngle,
        Alignment.bottomRight,
      );
      path.moveTo(ptl[1].dx, ptl[1].dy);
      path.arcToPoint(ptl[0], radius: tlRadius);
    }

    if (trRadius == Radius.zero) {
      path.lineTo(topRight.dx, topRight.dy);
    } else {
      final ptr = getPoints(
        trRadius.x,
        trRadius.y,
        topRight.dx,
        topRight.dy,
        topAngle,
        rightAngle,
        Alignment.bottomLeft,
      );
      path.lineTo(ptr[0].dx, ptr[0].dy);

      path.arcToPoint(ptr[1], radius: trRadius);
    }

    if (brRadius == Radius.zero) {
      path.lineTo(bottomRight.dx, bottomRight.dy);
    } else {
      final pbr = getPoints(
        brRadius.x,
        brRadius.y,
        bottomRight.dx,
        bottomRight.dy,
        bottomAngle,
        rightAngle,
        Alignment.topLeft,
      );
      path.lineTo(pbr[1].dx, pbr[1].dy);
      path.arcToPoint(pbr[0], radius: brRadius);
    }

    if (blRadius == Radius.zero) {
      path.lineTo(bottomLeft.dx, bottomLeft.dy);
    } else {
      final pbl = getPoints(
        blRadius.x,
        blRadius.y,
        bottomLeft.dx,
        bottomLeft.dy,
        bottomAngle,
        leftAngle,
        Alignment.topRight,
      );
      path.lineTo(pbl[0].dx, pbl[0].dy);

      path.arcToPoint(pbl[1], radius: blRadius);
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

List<Offset> getPoints(
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

  double h = 0;
  double k = 0;
  if (k1 == 0) {
    h = x + a;
    x1 = x;
    x2 = x + a;
  }

  if (k2 == 0) {
    k = y + b;
    y1 = y + b;
    y2 = y;
  }

  if (x1 == null || y1 == null) {
    if (x1 != null) {
      y1 = k1 * (x1 - x) + y;
    } else if (y1 != null) {
      x1 = k1 * (y1 - y) + x;
    }
  }

  if (x2 == null || y2 == null) {
    if (x2 != null) {
      y2 = k2 * (x2 - x) + y;
    } else if (y2 != null) {
      x2 = k2 * (y2 - y) + x;
    }
  }

  /**
   * (x1-h)(x-h)/a^2+(y1-k)(y-k)/b^2=1
   * (x1-h)^2/a^2+(y1-k)^2/b^2=1
   * (y1-y)/(x1-x)=k1
   * 
   * (x2-h)(x-h)/a^2+(y2-k)(y-k)/b^2=1
   * (x2-h)^2/a^2+(y2-k)^2/b^2=1
   * (y2-y)/(x2-x)=k2
   */
  if (x1 == null || y1 == null || x2 == null || y2 == null) {
    final powa = math.pow(a, 2);
    final powb = math.pow(b, 2);

    // y1 = (x1 - x) * k1 + y;
    // y2 = (x2 - x) * k2 + y;

    // (x1 - h)^2 * b^2 + ((x1 - x) * k1 + y - k)^2 * a^2 = a^2 * b^2
    // (x1 - h)(x - h) * b^2 + ((x1 - x) * k1 + y - k)(y - k) * a^2 = a^2 * b^2

    // (x2 - h)^2 * b^2 + ((x2 - x) * k2 + y - k)^2 * a^2 = a^2 * b^2
    // (x2 - h)(x - h) * b^2 + ((x2 - x) * k2 + y - k)(y - k) * a^2 = a^2 * b^2

    // ?
    if (k1 != 0 && k2 != 0) {
      k = ((x - a) / k1 + y - k2 * b / k1) / (1 - k2 / k1);
      h = k2 * (k - b) + x;
    }

    y1 = powb / (y - k - (x - h) * k1) + k;
    x1 = h - powa * k1 / (y1 - k) / powb;

    y2 = powb / (y - k - (x - h) * k2) + k;
    x2 = h - powa * k1 / (y2 - k) / powb;
  }

  return [Offset(x1, y1), Offset(x2, y2)];
}
