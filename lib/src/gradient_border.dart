// ignore_for_file: overridden_fields

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'ui/gradient_border_side.dart';

class GradientBorder extends Border {
  /// Creates a border.
  ///
  /// All the sides of the border default to [GradientBorderSide.none].
  ///
  /// The arguments must not be null.
  const GradientBorder({
    this.top = GradientBorderSide.none,
    this.right = GradientBorderSide.none,
    this.bottom = GradientBorderSide.none,
    this.left = GradientBorderSide.none,
  });

  /// Creates a border whose sides are all the same.
  ///
  /// The `side` argument must not be null.
  const GradientBorder.fromBorderSide(GradientBorderSide side)
      : this(
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
  /// All arguments default to [GradientBorderSide.none] and must not be null.
  const GradientBorder.symmetric({
    GradientBorderSide vertical = GradientBorderSide.none,
    GradientBorderSide horizontal = GradientBorderSide.none,
  }) : this(
          left: vertical,
          top: horizontal,
          right: vertical,
          bottom: horizontal,
        );

  /// A uniform border with all sides the same color and width.
  ///
  /// The sides default to black solid borders, one logical pixel wide.
  factory GradientBorder.all({
    Color color = const Color(0xFF000000),
    double width = 1.0,
    BorderStyle style = BorderStyle.solid,
    double strokeAlign = BorderSide.strokeAlignInside,
    Gradient? gradient,
  }) {
    final side = GradientBorderSide(
      color: color,
      width: width,
      style: style,
      strokeAlign: strokeAlign,
      gradient: gradient,
    );
    return GradientBorder.fromBorderSide(side);
  }

  @override
  final GradientBorderSide left;
  @override
  final GradientBorderSide top;
  @override
  final GradientBorderSide right;
  @override
  final GradientBorderSide bottom;

  /// Creates a [GradientBorder] that represents the addition of the two given
  /// [GradientBorder]s.
  ///
  /// It is only valid to call this if [BorderSide.canMerge] returns true for
  /// the pairwise combination of each side on both [GradientBorder]s.
  ///
  /// The arguments must not be null.
  static GradientBorder merge(GradientBorder a, GradientBorder b) {
    assert(BorderSide.canMerge(a.top, b.top));
    assert(BorderSide.canMerge(a.right, b.right));
    assert(BorderSide.canMerge(a.bottom, b.bottom));
    assert(BorderSide.canMerge(a.left, b.left));
    return GradientBorder(
      top: GradientBorderSide.merge(a.top, b.top),
      right: GradientBorderSide.merge(a.right, b.right),
      bottom: GradientBorderSide.merge(a.bottom, b.bottom),
      left: GradientBorderSide.merge(a.left, b.left),
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

  bool get _gradientIsUniform {
    final topGradient = top.gradient;
    return left.gradient == topGradient &&
        bottom.gradient == topGradient &&
        right.gradient == topGradient;
  }

  @override
  GradientBorder? add(ShapeBorder other, {bool reversed = false}) {
    if (other is GradientBorder &&
        BorderSide.canMerge(top, other.top) &&
        BorderSide.canMerge(right, other.right) &&
        BorderSide.canMerge(bottom, other.bottom) &&
        BorderSide.canMerge(left, other.left)) {
      return GradientBorder.merge(this, other);
    }
    return null;
  }

  @override
  GradientBorder scale(double t) => GradientBorder(
        top: top.scale(t),
        right: right.scale(t),
        bottom: bottom.scale(t),
        left: left.scale(t),
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is GradientBorder) {
      return GradientBorder.lerp(a, this, t);
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is GradientBorder) {
      return GradientBorder.lerp(this, b, t);
    }
    return super.lerpTo(b, t);
  }

  /// Linearly interpolate between two borders.
  ///
  /// If a border is null, it is treated as having four [GradientBorder.none]
  /// borders.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static GradientBorder? lerp(GradientBorder? a, GradientBorder? b, double t) {
    if (identical(a, b)) {
      return a;
    }
    if (a == null) {
      return b!.scale(t);
    }
    if (b == null) {
      return a.scale(1.0 - t);
    }
    return GradientBorder(
      top: GradientBorderSide.lerp(a.top, b.top, t),
      right: GradientBorderSide.lerp(a.right, b.right, t),
      bottom: GradientBorderSide.lerp(a.bottom, b.bottom, t),
      left: GradientBorderSide.lerp(a.left, b.left, t),
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
      switch (top.style) {
        case BorderStyle.none:
          return;
        case BorderStyle.solid:
          switch (shape) {
            case BoxShape.circle:
              assert(
                borderRadius == null,
                'A borderRadius cannot be given when shape is a BoxShape.circle.',
              );
              _paintUniformBorderWithCircle(canvas, rect, top);
              break;
            case BoxShape.rectangle:
              if (borderRadius != null && borderRadius != BorderRadius.zero) {
                _paintUniformBorderWithRadius(canvas, rect, top, borderRadius);
                return;
              }
              _paintUniformBorderWithRectangle(canvas, rect, top);
          }
          return;
      }
    }

    // Allow painting non-uniform borders if the color and style are uniform.
    if (_colorIsUniform && _styleIsUniform && _gradientIsUniform) {
      switch (top.style) {
        case BorderStyle.none:
          return;
        case BorderStyle.solid:
          _paintNonUniformBorder(
            canvas,
            rect,
            shape: shape,
            borderRadius: borderRadius,
            textDirection: textDirection,
            left: left,
            top: top,
            right: right,
            bottom: bottom,
          );
          return;
      }
    }

    assert(() {
      if (borderRadius != null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'A borderRadius can only be given on borders with uniform colors and styles.',
          ),
          ErrorDescription('The following is not uniform:'),
          if (!_colorIsUniform) ErrorDescription('BorderSide.color'),
          if (!_styleIsUniform) ErrorDescription('BorderSide.style'),
        ]);
      }
      return true;
    }());
    assert(() {
      if (shape != BoxShape.rectangle) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'A Border can only be drawn as a circle on borders with uniform colors and styles.',
          ),
          ErrorDescription('The following is not uniform:'),
          if (!_colorIsUniform) ErrorDescription('BorderSide.color'),
          if (!_styleIsUniform) ErrorDescription('BorderSide.style'),
        ]);
      }
      return true;
    }());
    assert(() {
      if (!_strokeAlignIsUniform ||
          top.strokeAlign != BorderSide.strokeAlignInside) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'A Border can only draw strokeAlign different than BorderSide.strokeAlignInside on borders with uniform colors and styles.',
          ),
        ]);
      }
      return true;
    }());

    _paintBorder(
      canvas,
      rect,
      top: top,
      right: right,
      bottom: bottom,
      left: left,
    );
  }

  @override
  String toString() {
    if (isUniform) {
      return '${objectRuntimeType(this, 'GradientBorder')}.all($top)';
    }
    final List<String> arguments = <String>[
      if (top != GradientBorderSide.none) 'top: $top',
      if (right != GradientBorderSide.none) 'right: $right',
      if (bottom != GradientBorderSide.none) 'bottom: $bottom',
      if (left != GradientBorderSide.none) 'left: $left',
    ];
    return '${objectRuntimeType(this, 'GradientBorder')}(${arguments.join(", ")})';
  }
}

