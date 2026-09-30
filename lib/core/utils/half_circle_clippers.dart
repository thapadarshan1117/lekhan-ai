import 'package:flutter/material.dart';
import 'dart:math' as math;

class HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Define the rectangle bounds of the semi-circle
    Rect rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );
    // Use arcTo to draw a semi-circle. The start angle is π/2 radians (90 degrees),
    // and the sweep angle is π radians (180 degrees) to create a half circle.
    // The last parameter is set to false because we are not using the arc to create a closed path.
    path.arcTo(rect, 0, math.pi, false);
    // Close the path to form the semi-circle
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; // Return true if the clip path can change on each invocation of the `clipper`.
  }
}