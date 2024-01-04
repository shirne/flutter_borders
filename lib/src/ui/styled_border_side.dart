import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class BorderDash {
  const BorderDash(
    this.array, [
    this.offset = 0,
    this.strokeCap = StrokeCap.round,
  ]);

  static const none = BorderDash([0, 3]);
  static const dotted = BorderDash([1]);
  static const dashed = BorderDash([3, 2]);
  static const morse = BorderDash([3, 2, 1, 2]);

  final List<double> array;
  final double offset;
  final StrokeCap strokeCap;

  static BorderDash? lerp(BorderDash? a, BorderDash? b, double t) {
    if (a == null) return b;
    if (b == null) return a;
    final lowestMultiple = a.array.length * b.array.length;

    return BorderDash(
      [
        for (int i = 0; i < lowestMultiple; i++)
          ui.lerpDouble(
                a.array[i % a.array.length],
                b.array[i % b.array.length],
                t,
              ) ??
              0,
      ],
      ui.lerpDouble(a.offset, b.offset, t) ?? 0,
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
    return other is BorderDash &&
        listEqual(other.array, array) &&
        other.offset == offset &&
        other.strokeCap == strokeCap;
  }

  static bool listEqual(List a, List b) {
    if (a.runtimeType != b.runtimeType) {
      return false;
    }
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(array, offset, strokeCap);
}

@immutable
class StyledBorderSide extends BorderSide {
  /// Creates the side of a border.
  ///
  /// By default, the border is 1.0 logical pixels wide and solid black.
  const StyledBorderSide({
    super.color = const Color(0xFF000000),
    super.width = 1.0,
    super.style = BorderStyle.solid,
    super.strokeAlign = BorderSide.strokeAlignInside,
    this.dashStyle,
  }) : assert(width >= 0.0);

  /// Creates a [StyledBorderSide] that represents the addition of the two given
  /// [StyledBorderSide]s.
  ///
  /// It is only valid to call this if [canMerge] returns true for the two
  /// sides.
  ///
  /// If one of the sides is zero-width with [BorderStyle.none], then the other
  /// side is return as-is. If both of the sides are zero-width with
  /// [StyledBorderSide.none], then [StyledBorderSide.none] is returned.
  ///
  /// The arguments must not be null.
  static StyledBorderSide merge(BorderSide a, BorderSide b) {
    assert(BorderSide.canMerge(a, b));
    final bool aIsNone = a.style == BorderStyle.none && a.width == 0.0;
    final bool bIsNone = b.style == BorderStyle.none && b.width == 0.0;
    if (aIsNone && bIsNone) {
      return StyledBorderSide.none;
    }
    if (aIsNone) {
      return a is StyledBorderSide
          ? a
          : StyledBorderSide(
              color: b.color,
              width: b.width,
              style: b.style,
              strokeAlign: b.strokeAlign,
            );
    }
    if (bIsNone) {
      return b is StyledBorderSide
          ? b
          : StyledBorderSide(
              color: a.color,
              width: a.width,
              style: a.style,
              strokeAlign: a.strokeAlign,
            );
    }
    assert(a.color == b.color);
    assert(a.style == b.style);
    return StyledBorderSide(
      color: a.color, // == b.color
      width: a.width + b.width,
      strokeAlign: math.max(a.strokeAlign, b.strokeAlign),
      style: a.style, // == b.style
      dashStyle: a is StyledBorderSide ? a.dashStyle : null,
    );
  }

  final BorderDash? dashStyle;

  /// A hairline black border that is not rendered.
  static const StyledBorderSide none =
      StyledBorderSide(width: 0.0, style: BorderStyle.none);

  /// Creates a copy of this border but with the given fields replaced with the new values.
  @override
  StyledBorderSide copyWith({
    Color? color,
    double? width,
    BorderStyle? style,
    double? strokeAlign,
    BorderDash? dashStyle,
  }) =>
      StyledBorderSide(
        color: color ?? this.color,
        width: width ?? this.width,
        style: style ?? this.style,
        strokeAlign: strokeAlign ?? this.strokeAlign,
        dashStyle: dashStyle ?? this.dashStyle,
      );

  @override
  StyledBorderSide scale(double t) => StyledBorderSide(
        color: color,
        width: math.max(0.0, width * t),
        style: t <= 0.0 ? BorderStyle.none : style,
        dashStyle: dashStyle,
      );

  /// Linearly interpolate between two border sides.
  ///
  /// The arguments must not be null.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static StyledBorderSide lerp(BorderSide a, BorderSide b, double t) {
    if (identical(a, b)) {
      return a is StyledBorderSide
          ? a
          : StyledBorderSide(
              color: a.color,
              width: a.width,
              style: a.style,
              strokeAlign: a.strokeAlign,
            );
    }
    if (t == 0.0) {
      return a is StyledBorderSide
          ? a
          : StyledBorderSide(
              color: a.color,
              width: a.width,
              style: a.style,
              strokeAlign: a.strokeAlign,
            );
    }
    if (t == 1.0) {
      return b is StyledBorderSide
          ? b
          : StyledBorderSide(
              color: b.color,
              width: b.width,
              style: b.style,
              strokeAlign: b.strokeAlign,
            );
    }
    final double width = ui.lerpDouble(a.width, b.width, t)!;
    if (width < 0.0) {
      return StyledBorderSide.none;
    }
    if (a.style == b.style && a.strokeAlign == b.strokeAlign) {
      return StyledBorderSide(
        color: Color.lerp(a.color, b.color, t)!,
        width: width,
        style: a.style, // == b.style
        strokeAlign: a.strokeAlign, // == b.strokeAlign
        dashStyle: BorderDash.lerp(
          a is StyledBorderSide ? a.dashStyle : null,
          b is StyledBorderSide ? b.dashStyle : null,
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
      return StyledBorderSide(
        color: Color.lerp(colorA, colorB, t)!,
        width: width,
        strokeAlign: ui.lerpDouble(a.strokeAlign, b.strokeAlign, t)!,
        dashStyle: BorderDash.lerp(
          a is StyledBorderSide ? a.dashStyle : null,
          b is StyledBorderSide ? b.dashStyle : null,
          t,
        ),
      );
    }
    return StyledBorderSide(
      color: Color.lerp(colorA, colorB, t)!,
      width: width,
      strokeAlign: a.strokeAlign, // == b.strokeAlign
      dashStyle: BorderDash.lerp(
        a is StyledBorderSide ? a.dashStyle : null,
        b is StyledBorderSide ? b.dashStyle : null,
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
    return other is StyledBorderSide &&
        other.color == color &&
        other.width == width &&
        other.style == style &&
        other.strokeAlign == strokeAlign &&
        other.dashStyle == dashStyle;
  }

  @override
  int get hashCode => Object.hash(color, width, style, strokeAlign, dashStyle);

  @override
  String toStringShort() => 'StyledBorderSide';

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
        DiagnosticsProperty<BorderDash>(
          'dashStyle',
          dashStyle,
          defaultValue: null,
        ),
      );
  }
}
