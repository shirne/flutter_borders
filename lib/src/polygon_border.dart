import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'options/corner_radius.dart';

bool _isDebug = false;

class PolygonRadius {
  const PolygonRadius(Map<int, Radius> allRadius, [Radius radius = Radius.zero])
      : _radius = allRadius,
        _default = radius;

  const PolygonRadius.all(Radius radius)
      : _radius = const {},
        _default = radius;

  static const PolygonRadius zero = PolygonRadius({});

  final Map<int, Radius> _radius;
  final Radius _default;

  Radius operator [](int index) => _radius[index] ?? _default;
  PolygonRadius operator *(double t) => PolygonRadius(
        Map.fromEntries(
          _radius.entries.map((e) => MapEntry(e.key, e.value * t)),
        ),
        _default * t,
      );
}

/// Irregular quadrilateral border, such as trapezoid,prisms.
/// [Offset] four vertices based on [Rect].
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
class PolygonBorder extends OutlinedBorder {
  PolygonBorder({
    required this.vertexes,
    this.borderRadius = PolygonRadius.zero,
    super.side,
  }) : assert(vertexes.length > 2, 'vertexes must more then 2.');

  static set isDebug(bool d) => _isDebug = d;

  final List<Alignment> vertexes;
  final PolygonRadius borderRadius;

  @override
  PolygonBorder copyWith({BorderSide? side, List<Alignment>? vertexes}) =>
      PolygonBorder(
        vertexes: vertexes ?? this.vertexes,
        side: side ?? this.side,
      );

  List<Offset> getVertexes(Rect rect) =>
      vertexes.map((e) => Offset(e.x, e.y)).toList();

  /// for debug
  final path3 = Path();
  final cpoints = <String, Offset>{};

  Path _getPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    if (_isDebug) {
      path3.reset();
      cpoints.clear();
    }
    final offsets = getVertexes(rect);
    var lastOffset = offsets.last;
    var slope = math.atan2(
      offsets.first.dy - lastOffset.dy,
      offsets.first.dx - lastOffset.dx,
    );

    for (final oe in offsets.indexed) {
      final radius = borderRadius[oe.$1];
      final nslope = math.atan2(
        oe.$2.dy - lastOffset.dy,
        oe.$2.dx - lastOffset.dx,
      );
      if (radius == Radius.zero || slope == nslope) {
        path.moveTo(offsets.topLeft.dx, offsets.topLeft.dy);
        if (_isDebug) path3.moveTo(offsets.topLeft.dx, offsets.topLeft.dy);
      } else {
        final ptl = getPoints(
          tlRadius,
          offsets.topLeft,
          lSlope,
          tSlope,
        );

        path.moveTo(ptl.start.dx, ptl.start.dy);
        path.arcToPoint(ptl.stop, radius: tlRadius, largeArc: ptl.isLarge);
        if (_isDebug) {
          path3.moveTo(ptl.center.dx, ptl.center.dy);
          cpoints['top-left'] = ptl.center;
        }
      }

      lastOffset = oe.$2;
      slope = nslope;
    }

    path.close();
    if (_isDebug) path3.close();

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

        //  for debug
        if (_isDebug) {
          final offsets = getVertexes(rect);
          final path = Path()
            ..moveTo(offsets.topLeft.dx, offsets.topLeft.dy)
            ..lineTo(offsets.topRight.dx, offsets.topRight.dy)
            ..lineTo(offsets.bottomRight.dx, offsets.bottomRight.dy)
            ..lineTo(offsets.bottomLeft.dx, offsets.bottomLeft.dy)
            ..close();

          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.fill
              ..color = const Color(0x20FF0000),
          );
          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = const Color(0xA0FF0000),
          );

          if (!path3.getBounds().isEmpty) {
            canvas.drawPath(
              path3,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1
                ..color = const Color(0xA00000FF),
            );
          }
          final radius = borderRadius.resolve(textDirection);
          for (final e in cpoints.entries) {
            canvas.drawCircle(
              e.value,
              radius.topLeft.x,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1
                ..color = const Color(0xA0FF0000),
            );
          }
        }
    }
  }

  @override
  PolygonBorder scale(double t) => PolygonBorder(
        side: side.scale(t),
        vertexes: vertexes,
        borderRadius: borderRadius * t,
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is PolygonBorder) {
      return PolygonBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius: PolygonRadius.lerp(
          a.borderRadius,
          borderRadius,
          t,
        )!,
        vertexes: BorderOffset.lerp(a.borderOffset, borderOffset, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is PolygonBorder) {
      return PolygonBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius: PolygonRadius.lerp(
          borderRadius,
          b.borderRadius,
          t,
        )!,
        vertexes: BorderOffset.lerp(borderOffset, b.borderOffset, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is PolygonBorder &&
        other.side == side &&
        other.vertexes == vertexes &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(side, borderRadius, vertexes);

  @override
  String toString() => '${objectRuntimeType(this, 'PolygonBorder')}'
      '($side, $borderRadius, $vertexes)';
}
