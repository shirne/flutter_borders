import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class GradientShapeBorder extends OutlinedBorder {
  /// const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const GradientShapeBorder({
    super.side = BorderSide.none,
    this.borderRadius = BorderRadius.zero,
    this.gradient,
  });

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsets.all(math.max(side.strokeInset, 0));

  /// The radii for each corner.
  final BorderRadiusGeometry borderRadius;

  final Gradient? gradient;

  @override
  ShapeBorder scale(double t) => GradientShapeBorder(
        side: side.scale(t),
        borderRadius: borderRadius * t,
        gradient: gradient,
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is GradientShapeBorder) {
      return GradientShapeBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius: BorderRadiusGeometry.lerp(
          a.borderRadius,
          borderRadius,
          t,
        )!,
        gradient: Gradient.lerp(a.gradient, gradient, t),
      );
    }

    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is GradientShapeBorder) {
      return GradientShapeBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius: BorderRadiusGeometry.lerp(
          borderRadius,
          b.borderRadius,
          t,
        )!,
        gradient: Gradient.lerp(gradient, b.gradient, t),
      );
    }

    return super.lerpTo(b, t);
  }

  /// Returns a copy of this GradientShapeBorder with the given fields
  /// replaced with the new values.
  @override
  GradientShapeBorder copyWith({
    BorderSide? side,
    BorderRadiusGeometry? borderRadius,
    Gradient? gradient,
  }) =>
      GradientShapeBorder(
        side: side ?? this.side,
        borderRadius: borderRadius ?? this.borderRadius,
        gradient: gradient ?? this.gradient,
      );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final RRect borderRect = borderRadius.resolve(textDirection).toRRect(rect);
    final RRect adjustedRect = borderRect.deflate(side.strokeInset);
    return Path()..addRRect(adjustedRect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    if (borderRadius == BorderRadius.zero) {
      canvas.drawRect(rect, paint);
    } else {
      canvas.drawRRect(
        borderRadius.resolve(textDirection).toRRect(rect),
        paint,
      );
    }
  }

  @override
  bool get preferPaintInterior => true;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        if (side.width == 0.0) {
          canvas.drawRRect(
            borderRadius.resolve(textDirection).toRRect(rect),
            side.toPaint(),
          );
        } else {
          final Paint paint = Paint()..color = side.color;
          if (gradient != null) {
            paint.shader = gradient!.createShader(rect);
          }
          final RRect borderRect =
              borderRadius.resolve(textDirection).toRRect(rect);
          final RRect inner = borderRect.deflate(side.strokeInset);
          final RRect outer = borderRect.inflate(side.strokeOutset);
          canvas.drawDRRect(outer, inner, paint);
        }
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GradientShapeBorder &&
        other.side == side &&
        other.borderRadius == borderRadius &&
        other.gradient == gradient;
  }

  @override
  int get hashCode => Object.hash(side, borderRadius);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'GradientShapeBorder')}($side, $borderRadius, $gradient)';
}
