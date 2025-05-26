import 'dart:math' as math;
import 'dart:ui';

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

  static PolygonRadius lerp(PolygonRadius a, PolygonRadius b, double t) =>
      PolygonRadius(
        Map.fromEntries(
          b._radius.entries.map(
            (e) => MapEntry(e.key, Radius.lerp(a[e.key], e.value, t)!),
          ),
        ),
        Radius.lerp(a._default, b._default, t)!,
      );
}

/// Polygon Border.
/// vertices alignment based on [Rect].
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
      vertexes.map((e) => e.withinRect(rect)).toList();

  /// for debug
  final path3 = Path();
  final cpoints = <int, Offset>{};

  Path _getPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path();
    if (_isDebug) {
      path3.reset();
      cpoints.clear();
    }
    final offsets = getVertexes(rect);
    var lastOffset = offsets.last;
    final fslope = math.atan2(
      offsets.first.dy - lastOffset.dy,
      offsets.first.dx - lastOffset.dx,
    );
    var slope = fslope;

    for (final oe in offsets.indexed) {
      final radius = borderRadius[oe.$1];

      final double nslope;
      if (oe.$1 >= offsets.length - 1) {
        nslope = fslope;
      } else {
        final next = offsets[oe.$1 + 1];
        nslope = math.atan2(
          next.dy - oe.$2.dy,
          next.dx - oe.$2.dx,
        );
      }
      if (radius == Radius.zero || slope == nslope) {
        if (oe.$1 == 0) {
          path.moveTo(oe.$2.dx, oe.$2.dy);
        } else {
          path.lineTo(oe.$2.dx, oe.$2.dy);
        }
        if (_isDebug) path3.moveTo(oe.$2.dx, oe.$2.dy);
      } else {
        final ptl = getPoints(
          radius,
          oe.$2,
          slope,
          nslope,
        );
        if (oe.$1 == 0) {
          path.moveTo(ptl.start.dx, ptl.start.dy);
        } else {
          path.lineTo(ptl.start.dx, ptl.start.dy);
        }
        path.arcToPoint(ptl.stop, radius: radius, largeArc: ptl.isLarge);
        if (_isDebug) {
          path3.moveTo(ptl.center.dx, ptl.center.dy);
          cpoints[oe.$1] = ptl.center;
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
          final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
          for (final o in offsets.skip(1)) {
            path.lineTo(o.dx, o.dy);
          }
          path.close();

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

          for (final e in cpoints.entries) {
            canvas.drawCircle(
              e.value,
              borderRadius[e.key].x,
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
        ),
        vertexes: List.generate(
          lerpDouble(
            a.vertexes.length.toDouble(),
            vertexes.length.toDouble(),
            t,
          )!
              .round(),
          (i) => Alignment.lerp(
            a.vertexes.length > i ? a.vertexes[i] : null,
            vertexes.length > i ? vertexes[i] : null,
            t,
          )!,
        ),
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
        ),
        vertexes: List.generate(
          lerpDouble(
            vertexes.length.toDouble(),
            b.vertexes.length.toDouble(),
            t,
          )!
              .round(),
          (i) => Alignment.lerp(
            vertexes.length > i ? vertexes[i] : null,
            b.vertexes.length > i ? b.vertexes[i] : null,
            t,
          )!,
        ),
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
