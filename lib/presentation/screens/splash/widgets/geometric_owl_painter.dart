import 'dart:math' as math;
import 'package:flutter/material.dart';

class GeometricOwlPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color glowColor;

  GeometricOwlPainter({
    required this.progress,
    required this.color,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 200;

    // Define all owl paths
    final paths = _createOwlPaths(center, scale);

    // Draw paths with animation
    for (int i = 0; i < paths.length; i++) {
      final pathProgress = ((progress * paths.length) - i).clamp(0.0, 1.0);
      if (pathProgress > 0) {
        final animatedPath = _createAnimatedPath(paths[i], pathProgress);
        canvas.drawPath(animatedPath, glowPaint);
        canvas.drawPath(animatedPath, paint);
      }
    }
  }

  List<Path> _createOwlPaths(Offset center, double scale) {
    final paths = <Path>[];

    // Head outline (top part)
    Path headTop = Path();
    headTop.moveTo(center.dx - 40 * scale, center.dy - 60 * scale);
    headTop.lineTo(center.dx - 50 * scale, center.dy - 40 * scale);
    headTop.lineTo(center.dx - 45 * scale, center.dy - 20 * scale);
    paths.add(headTop);

    Path headTopRight = Path();
    headTopRight.moveTo(center.dx + 40 * scale, center.dy - 60 * scale);
    headTopRight.lineTo(center.dx + 50 * scale, center.dy - 40 * scale);
    headTopRight.lineTo(center.dx + 45 * scale, center.dy - 20 * scale);
    paths.add(headTopRight);

    // Ears (geometric triangles)
    Path leftEar = Path();
    leftEar.moveTo(center.dx - 50 * scale, center.dy - 70 * scale);
    leftEar.lineTo(center.dx - 40 * scale, center.dy - 60 * scale);
    leftEar.lineTo(center.dx - 35 * scale, center.dy - 75 * scale);
    leftEar.close();
    paths.add(leftEar);

    Path rightEar = Path();
    rightEar.moveTo(center.dx + 50 * scale, center.dy - 70 * scale);
    rightEar.lineTo(center.dx + 40 * scale, center.dy - 60 * scale);
    rightEar.lineTo(center.dx + 35 * scale, center.dy - 75 * scale);
    rightEar.close();
    paths.add(rightEar);

    // Face structure (geometric shapes)
    Path faceLeft = Path();
    faceLeft.moveTo(center.dx - 45 * scale, center.dy - 20 * scale);
    faceLeft.lineTo(center.dx - 50 * scale, center.dy);
    faceLeft.lineTo(center.dx - 40 * scale, center.dy + 10 * scale);
    paths.add(faceLeft);

    Path faceRight = Path();
    faceRight.moveTo(center.dx + 45 * scale, center.dy - 20 * scale);
    faceRight.lineTo(center.dx + 50 * scale, center.dy);
    faceRight.lineTo(center.dx + 40 * scale, center.dy + 10 * scale);
    paths.add(faceRight);

    // Eyes (geometric diamonds)
    Path leftEye = Path();
    leftEye.moveTo(center.dx - 25 * scale, center.dy - 30 * scale);
    leftEye.lineTo(center.dx - 15 * scale, center.dy - 25 * scale);
    leftEye.lineTo(center.dx - 25 * scale, center.dy - 15 * scale);
    leftEye.lineTo(center.dx - 35 * scale, center.dy - 25 * scale);
    leftEye.close();
    paths.add(leftEye);

    Path rightEye = Path();
    rightEye.moveTo(center.dx + 25 * scale, center.dy - 30 * scale);
    rightEye.lineTo(center.dx + 35 * scale, center.dy - 25 * scale);
    rightEye.lineTo(center.dx + 25 * scale, center.dy - 15 * scale);
    rightEye.lineTo(center.dx + 15 * scale, center.dy - 25 * scale);
    rightEye.close();
    paths.add(rightEye);

    // Eye pupils (small triangles)
    Path leftPupil = Path();
    leftPupil.moveTo(center.dx - 25 * scale, center.dy - 28 * scale);
    leftPupil.lineTo(center.dx - 20 * scale, center.dy - 25 * scale);
    leftPupil.lineTo(center.dx - 25 * scale, center.dy - 22 * scale);
    leftPupil.close();
    paths.add(leftPupil);

    Path rightPupil = Path();
    rightPupil.moveTo(center.dx + 25 * scale, center.dy - 28 * scale);
    rightPupil.lineTo(center.dx + 30 * scale, center.dy - 25 * scale);
    rightPupil.lineTo(center.dx + 25 * scale, center.dy - 22 * scale);
    rightPupil.close();
    paths.add(rightPupil);

    // Beak (triangle)
    Path beak = Path();
    beak.moveTo(center.dx, center.dy - 15 * scale);
    beak.lineTo(center.dx - 8 * scale, center.dy - 5 * scale);
    beak.lineTo(center.dx + 8 * scale, center.dy - 5 * scale);
    beak.close();
    paths.add(beak);

    // Central face structure
    Path centerLine = Path();
    centerLine.moveTo(center.dx, center.dy - 15 * scale);
    centerLine.lineTo(center.dx, center.dy + 50 * scale);
    paths.add(centerLine);

    // Body geometric structure
    Path bodyLeft = Path();
    bodyLeft.moveTo(center.dx - 40 * scale, center.dy + 10 * scale);
    bodyLeft.lineTo(center.dx - 35 * scale, center.dy + 30 * scale);
    bodyLeft.lineTo(center.dx - 25 * scale, center.dy + 50 * scale);
    bodyLeft.lineTo(center.dx, center.dy + 60 * scale);
    paths.add(bodyLeft);

    Path bodyRight = Path();
    bodyRight.moveTo(center.dx + 40 * scale, center.dy + 10 * scale);
    bodyRight.lineTo(center.dx + 35 * scale, center.dy + 30 * scale);
    bodyRight.lineTo(center.dx + 25 * scale, center.dy + 50 * scale);
    bodyRight.lineTo(center.dx, center.dy + 60 * scale);
    paths.add(bodyRight);

    // Chest feathers (geometric lines)
    Path feather1 = Path();
    feather1.moveTo(center.dx - 15 * scale, center.dy + 10 * scale);
    feather1.lineTo(center.dx - 10 * scale, center.dy + 25 * scale);
    paths.add(feather1);

    Path feather2 = Path();
    feather2.moveTo(center.dx + 15 * scale, center.dy + 10 * scale);
    feather2.lineTo(center.dx + 10 * scale, center.dy + 25 * scale);
    paths.add(feather2);

    Path feather3 = Path();
    feather3.moveTo(center.dx - 10 * scale, center.dy + 25 * scale);
    feather3.lineTo(center.dx - 5 * scale, center.dy + 40 * scale);
    paths.add(feather3);

    Path feather4 = Path();
    feather4.moveTo(center.dx + 10 * scale, center.dy + 25 * scale);
    feather4.lineTo(center.dx + 5 * scale, center.dy + 40 * scale);
    paths.add(feather4);

    // Wing details
    Path wingLeft1 = Path();
    wingLeft1.moveTo(center.dx - 50 * scale, center.dy);
    wingLeft1.lineTo(center.dx - 40 * scale, center.dy + 10 * scale);
    paths.add(wingLeft1);

    Path wingLeft2 = Path();
    wingLeft2.moveTo(center.dx - 45 * scale, center.dy + 5 * scale);
    wingLeft2.lineTo(center.dx - 35 * scale, center.dy + 15 * scale);
    paths.add(wingLeft2);

    Path wingRight1 = Path();
    wingRight1.moveTo(center.dx + 50 * scale, center.dy);
    wingRight1.lineTo(center.dx + 40 * scale, center.dy + 10 * scale);
    paths.add(wingRight1);

    Path wingRight2 = Path();
    wingRight2.moveTo(center.dx + 45 * scale, center.dy + 5 * scale);
    wingRight2.lineTo(center.dx + 35 * scale, center.dy + 15 * scale);
    paths.add(wingRight2);

    return paths;
  }

  Path _createAnimatedPath(Path originalPath, double progress) {
    final metrics = originalPath.computeMetrics().toList();
    final animatedPath = Path();

    for (final metric in metrics) {
      final extractPath = metric.extractPath(
        0.0,
        metric.length * progress,
      );
      animatedPath.addPath(extractPath, Offset.zero);
    }

    return animatedPath;
  }

  @override
  bool shouldRepaint(GeometricOwlPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