void _paintBorder(
  Canvas canvas,
  Rect rect, {
  GradientBorderSide top = GradientBorderSide.none,
  GradientBorderSide right = GradientBorderSide.none,
  GradientBorderSide bottom = GradientBorderSide.none,
  GradientBorderSide left = GradientBorderSide.none,
}) {
  // We draw the borders as filled shapes, unless the borders are hairline
  // borders, in which case we use PaintingStyle.stroke, with the stroke width
  // specified here.
  final Paint paint = Paint()..strokeWidth = 0.0;

  final Path path = Path();

  switch (top.style) {
    case BorderStyle.solid:
      paint.color = top.color;
      paint.shader = top.gradient?.createShader(rect);
      path.reset();
      path.moveTo(rect.left, rect.top);
      path.lineTo(rect.right, rect.top);
      if (top.width == 0.0) {
        paint.style = PaintingStyle.stroke;
      } else {
        paint.style = PaintingStyle.fill;
        path.lineTo(rect.right - right.width, rect.top + top.width);
        path.lineTo(rect.left + left.width, rect.top + top.width);
      }
      canvas.drawPath(path, paint);
      break;
    case BorderStyle.none:
      break;
  }

  switch (right.style) {
    case BorderStyle.solid:
      paint.color = right.color;
      paint.shader = right.gradient?.createShader(rect);
      path.reset();
      path.moveTo(rect.right, rect.top);
      path.lineTo(rect.right, rect.bottom);
      if (right.width == 0.0) {
        paint.style = PaintingStyle.stroke;
      } else {
        paint.style = PaintingStyle.fill;
        path.lineTo(rect.right - right.width, rect.bottom - bottom.width);
        path.lineTo(rect.right - right.width, rect.top + top.width);
      }
      canvas.drawPath(path, paint);
      break;
    case BorderStyle.none:
      break;
  }

  switch (bottom.style) {
    case BorderStyle.solid:
      paint.color = bottom.color;
      paint.shader = bottom.gradient?.createShader(rect);
      path.reset();
      path.moveTo(rect.right, rect.bottom);
      path.lineTo(rect.left, rect.bottom);
      if (bottom.width == 0.0) {
        paint.style = PaintingStyle.stroke;
      } else {
        paint.style = PaintingStyle.fill;
        path.lineTo(rect.left + left.width, rect.bottom - bottom.width);
        path.lineTo(rect.right - right.width, rect.bottom - bottom.width);
      }
      canvas.drawPath(path, paint);
      break;
    case BorderStyle.none:
      break;
  }

  switch (left.style) {
    case BorderStyle.solid:
      paint.color = left.color;
      paint.shader = left.gradient?.createShader(rect);
      path.reset();
      path.moveTo(rect.left, rect.bottom);
      path.lineTo(rect.left, rect.top);
      if (left.width == 0.0) {
        paint.style = PaintingStyle.stroke;
      } else {
        paint.style = PaintingStyle.fill;
        path.lineTo(rect.left + left.width, rect.top + top.width);
        path.lineTo(rect.left + left.width, rect.bottom - bottom.width);
      }
      canvas.drawPath(path, paint);
      break;
    case BorderStyle.none:
      break;
  }
}

