// ignore_for_file: overridden_fields

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'ui/styled_border_side.dart';

/// A dashed border use for [ShapeDecoration]
class StyledBorder extends ShapeBorder {
  /// Creates a border.
  ///
  /// All the sides of the border default to [StyledBorderSide.none].
  const StyledBorder({
    this.side = StyledBorderSide.none,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  });

  final StyledBorderSide side;

  final BoxShape shape;

  final BorderRadius? borderRadius;

  /// Creates a [DashedBorder] that represents the addition of the two given
  /// [DashedBorder]s.
  ///
  /// It is only valid to call this if [BorderSide.canMerge] returns true for
  /// the pairwise combination of each side on both [DashedBorder]s.
  ///
  /// The arguments must not be null.
  static StyledBorder merge(StyledBorder a, StyledBorder b) {
    assert(StyledBorderSide.canMerge(a.side, b.side));
    return StyledBorder(
      side: StyledBorderSide.merge(a.side, b.side),
      shape: a.shape,
      borderRadius: a.borderRadius,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.strokeInset);

  @override
  StyledBorder? add(ShapeBorder other, {bool reversed = false}) {
    if (other is StyledBorder && StyledBorderSide.canMerge(side, other.side)) {
      return StyledBorder.merge(this, other);
    }
    return null;
  }

  @override
  StyledBorder scale(double t) => StyledBorder(
        side: side.scale(t),
        shape: shape,
        borderRadius: borderRadius,
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is StyledBorder) {
      return StyledBorder.lerp(a, this, t);
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is StyledBorder) {
      return StyledBorder.lerp(this, b, t);
    }
    return super.lerpTo(b, t);
  }

  /// Linearly interpolate between two borders.
  ///
  /// If a border is null, it is treated as having four [StyledBorderSide.none]
  /// borders.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static StyledBorder? lerp(StyledBorder? a, StyledBorder? b, double t) {
    if (identical(a, b)) {
      return a;
    }
    if (a == null) {
      return b!.scale(t);
    }
    if (b == null) {
      return a.scale(1.0 - t);
    }
    return StyledBorder(
      side: StyledBorderSide.lerp(a.side, b.side, t),
      shape: t > 0.5 ? b.shape : a.shape,
      borderRadius: BorderRadius.lerp(a.borderRadius, b.borderRadius, t),
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
  }) {
    Path? path;
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        path = Path();
        switch (shape) {
          case BoxShape.circle:
            assert(
              borderRadius == null,
              'A borderRadius cannot be given when shape is a BoxShape.circle.',
            );
            final diameter = rect.shortestSide + side.strokeOffset / 2;

            path.addOval(
              Rect.fromCenter(
                center: rect.center,
                width: diameter,
                height: diameter,
              ),
            );
            break;
          case BoxShape.rectangle:
            if (borderRadius != null && borderRadius != BorderRadius.zero) {
              path.addRRect(
                borderRadius!.toRRect(rect.inflate(side.strokeOffset / 2)),
              );
            } else {
              path.addRect(rect.inflate(side.strokeOffset / 2));
            }
        }
    }
    if (path != null) {
      _paintMetrics(canvas, path, side);
    }
    return;
  }

  @override
  String toString() => '${objectRuntimeType(this, 'StyledBorder')}.all($side)';

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(dimensions.resolve(textDirection).deflateRect(rect));

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    switch (shape) {
      case BoxShape.circle:
        assert(
          borderRadius == null,
          'A borderRadius cannot be given when shape is a BoxShape.circle.',
        );
        final diameter = rect.shortestSide;

        path.addOval(
          Rect.fromCenter(
            center: rect.center,
            width: diameter,
            height: diameter,
          ),
        );
        break;
      case BoxShape.rectangle:
        if (borderRadius != null && borderRadius != BorderRadius.zero) {
          path.addRRect(
            borderRadius!.toRRect(rect),
          );
        } else {
          path.addRect(rect);
        }
    }
    return path;
  }
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
