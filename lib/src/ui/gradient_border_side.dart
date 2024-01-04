import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

@immutable
class GradientBorderSide extends BorderSide {
  /// Creates the side of a border.
  ///
  /// By default, the border is 1.0 logical pixels wide and solid black.
  const GradientBorderSide({
    super.color = const Color(0xFF000000),
    super.width = 1.0,
    super.style = BorderStyle.solid,
    super.strokeAlign = BorderSide.strokeAlignInside,
    this.gradient,
  }) : assert(width >= 0.0);

  /// Creates a [GradientBorderSide] that represents the addition of the two given
  /// [GradientBorderSide]s.
  ///
  /// It is only valid to call this if [canMerge] returns true for the two
  /// sides.
  ///
  /// If one of the sides is zero-width with [BorderStyle.none], then the other
  /// side is return as-is. If both of the sides are zero-width with
  /// [GradientBorderSide.none], then [GradientBorderSide.none] is returned.
  ///
  /// The arguments must not be null.
  static GradientBorderSide merge(BorderSide a, BorderSide b) {
    assert(BorderSide.canMerge(a, b));
    final bool aIsNone = a.style == BorderStyle.none && a.width == 0.0;
    final bool bIsNone = b.style == BorderStyle.none && b.width == 0.0;
    if (aIsNone && bIsNone) {
      return GradientBorderSide.none;
    }
    if (aIsNone) {
      return a is GradientBorderSide
          ? a
          : GradientBorderSide(
              color: b.color,
              width: b.width,
              style: b.style,
              strokeAlign: b.strokeAlign,
            );
    }
    if (bIsNone) {
      return b is GradientBorderSide
          ? b
          : GradientBorderSide(
              color: a.color,
              width: a.width,
              style: a.style,
              strokeAlign: a.strokeAlign,
            );
    }
    assert(a.color == b.color);
    assert(a.style == b.style);
    return GradientBorderSide(
      color: a.color, // == b.color
      width: a.width + b.width,
      strokeAlign: math.max(a.strokeAlign, b.strokeAlign),
      style: a.style, // == b.style
      gradient: a is GradientBorderSide ? a.gradient : null,
    );
  }

  final Gradient? gradient;

  /// A hairline black border that is not rendered.
  static const GradientBorderSide none =
      GradientBorderSide(width: 0.0, style: BorderStyle.none);

  /// Creates a copy of this border but with the given fields replaced with the new values.
  @override
  GradientBorderSide copyWith({
    Color? color,
    double? width,
    BorderStyle? style,
    double? strokeAlign,
    Gradient? gradient,
  }) =>
      GradientBorderSide(
        color: color ?? this.color,
        width: width ?? this.width,
        style: style ?? this.style,
        strokeAlign: strokeAlign ?? this.strokeAlign,
        gradient: gradient ?? this.gradient,
      );

  @override
  GradientBorderSide scale(double t) => GradientBorderSide(
        color: color,
        width: math.max(0.0, width * t),
        style: t <= 0.0 ? BorderStyle.none : style,
        gradient: gradient,
      );

  /// Linearly interpolate between two border sides.
  ///
  /// The arguments must not be null.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static GradientBorderSide lerp(BorderSide a, BorderSide b, double t) {
    if (identical(a, b)) {
      return a is GradientBorderSide
          ? a
          : GradientBorderSide(
              color: a.color,
              width: a.width,
              style: a.style,
              strokeAlign: a.strokeAlign,
            );
    }
    if (t == 0.0) {
      return a is GradientBorderSide
          ? a
          : GradientBorderSide(
              color: a.color,
              width: a.width,
              style: a.style,
              strokeAlign: a.strokeAlign,
            );
    }
    if (t == 1.0) {
      return b is GradientBorderSide
          ? b
          : GradientBorderSide(
              color: b.color,
              width: b.width,
              style: b.style,
              strokeAlign: b.strokeAlign,
            );
    }
    final double width = ui.lerpDouble(a.width, b.width, t)!;
    if (width < 0.0) {
      return GradientBorderSide.none;
    }
    if (a.style == b.style && a.strokeAlign == b.strokeAlign) {
      return GradientBorderSide(
        color: Color.lerp(a.color, b.color, t)!,
        width: width,
        style: a.style, // == b.style
        strokeAlign: a.strokeAlign, // == b.strokeAlign
        gradient: Gradient.lerp(
          a is GradientBorderSide ? a.gradient : null,
          b is GradientBorderSide ? b.gradient : null,
          t,
        ),
      );
    }
    final Color colorA, colorB;
    switch (a.style) {
      case BorderStyle.solid:
        colorA = a.color;
        break;
      case BorderStyle.none:
        colorA = a.color.withAlpha(0x00);
    }
    switch (b.style) {
      case BorderStyle.solid:
        colorB = b.color;
        break;
      case BorderStyle.none:
        colorB = b.color.withAlpha(0x00);
    }
    if (a.strokeAlign != b.strokeAlign) {
      return GradientBorderSide(
        color: Color.lerp(colorA, colorB, t)!,
        width: width,
        strokeAlign: ui.lerpDouble(a.strokeAlign, b.strokeAlign, t)!,
        gradient: Gradient.lerp(
          a is GradientBorderSide ? a.gradient : null,
          b is GradientBorderSide ? b.gradient : null,
          t,
        ),
      );
    }
    return GradientBorderSide(
      color: Color.lerp(colorA, colorB, t)!,
      width: width,
      strokeAlign: a.strokeAlign, // == b.strokeAlign
      gradient: Gradient.lerp(
        a is GradientBorderSide ? a.gradient : null,
        b is GradientBorderSide ? b.gradient : null,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is GradientBorderSide &&
        other.color == color &&
        other.width == width &&
        other.style == style &&
        other.strokeAlign == strokeAlign &&
        other.gradient == gradient;
  }

  @override
  int get hashCode => Object.hash(color, width, style, strokeAlign, gradient);

  @override
  String toStringShort() => 'GradientBorderSide';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<Color>(
          'color',
          color,
          defaultValue: const Color(0xFF000000),
        ),
      )
      ..add(DoubleProperty('width', width, defaultValue: 1.0))
      ..add(
        DoubleProperty(
          'strokeAlign',
          strokeAlign,
          defaultValue: BorderSide.strokeAlignInside,
        ),
      )
      ..add(
        EnumProperty<BorderStyle>(
          'style',
          style,
          defaultValue: BorderStyle.solid,
        ),
      )
      ..add(
        DiagnosticsProperty<Gradient>('gradient', gradient, defaultValue: null),
      );
  }
}
