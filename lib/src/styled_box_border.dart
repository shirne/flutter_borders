// ignore_for_file: overridden_fields

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'ui/styled_border_side.dart';

/// A dashed border use for [ShapeDecoration]
class StyledBoxBorder extends Border {
  /// Creates a border.
  ///
  /// All the sides of the border default to [StyledBorderSide.none].
  const StyledBoxBorder({
    this.top = StyledBorderSide.none,
    this.right = StyledBorderSide.none,
    this.bottom = StyledBorderSide.none,
    this.left = StyledBorderSide.none,
  });

  /// Creates a border whose sides are all the same.
  ///
  /// The `side` argument must not be null.
  const StyledBoxBorder.fromBorderSide(
    StyledBorderSide side, {
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) : this(
          top: side,
          right: side,
          bottom: side,
          left: side,
        );

  /// Creates a border with symmetrical vertical and horizontal sides.
  ///
  /// The `vertical` argument applies to the [left] and [right] sides, and the
  /// `horizontal` argument applies to the [top] and [bottom] sides.
  ///
  /// All arguments default to [StyledBorderSide.none] and must not be null.
  const StyledBoxBorder.symmetric({
    StyledBorderSide vertical = StyledBorderSide.none,
    StyledBorderSide horizontal = StyledBorderSide.none,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) : this(
          left: vertical,
          top: horizontal,
          right: vertical,
          bottom: horizontal,
        );

  /// A uniform border with all sides the same color and width.
  ///
  /// The sides default to black solid borders, one logical pixel wide.
  factory StyledBoxBorder.all({
    Color color = const Color(0xFF000000),
    double width = 1.0,
    BorderStyle style = BorderStyle.solid,
    double strokeAlign = BorderSide.strokeAlignInside,
    BorderDash? dashStyle,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final side = StyledBorderSide(
      color: color,
      width: width,
      style: style,
      strokeAlign: strokeAlign,
      dashStyle: dashStyle,
    );
    return StyledBoxBorder.fromBorderSide(
      side,
      shape: shape,
      borderRadius: borderRadius,
    );
  }

  @override
  final StyledBorderSide left;
  @override
  final StyledBorderSide top;
  @override
  final StyledBorderSide right;
  @override
  final StyledBorderSide bottom;

  /// Creates a [DashedBorder] that represents the addition of the two given
  /// [DashedBorder]s.
  ///
  /// It is only valid to call this if [BorderSide.canMerge] returns true for
  /// the pairwise combination of each side on both [DashedBorder]s.
  ///
  /// The arguments must not be null.
  static StyledBoxBorder merge(StyledBoxBorder a, StyledBoxBorder b) {
    assert(BorderSide.canMerge(a.top, b.top));
    assert(BorderSide.canMerge(a.right, b.right));
    assert(BorderSide.canMerge(a.bottom, b.bottom));
    assert(BorderSide.canMerge(a.left, b.left));
    return StyledBoxBorder(
      top: StyledBorderSide.merge(a.top, b.top),
      right: StyledBorderSide.merge(a.right, b.right),
      bottom: StyledBorderSide.merge(a.bottom, b.bottom),
      left: StyledBorderSide.merge(a.left, b.left),
    );
  }

  @override
  EdgeInsetsGeometry get dimensions {
    if (_widthIsUniform) {
      return EdgeInsets.all(top.strokeInset);
    }
    return EdgeInsets.fromLTRB(
      left.strokeInset,
      top.strokeInset,
      right.strokeInset,
      bottom.strokeInset,
    );
  }

  @override
  bool get isUniform =>
      _colorIsUniform &&
      _widthIsUniform &&
      _styleIsUniform &&
      _strokeAlignIsUniform &&
      _dashStyleIsUniform &&
      _gradientIsUniform;

  bool get _colorIsUniform {
    final Color topColor = top.color;
    return left.color == topColor &&
        bottom.color == topColor &&
        right.color == topColor;
  }

  bool get _widthIsUniform {
    final double topWidth = top.width;
    return left.width == topWidth &&
        bottom.width == topWidth &&
        right.width == topWidth;
  }

  bool get _styleIsUniform {
    final BorderStyle topStyle = top.style;
    return left.style == topStyle &&
        bottom.style == topStyle &&
        right.style == topStyle;
  }

  bool get _strokeAlignIsUniform {
    final double topStrokeAlign = top.strokeAlign;
    return left.strokeAlign == topStrokeAlign &&
        bottom.strokeAlign == topStrokeAlign &&
        right.strokeAlign == topStrokeAlign;
  }

  bool get _dashStyleIsUniform {
    final topDashStyle = top.dashStyle;
    return left.dashStyle == topDashStyle &&
        bottom.dashStyle == topDashStyle &&
        right.dashStyle == topDashStyle;
  }

  bool get _gradientIsUniform {
    final topGradient = top.gradient;
    return left.gradient == topGradient &&
        bottom.gradient == topGradient &&
        right.gradient == topGradient;
  }

  @override
  StyledBoxBorder? add(ShapeBorder other, {bool reversed = false}) {
    if (other is StyledBoxBorder &&
        BorderSide.canMerge(top, other.top) &&
        BorderSide.canMerge(right, other.right) &&
        BorderSide.canMerge(bottom, other.bottom) &&
        BorderSide.canMerge(left, other.left)) {
      return StyledBoxBorder.merge(this, other);
    }
    return null;
  }

  @override
  StyledBoxBorder scale(double t) => StyledBoxBorder(
        top: top.scale(t),
        right: right.scale(t),
        bottom: bottom.scale(t),
        left: left.scale(t),
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is StyledBoxBorder) {
      return StyledBoxBorder.lerp(a, this, t);
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is StyledBoxBorder) {
      return StyledBoxBorder.lerp(this, b, t);
    }
    return super.lerpTo(b, t);
  }

  /// Linearly interpolate between two borders.
  ///
  /// If a border is null, it is treated as having four [StyledBorderSide.none]
  /// borders.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static StyledBoxBorder? lerp(
      StyledBoxBorder? a, StyledBoxBorder? b, double t) {
    if (identical(a, b)) {
      return a;
    }
    if (a == null) {
      return b!.scale(t);
    }
    if (b == null) {
      return a.scale(1.0 - t);
    }
    return StyledBoxBorder(
      top: StyledBorderSide.lerp(a.top, b.top, t),
      right: StyledBorderSide.lerp(a.right, b.right, t),
      bottom: StyledBorderSide.lerp(a.bottom, b.bottom, t),
      left: StyledBorderSide.lerp(a.left, b.left, t),
    );
  }

  /// Paints the border within the given [Rect] on the given [Canvas].
  ///
  /// Uniform borders and non-uniform borders with similar colors and styles
  /// are more efficient to paint than more complex borders.
  ///
  /// You can provide a [BoxShape] to draw the border on. If the `shape` in
  /// [BoxShape.circle], there is the requirement that the border has uniform
  /// color and style.
  ///
  /// If you specify a rectangular box shape ([BoxShape.rectangle]), then you
  /// may specify a [BorderRadius]. If a `borderRadius` is specified, there is
  /// the requirement that the border has uniform color and style.
  ///
  /// The [getInnerPath] and [getOuterPath] methods do not know about the
  /// `shape` and `borderRadius` arguments.
  ///
  /// The `textDirection` argument is not used by this paint method.
  ///
  /// See also:
  ///
  ///  * [paintBorder], which is used if the border has non-uniform colors or styles and no borderRadius.
  ///  * <https://pub.dev/packages/non_uniform_border>, a package that implements
  ///    a Non-Uniform Border on ShapeBorder, which is used by Material Design
  ///    buttons and other widgets, under the "shape" field.
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    if (isUniform) {
      Path? path;
      switch (top.style) {
        case BorderStyle.none:
          break;
        case BorderStyle.solid:
          switch (shape) {
            case BoxShape.circle:
              assert(
                borderRadius == null,
                'A borderRadius cannot be given when shape is a BoxShape.circle.',
              );

              path = _paintUniformBorderWithCircle(rect, top);
              break;
            case BoxShape.rectangle:
              if (borderRadius != null && borderRadius != BorderRadius.zero) {
                path = _paintUniformBorderWithRadius(rect, top, borderRadius);
              } else {
                path = _paintUniformBorderWithRectangle(rect, top);
              }
          }
      }
      if (path != null) {
        _paintMetrics(canvas, path, top);
      }
      return;
    }

    assert(() {
      if (shape != BoxShape.rectangle ||
          (borderRadius != BorderRadius.zero && borderRadius != null)) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'A Border can only be drawn as a circle on borders with uniform colors.',
          ),
          ErrorDescription('The following is not uniform:'),
          if (!_colorIsUniform) ErrorDescription('BorderSide.color'),
        ]);
      }
      return true;
    }());

    paintBorder(
      canvas,
      rect,
      top: top,
      right: right,
      bottom: bottom,
      left: left,
    );
  }

  void paintBorder(
    Canvas canvas,
    Rect rect, {
    StyledBorderSide top = StyledBorderSide.none,
    StyledBorderSide right = StyledBorderSide.none,
    StyledBorderSide bottom = StyledBorderSide.none,
    StyledBorderSide left = StyledBorderSide.none,
  }) {
    // We draw the borders as filled shapes, unless the borders are hairline
    // borders, in which case we use PaintingStyle.stroke, with the stroke width
    // specified here.
    final Paint paint = Paint()
      ..strokeWidth = 0.0
      ..style = PaintingStyle.stroke;

    switch (top.style) {
      case BorderStyle.solid:
        final topY = rect.top - top.strokeOffset / 2;
        final path = Path()
          ..reset()
          ..moveTo(rect.left, topY)
          ..lineTo(rect.right, topY);

        _paintSide(canvas, path, top, paint);
        break;
      case BorderStyle.none:
        break;
    }

    switch (right.style) {
      case BorderStyle.solid:
        final rightX = rect.right + right.strokeOffset / 2;

        final path = Path()
          ..moveTo(rightX, rect.top)
          ..lineTo(rightX, rect.bottom);

        _paintSide(canvas, path, right, paint);
        break;
      case BorderStyle.none:
        break;
    }

    switch (bottom.style) {
      case BorderStyle.solid:
        final bottomY = rect.bottom + bottom.strokeOffset / 2;
        final path = Path()
          ..moveTo(rect.right, bottomY)
          ..lineTo(rect.left, bottomY);

        _paintSide(canvas, path, bottom, paint);
        break;
      case BorderStyle.none:
        break;
    }

    switch (left.style) {
      case BorderStyle.solid:
        final leftX = rect.left - left.strokeOffset / 2;
        final path = Path()
          ..moveTo(leftX, rect.bottom)
          ..lineTo(leftX, rect.top);

        _paintSide(canvas, path, left, paint);
        break;
      case BorderStyle.none:
        break;
    }
  }

  void _paintSide(
    Canvas canvas,
    Path path,
    StyledBorderSide side,
    Paint paint,
  ) {
    paint
      ..color = side.color
      ..strokeWidth = side.width
      ..shader = side.gradient?.createShader(path.getBounds());

    final dash = side.dashStyle;

    if (dash == null || dash.array.isEmpty) {
      canvas.drawPath(path, paint);
    } else if (dash == BorderDash.none) {
    } else {
      paint.strokeCap = dash.strokeCap;
      final dashes = dash.array;
      final w = side.width;
      final l = dashes.length;
      var dPointer = 0;
      bool isSkip = false;
      for (final m in path.computeMetrics()) {
        for (double i = 0; i < m.length;) {
          final cl = dashes[dPointer];
          dPointer++;
          if (dPointer >= l) dPointer = 0;
          if (cl > 0) {
            final dl = cl * w;
            if (i + dl > m.length) {
              if (!isSkip) {
                canvas.drawPath(
                  m.extractPath(i + w / 2, m.length - i - w / 2),
                  paint,
                );
              }
              isSkip = !isSkip;
              break;
            } else {
              if (!isSkip) {
                canvas.drawPath(
                  m.extractPath(i + w / 2, i + dl - w / 2),
                  paint,
                );
              }
              i += dl;
            }
          }
          isSkip = !isSkip;
        }
      }
    }
  }

  @override
  String toString() {
    if (isUniform) {
      return '${objectRuntimeType(this, 'StyledBoxBorder')}.all($top)';
    }
    final List<String> arguments = <String>[
      if (top != StyledBorderSide.none) 'top: $top',
      if (right != StyledBorderSide.none) 'right: $right',
      if (bottom != StyledBorderSide.none) 'bottom: $bottom',
      if (left != StyledBorderSide.none) 'left: $left',
    ];
    return '${objectRuntimeType(this, 'StyledBoxBorder')}(${arguments.join(", ")})';
  }
}

