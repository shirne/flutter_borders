import 'dart:ui';

import 'package:borders/borders.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('borders', () {
    const circle8 = Radius.circular(8);
    const elliptical84 = Radius.elliptical(8, 4);
    const elliptical48 = Radius.elliptical(4, 8);
    const circle100 = Radius.circular(100);
    const elliptical100 = Radius.elliptical(100, 50);
    tryDrawRect(
      elliptical84,
      elliptical84,
      circle8,
      circle8,
      Offset.zero,
      Offset(8, 8),
      Offset(8, 8),
      Offset(8, 8),
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

  final topAngle = topRight.dx == topLeft.dx
      ? 0.0
      : (topRight.dy - topLeft.dy) / (topRight.dx - topLeft.dx);
  final rightAngle = bottomRight.dy == topRight.dy
      ? 0.0
      : (bottomRight.dx - topRight.dx) / (bottomRight.dy - topRight.dy);
  final bottomAngle = bottomRight.dx == bottomLeft.dx
      ? 0.0
      : (bottomRight.dy - bottomLeft.dy) / (bottomRight.dx - bottomLeft.dx);
  final leftAngle = topLeft.dy == bottomLeft.dy
      ? 0.0
      : (topLeft.dx - bottomLeft.dx) / (topLeft.dy - bottomLeft.dy);

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
    );
    print('top left: ${ptl}');
    path.moveTo(ptl[0].dx, ptl[0].dy);
    path.arcToPoint(ptl[1], radius: tlRadius);
  }

  if (trRadius == Radius.zero) {
    path.lineTo(topRight.dx, topRight.dy);
  } else {
    final ptr = getPoints(
      trRadius.x,
      trRadius.y,
      topRight.dx,
      topRight.dy,
      topAngle,
      rightAngle,
    );
    print('top right: ${ptr}');
    path.lineTo(ptr[1].dx, ptr[1].dy);

    path.arcToPoint(ptr[0], radius: trRadius);
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
    );
    print('bottom right: ${pbr}');
    path.lineTo(pbr[0].dx, pbr[0].dy);
    path.arcToPoint(pbr[1], radius: brRadius);
  }

  if (blRadius == Radius.zero) {
    path.lineTo(bottomLeft.dx, bottomLeft.dy);
  } else {
    final pbl = getPoints(
      blRadius.x,
      blRadius.y,
      bottomLeft.dx,
      bottomLeft.dy,
      bottomAngle,
      leftAngle,
    );
    print('bottom left: ${pbl}');
    path.lineTo(pbl[1].dx, pbl[1].dy);

    path.arcToPoint(pbl[0], radius: blRadius);
  }

  path.close();
}
