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
    BorderSide side = BorderSide.none,
  }) : super(side: side);

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
        ? 0
        : math.atan((topRight.dy - topLeft.dy) / (topRight.dx - topLeft.dx));
    final rightAngle = bottomRight.dy == topRight.dy
        ? 0
        : math.atan(
            (bottomRight.dx - topRight.dx) / (bottomRight.dy - topRight.dy),
          );
    final bottomAngle = bottomRight.dx == bottomLeft.dx
        ? 0
        : math.atan(
            (bottomRight.dy - bottomLeft.dy) / (bottomRight.dx - bottomLeft.dx),
          );
    final leftAngle = topLeft.dy == bottomLeft.dy
        ? 0
        : math
            .atan((topLeft.dx - bottomLeft.dx) / (topLeft.dy - bottomLeft.dy));

    final path = Path();

    if (tlRadius == Radius.zero) {
      path.moveTo(topLeft.dx, topLeft.dy);
    } else {
      path.moveTo(
        topLeft.dx + tlRadius.x * math.sin(leftAngle),
        topLeft.dy + tlRadius.y * math.cos(leftAngle),
      );
      path.arcToPoint(
        Offset(
          topLeft.dx + tlRadius.x * math.cos(topAngle),
          topLeft.dy + tlRadius.y * math.sin(topAngle),
        ),
        radius: tlRadius,
      );
    }

    if (trRadius == Radius.zero) {
      path.lineTo(topRight.dx, topRight.dy);
    } else {
      path.lineTo(
        topRight.dx - trRadius.x * math.cos(topAngle),
        topRight.dy + trRadius.y * math.sin(topAngle),
      );

      path.arcToPoint(
        Offset(
          topRight.dx + trRadius.x * math.sin(rightAngle),
          topRight.dy + trRadius.y * math.cos(rightAngle),
        ),
        radius: trRadius,
      );
    }

    if (brRadius == Radius.zero) {
      path.lineTo(bottomRight.dx, bottomRight.dy);
    } else {
      path.lineTo(
        bottomRight.dx - brRadius.x * math.sin(rightAngle),
        bottomRight.dy - brRadius.y * math.cos(rightAngle),
      );
      path.arcToPoint(
        Offset(
          bottomRight.dx - brRadius.x * math.cos(bottomAngle),
          bottomRight.dy - brRadius.y * math.sin(bottomAngle),
        ),
        radius: brRadius,
      );
    }

    if (blRadius == Radius.zero) {
      path.lineTo(bottomLeft.dx, bottomLeft.dy);
    } else {
      path.lineTo(
        bottomLeft.dx + blRadius.x * math.cos(bottomAngle),
        bottomLeft.dy - blRadius.y * math.sin(bottomAngle),
      );

      path.arcToPoint(
        Offset(
          bottomLeft.dx - blRadius.x * math.sin(leftAngle),
          bottomLeft.dy - blRadius.y * math.cos(leftAngle),
        ),
        radius: blRadius,
      );
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