void _paintUniformBorderWithRadius(
  Canvas canvas,
  Rect rect,
  GradientBorderSide side,
  BorderRadius borderRadius,
) {
  assert(side.style != BorderStyle.none);
  final Paint paint = Paint()
    ..color = side.color
    ..shader = side.gradient?.createShader(rect);
  final double width = side.width;
  if (width == 0.0) {
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.0;
    canvas.drawRRect(borderRadius.toRRect(rect), paint);
  } else {
    final RRect borderRect = borderRadius.toRRect(rect);
    final RRect inner = borderRect.deflate(side.strokeInset);
    final RRect outer = borderRect.inflate(side.strokeOutset);
    canvas.drawDRRect(outer, inner, paint);
  }
}

void _paintNonUniformBorder(
  Canvas canvas,
  Rect rect, {
  required BorderRadius? borderRadius,
  required BoxShape shape,
  required TextDirection? textDirection,
  required GradientBorderSide left,
  required GradientBorderSide top,
  required GradientBorderSide right,
  required GradientBorderSide bottom,
}) {
  final RRect borderRect;
  switch (shape) {
    case BoxShape.rectangle:
      borderRect = (borderRadius ?? BorderRadius.zero)
          .resolve(textDirection)
          .toRRect(rect);
      break;
    case BoxShape.circle:
      assert(
        borderRadius == null,
        'A borderRadius cannot be given when shape is a BoxShape.circle.',
      );
      borderRect = RRect.fromRectAndRadius(
        Rect.fromCircle(center: rect.center, radius: rect.shortestSide / 2.0),
        Radius.circular(rect.width),
      );
  }
  final Paint paint = Paint()
    ..color = top.color
    ..shader = top.gradient?.createShader(rect);
  final RRect inner = _deflateRRect(
    borderRect,
    EdgeInsets.fromLTRB(
      left.strokeInset,
      top.strokeInset,
      right.strokeInset,
      bottom.strokeInset,
    ),
  );
  final RRect outer = _inflateRRect(
    borderRect,
    EdgeInsets.fromLTRB(
      left.strokeOutset,
      top.strokeOutset,
      right.strokeOutset,
      bottom.strokeOutset,
    ),
  );
  canvas.drawDRRect(outer, inner, paint);
}

RRect _inflateRRect(RRect rect, EdgeInsets insets) => RRect.fromLTRBAndCorners(
      rect.left - insets.left,
      rect.top - insets.top,
      rect.right + insets.right,
      rect.bottom + insets.bottom,
      topLeft: (rect.tlRadius + Radius.elliptical(insets.left, insets.top))
          .clamp(minimum: Radius.zero), // ignore_clamp_double_lint
      topRight: (rect.trRadius + Radius.elliptical(insets.right, insets.top))
          .clamp(minimum: Radius.zero), // ignore_clamp_double_lint
      bottomRight:
          (rect.brRadius + Radius.elliptical(insets.right, insets.bottom))
              .clamp(minimum: Radius.zero), // ignore_clamp_double_lint
      bottomLeft:
          (rect.blRadius + Radius.elliptical(insets.left, insets.bottom))
              .clamp(minimum: Radius.zero), // ignore_clamp_double_lint
    );

RRect _deflateRRect(RRect rect, EdgeInsets insets) => RRect.fromLTRBAndCorners(
      rect.left + insets.left,
      rect.top + insets.top,
      rect.right - insets.right,
      rect.bottom - insets.bottom,
      topLeft: (rect.tlRadius - Radius.elliptical(insets.left, insets.top))
          .clamp(minimum: Radius.zero), // ignore_clamp_double_lint
      topRight: (rect.trRadius - Radius.elliptical(insets.right, insets.top))
          .clamp(minimum: Radius.zero), // ignore_clamp_double_lint
      bottomRight:
          (rect.brRadius - Radius.elliptical(insets.right, insets.bottom))
              .clamp(minimum: Radius.zero), // ignore_clamp_double_lint
      bottomLeft:
          (rect.blRadius - Radius.elliptical(insets.left, insets.bottom))
              .clamp(minimum: Radius.zero), // ignore_clamp_double_lint
    );

void _paintUniformBorderWithCircle(
  Canvas canvas,
  Rect rect,
  GradientBorderSide side,
) {
  assert(side.style != BorderStyle.none);
  final double radius = (rect.shortestSide + side.strokeOffset) / 2;
  canvas.drawCircle(
    rect.center,
    radius,
    side.toPaint()..shader = side.gradient?.createShader(rect),
  );
}

void _paintUniformBorderWithRectangle(
  Canvas canvas,
  Rect rect,
  GradientBorderSide side,
) {
  assert(side.style != BorderStyle.none);
  canvas.drawRect(
    rect.inflate(side.strokeOffset / 2),
    side.toPaint()..shader = side.gradient?.createShader(rect),
  );
}
