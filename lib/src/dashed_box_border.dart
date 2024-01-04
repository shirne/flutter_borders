// ignore_for_file: overridden_fields

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'common.dart';
import 'ui/styled_border_side.dart';

/// A dashed border use for [BoxDecoration]
class DashedBoxBorder extends Border {
  /// Creates a border.
  ///
  /// All the sides of the border default to [StyledBorderSide.none].
  ///
  /// The arguments must not be null.
  const DashedBoxBorder({
    this.top = StyledBorderSide.none,
    this.right = StyledBorderSide.none,
    this.bottom = StyledBorderSide.none,
    this.left = StyledBorderSide.none,
  });

  /// Creates a border whose sides are all the same.
  ///
  /// The `side` argument must not be null.
  const DashedBoxBorder.fromBorderSide(StyledBorderSide side)
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
  /// All arguments default to [StyledBorderSide.none] and must not be null.
  const DashedBoxBorder.symmetric({
    StyledBorderSide vertical = StyledBorderSide.none,
    StyledBorderSide horizontal = StyledBorderSide.none,
  }) : this(
          left: vertical,
          top: horizontal,
          right: vertical,
          bottom: horizontal,
        );

  /// A uniform border with all sides the same color and width.
  ///
  /// The sides default to black solid borders, one logical pixel wide.
  factory DashedBoxBorder.all({
    Color color = const Color(0xFF000000),
    double width = 1.0,
    BorderStyle style = BorderStyle.solid,
    double strokeAlign = BorderSide.strokeAlignInside,
    BorderDash? dashStyle,
  }) {
    final side = StyledBorderSide(
      color: color,
      width: width,
      style: style,
      strokeAlign: strokeAlign,
      dashStyle: dashStyle,
    );
    return DashedBoxBorder.fromBorderSide(side);
  }

  @override
  final StyledBorderSide left;
  @override
  final StyledBorderSide top;
  @override
  final StyledBorderSide right;
  @override
  final StyledBorderSide bottom;

  /// Creates a [DashedBoxBorder] that represents the addition of the two given
  /// [DashedBoxBorder]s.
  ///
  /// It is only valid to call this if [BorderSide.canMerge] returns true for
  /// the pairwise combination of each side on both [DashedBoxBorder]s.
  ///
  /// The arguments must not be null.
  static DashedBoxBorder merge(DashedBoxBorder a, DashedBoxBorder b) {
    assert(BorderSide.canMerge(a.top, b.top));
    assert(BorderSide.canMerge(a.right, b.right));
    assert(BorderSide.canMerge(a.bottom, b.bottom));
    assert(BorderSide.canMerge(a.left, b.left));
    return DashedBoxBorder(
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
      _dashStyleIsUniform;

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

  @override
  DashedBoxBorder? add(ShapeBorder other, {bool reversed = false}) {
    if (other is DashedBoxBorder &&
        BorderSide.canMerge(top, other.top) &&
        BorderSide.canMerge(right, other.right) &&
        BorderSide.canMerge(bottom, other.bottom) &&
        BorderSide.canMerge(left, other.left)) {
      return DashedBoxBorder.merge(this, other);
    }
    return null;
  }

  @override
  DashedBoxBorder scale(double t) => DashedBoxBorder(
        top: top.scale(t),
        right: right.scale(t),
        bottom: bottom.scale(t),
        left: left.scale(t),
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is DashedBoxBorder) {
      return DashedBoxBorder.lerp(a, this, t);
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is DashedBoxBorder) {
      return DashedBoxBorder.lerp(this, b, t);
    }
    return super.lerpTo(b, t);
  }

  /// Linearly interpolate between two borders.
  ///
  /// If a border is null, it is treated as having four [StyledBorderSide.none]
  /// borders.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static DashedBoxBorder? lerp(
    DashedBoxBorder? a,
    DashedBoxBorder? b,
    double t,
  ) {
    if (identical(a, b)) {
      return a;
    }
    if (a == null) {
      return b!.scale(t);
    }
    if (b == null) {
      return a.scale(1.0 - t);
    }
    return DashedBoxBorder(
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

    throw UnsupportedError('Unsupport ununiformed border paint yet.');
  }

  @override
  String toString() {
    if (isUniform) {
      return '${objectRuntimeType(this, 'DashedBoxBorder')}.all($top)';
    }
    final List<String> arguments = <String>[
      if (top != StyledBorderSide.none) 'top: $top',
      if (right != StyledBorderSide.none) 'right: $right',
      if (bottom != StyledBorderSide.none) 'bottom: $bottom',
      if (left != StyledBorderSide.none) 'left: $left',
    ];
    return '${objectRuntimeType(this, 'DashedBoxBorder')}(${arguments.join(", ")})';
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
      BorderRadius.only(
        topLeft: borderRadius.topLeft.inflate(deflate),
        topRight: borderRadius.topRight.inflate(deflate),
        bottomLeft: borderRadius.bottomLeft.inflate(deflate),
        bottomRight: borderRadius.bottomRight.inflate(deflate),
      ).toRRect(rect),
    );
}

void _paintMetrics(
  Canvas canvas,
  Path path,
  StyledBorderSide side,
) {
  final paint = side.toPaint();

  final dash = side.dashStyle;
  if (dash == null || dash.array.isEmpty) {
    canvas.drawPath(path, paint);
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
