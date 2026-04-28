import 'package:flutter/material.dart';

class IOSLikeClipper extends CustomClipper<Path> {
  final double radius;

  IOSLikeClipper(this.radius);

  @override
  Path getClip(Size size) {
    final path = Path();

    // Используем кривую, близкую к continuous corner curve
    final r = radius;
    const smoothness = 0.64; // число для приближения Безье

    path.moveTo(0, r);
    path.cubicTo(0, r * (1 - smoothness), r * (1 - smoothness), 0, r, 0);
    path.lineTo(size.width - r, 0);
    path.cubicTo(size.width - r * (1 - smoothness), 0, size.width, r * (1 - smoothness), size.width, r);
    path.lineTo(size.width, size.height - r);
    path.cubicTo(
      size.width,
      size.height - r * (1 - smoothness),
      size.width - r * (1 - smoothness),
      size.height,
      size.width - r,
      size.height,
    );
    path.lineTo(r, size.height);
    path.cubicTo(r * (1 - smoothness), size.height, 0, size.height - r * (1 - smoothness), 0, size.height - r);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(IOSLikeClipper oldClipper) => radius != oldClipper.radius;
}

// class IOSLikeShape extends ShapeBorder {
//   final double radius;
//
//   const IOSLikeShape(this.radius);
//
//   @override
//   Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
//     return IOSLikeClipper(radius).getClip(rect.size);
//   }
//
//   @override
//   EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
//
//   @override
//   ShapeBorder scale(double t) => this;
//
//   @override
//   void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
//
//   @override
//   Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);
// }

class IOSLikeShape extends ShapeBorder {
  final double radius;
  final BorderSide side;

  const IOSLikeShape(
      this.radius, {
        this.side = BorderSide.none,
      });

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final p = IOSLikeClipper(radius).getClip(rect.size);
    return p.shift(rect.topLeft);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder scale(double t) {
    return IOSLikeShape(
      radius * t,
      side: side.scale(t),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side == BorderSide.none) return;

    final paint = side.toPaint()
      ..style = PaintingStyle.stroke;

    final path = getOuterPath(rect, textDirection: textDirection);
    canvas.drawPath(path, paint);
  }
}
