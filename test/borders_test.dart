import 'package:borders/borders.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('borders', () {
    const circle8 = Radius.circular(8);
    const circle4 = Radius.circular(4);
    const elliptical84 = Radius.elliptical(8, 4);
    const elliptical48 = Radius.elliptical(4, 8);
    const circle100 = Radius.circular(100);
    const elliptical100 = Radius.elliptical(100, 50);
    tryDrawRect(
      circle4,
      circle4,
      circle8,
      circle8,
      Offset.zero,
      const Offset(8, 8),
      const Offset(0, 8),
      const Offset(8, 0),
    );
  });
}

void tryDrawRect(
  Radius tlRadius,
  Radius trRadius,
  Radius brRadius,
  Radius blRadius,
  Offset topLeftOffset,
  Offset topRightOffset,
  Offset bottomRightOffset,
  Offset bottomLeftOffset,
) {
  const rect = Rect.fromLTWH(100, 100, 100, 100);

  final topLeft = Offset(
    rect.left - topLeftOffset.dx,
    rect.top - topLeftOffset.dy,
  );
  final topRight = Offset(
    rect.right + topRightOffset.dx,
    rect.top - topRightOffset.dy,
  );
  final bottomRight = Offset(
    rect.right + bottomRightOffset.dx,
    rect.bottom + bottomRightOffset.dy,
  );
  final bottomLeft = Offset(
    rect.left - bottomLeftOffset.dx,
    rect.bottom + bottomLeftOffset.dy,
  );

  final topAngle = (topRight.dy - topLeft.dy) / (topRight.dx - topLeft.dx);
  final rightAngle =
      (bottomRight.dy - topRight.dy) / (bottomRight.dx - topRight.dx);
  final bottomAngle =
      (bottomRight.dy - bottomLeft.dy) / (bottomRight.dx - bottomLeft.dx);
  final leftAngle = (topLeft.dy - bottomLeft.dy) / (topLeft.dx - bottomLeft.dx);

  final path = Path();

  if (tlRadius == Radius.zero) {
    path.moveTo(topLeft.dx, topLeft.dy);
  } else {
    final ptl = getPoints(
      tlRadius.x,
      tlRadius.y,
      topLeft.dx,
      topLeft.dy,
      leftAngle,
      topAngle,
      Alignment.bottomRight,
    );
    print('top left: ${ptl}');
    path.moveTo(ptl.start.dx, ptl.start.dy);
    path.arcToPoint(ptl.stop, radius: tlRadius);
  }

  if (trRadius == Radius.zero) {
    path.lineTo(topRight.dx, topRight.dy);
  } else {
    final ptr = getPoints(
      trRadius.x,
      trRadius.y,
      topRight.dx,
      topRight.dy,
      rightAngle,
      topAngle,
      Alignment.bottomLeft,
    );
    print('top right: ${ptr}');
    path.lineTo(ptr.stop.dx, ptr.stop.dy);

    path.arcToPoint(ptr.start, radius: trRadius);
  }

  if (brRadius == Radius.zero) {
    path.lineTo(bottomRight.dx, bottomRight.dy);
  } else {
    final pbr = getPoints(
      brRadius.x,
      brRadius.y,
      bottomRight.dx,
      bottomRight.dy,
      rightAngle,
      bottomAngle,
      Alignment.topLeft,
    );
    print('bottom right: ${pbr}');
    path.lineTo(pbr.start.dx, pbr.start.dy);
    path.arcToPoint(pbr.stop, radius: brRadius);
  }

  if (blRadius == Radius.zero) {
    path.lineTo(bottomLeft.dx, bottomLeft.dy);
  } else {
    final pbl = getPoints(
      blRadius.x,
      blRadius.y,
      bottomLeft.dx,
      bottomLeft.dy,
      leftAngle,
      bottomAngle,
      Alignment.topRight,
    );
    print('bottom left: ${pbl}');
    path.lineTo(pbl.stop.dx, pbl.stop.dy);

    path.arcToPoint(pbl.start, radius: blRadius);
  }

  path.close();
}