Path _paintUniformBorderWithCircle(
  Rect rect,
  StyledBorderSide side,
) {
  assert(side.style != BorderStyle.none);
  final diameter = rect.shortestSide + side.strokeOffset;

  return Path()
    ..addOval(
      Rect.fromCenter(
        center: rect.center,
        width: diameter,
        height: diameter,
      ),
    );
}

Path _paintUniformBorderWithRectangle(
  Rect rect,
  StyledBorderSide side,
) {
  assert(side.style != BorderStyle.none);

  return Path()..addRect(rect.inflate(side.strokeOffset / 2));
}

Path _paintUniformBorderWithRadius(
  Rect rect,
  StyledBorderSide side,
  BorderRadius borderRadius,
) {
  final double deflate = side.width * side.strokeAlign / 2;
  return Path()
    ..addRRect(
      borderRadius.toRRect(rect.inflate(deflate)),
    );
}

void _paintMetrics(
  Canvas canvas,
  Path path,
  StyledBorderSide side,
) {
  final paint = side.toPaint()
    ..shader = side.gradient?.createShader(path.getBounds());

  final dash = side.dashStyle;
  if (dash == null || dash.array.isEmpty) {
    canvas.drawPath(path, paint);
  } else if (dash == BorderDash.none) {
  } else {
    paint.strokeCap = dash.strokeCap;
    final dashes = dash.array;
    final w = side.width;
    final l = dashes.length;
    var dPointer = 0;
    bool isSkip = false;
    for (final m in path.computeMetrics()) {
      for (double i = 0; i < m.length;) {
        final cl = dashes[dPointer];
        dPointer++;
        if (dPointer >= l) dPointer = 0;
        if (cl > 0) {
          final dl = cl * w;
          if (i + dl > m.length) {
            if (!isSkip) {
              canvas.drawPath(
                m.extractPath(i + w / 2, m.length - i - w / 2),
                paint,
              );
            }
            isSkip = !isSkip;
            break;
          } else {
            if (!isSkip) {
              canvas.drawPath(m.extractPath(i + w / 2, i + dl - w / 2), paint);
            }
            i += dl;
          }
        }
        isSkip = !isSkip;
      }
    }
  }
}
