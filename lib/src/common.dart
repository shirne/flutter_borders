import 'dart:ui';

extension RadiusPlus on Radius {
  Radius deflate(double delta) => Radius.elliptical(
        (x - delta).clamp(0, double.infinity),
        (y - delta).clamp(0, double.infinity),
      );

  Radius inflate(double delta) => Radius.elliptical(
        (x + delta).clamp(0, double.infinity),
        (y + delta).clamp(0, double.infinity),
      );
}
