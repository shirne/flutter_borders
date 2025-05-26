import 'dart:math' as math;
import 'package:flutter/widgets.dart';

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

/// caculate the tangent point of the corner and the radius
CornerRadius getPoints(
  Radius radius,
  Offset corner,
  double k1,
  double k2,
) {
  if (radius.x != radius.y) {
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'Unsupported elliptical radius yet.',
      ),
      ErrorDescription('The following is not circle radius:'),
    ]);
  }

  double? x1;
  double? x2;
  double? y1;
  double? y2;

  /// 切圆的圆心
  double? h;
  double? k;

  final c = (k2 + k1) / 2;
  final r = radius.x / math.cos(c - k1);
  final d = radius.x * math.tan(c - k1).abs();

  h = corner.dx - math.sin(c) * r;
  k = corner.dy + math.cos(c) * r;

  x1 = corner.dx - math.cos(k1) * d;
  y1 = corner.dy - math.sin(k1) * d;
  x2 = corner.dx + math.cos(k2) * d;
  y2 = corner.dy + math.sin(k2) * d;

  return CornerRadius(Offset(x1, y1), Offset(x2, y2), Offset(h, k));
}
