import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constant/app_info.dart';

class MaroonAppBackground extends StatelessWidget {
  final Widget child;
  final bool useMaroonPattern;

  const MaroonAppBackground({
    Key key,
    @required this.child,
    this.useMaroonPattern = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background design layer
        Positioned.fill(
          child: MaroonGradientBackground(usePattern: useMaroonPattern),
        ),

        // Decorative elements
        Positioned.fill(
          child: MaroonDecorativeOverlay(),
        ),

        // Content layer
        child,
      ],
    );
  }
}

/// Creates a beautiful maroon gradient background with subtle animation
class MaroonGradientBackground extends StatefulWidget {
  final bool usePattern;

  const MaroonGradientBackground({
    Key key,
    this.usePattern = true,
  }) : super(key: key);

  @override
  State<MaroonGradientBackground> createState() =>
      _MaroonGradientBackgroundState();
}

class _MaroonGradientBackgroundState extends State<MaroonGradientBackground>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: MaroonGradientPainter(
            animationValue: _controller.value,
            usePattern: widget.usePattern,
          ),
          child: Container(),
        );
      },
    );
  }
}

class MaroonGradientPainter extends CustomPainter {
  final double animationValue;
  final bool usePattern;

  MaroonGradientPainter({
    @required this.animationValue,
    this.usePattern = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Use app theme colors with complementary gradients
    final paint = Paint();

    // Create a rich gradient using maroon and white
    final primaryGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        Colors.white.withOpacity(0.95),
        Color(0xFFFAF6F6),
      ],
      stops: [0.0, 0.4, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    paint.shader = primaryGradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    if (usePattern) {
      // Add luxury maroon patterns
      _drawMaroonPatterns(canvas, size);
    }

    // Add subtle maroon dots
    final random = math.Random(animationValue.toInt() * 100);
    final dotPaint = Paint()
      ..color = bgColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 0.5;
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
  }

  void _drawMaroonPatterns(Canvas canvas, Size size) {
    // Create elegant maroon patterns
    final maroonPaint = Paint()
      ..color = bgColor.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw royal pattern (inspired by traditional Indian patterns)
    final patternSize = size.width * 0.12;
    for (double x = 0; x < size.width; x += patternSize) {
      for (double y = 0; y < size.height; y += patternSize) {
        if ((x + y) % (patternSize * 2) < patternSize) {
          _drawRoyalPattern(canvas, Offset(x, y), patternSize, maroonPaint);
        }
      }
    }

    // Add subtle maroon gradient accents
    final accentPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = bgColor.withOpacity(0.03);

    // Draw curved accents at the top
    Path accentPath = Path();
    accentPath.moveTo(0, 0);
    accentPath.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.1 + 20 * math.sin(animationValue * math.pi * 2),
        size.width,
        0);
    accentPath.lineTo(size.width, size.height * 0.2);
    accentPath.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.1 - 20 * math.sin(animationValue * math.pi * 2),
        0,
        size.height * 0.2);
    accentPath.close();

    canvas.drawPath(accentPath, accentPaint);

    // Draw curved accents at the bottom
    accentPath = Path();
    accentPath.moveTo(0, size.height);
    accentPath.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.9 - 20 * math.sin(animationValue * math.pi * 2),
        size.width,
        size.height);
    accentPath.lineTo(size.width, size.height * 0.8);
    accentPath.quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.9 + 20 * math.sin(animationValue * math.pi * 2),
        0,
        size.height * 0.8);
    accentPath.close();

    canvas.drawPath(accentPath, accentPaint);
  }

  void _drawRoyalPattern(
      Canvas canvas, Offset center, double size, Paint paint) {
    // Draw a traditional Indian jewelry inspired pattern
    final maroonFillPaint = Paint()
      ..color = bgColor.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    // Draw main design
    Path path = Path();
    path.addOval(
        Rect.fromCenter(center: center, width: size * 0.7, height: size * 0.7));

    // Draw decorative arcs
    for (int i = 0; i < 4; i++) {
      double angle = i * math.pi / 2 + animationValue * 0.1;
      path.addArc(
        Rect.fromCenter(
          center: Offset(
            center.dx + math.cos(angle) * size * 0.4,
            center.dy + math.sin(angle) * size * 0.4,
          ),
          width: size * 0.4,
          height: size * 0.4,
        ),
        angle - math.pi / 2,
        math.pi,
      );
    }

    // Draw pattern with both fill and stroke
    canvas.drawPath(path, maroonFillPaint);
    canvas.drawPath(path, paint);

    // Draw center detail
    canvas.drawCircle(center, size * 0.15, maroonFillPaint);
    canvas.drawCircle(center, size * 0.15, paint);
  }

  @override
  bool shouldRepaint(MaroonGradientPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.usePattern != usePattern;
}

/// Adds decorative elements on top of the background
class MaroonDecorativeOverlay extends StatelessWidget {
  const MaroonDecorativeOverlay({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Maroon corner flourishes
        Positioned(
          top: 0,
          left: 0,
          child: CustomPaint(
            size: Size(70, 70),
            painter: MaroonCornerPainter(
              color: bgColor.withOpacity(0.15),
            ),
          ),
        ),

        Positioned(
          top: 0,
          right: 0,
          child: Transform(
            transform: Matrix4.identity()..scale(-1.0, 1.0),
            child: CustomPaint(
              size: Size(70, 70),
              painter: MaroonCornerPainter(
                color: bgColor.withOpacity(0.15),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          left: 0,
          child: Transform(
            transform: Matrix4.identity()..scale(1.0, -1.0),
            child: CustomPaint(
              size: Size(70, 70),
              painter: MaroonCornerPainter(
                color: bgColor.withOpacity(0.15),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 0,
          right: 0,
          child: Transform(
            transform: Matrix4.identity()..scale(-1.0, -1.0),
            child: CustomPaint(
              size: Size(70, 70),
              painter: MaroonCornerPainter(
                color: bgColor.withOpacity(0.15),
              ),
            ),
          ),
        ),

        // Add ornamental border elements
        Positioned(
          top: 120,
          right: 5,
          child: CustomPaint(
            size: Size(30, 150),
            painter: MaroonBorderPainter(
              color: bgColor.withOpacity(0.1),
            ),
          ),
        ),

        Positioned(
          top: 120,
          left: 5,
          child: CustomPaint(
            size: Size(30, 150),
            painter: MaroonBorderPainter(
              color: bgColor.withOpacity(0.1),
              isLeftSide: true,
            ),
          ),
        ),

        // Add subtle decorative elements
        Positioned(
          top: 300,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(double.infinity, 40),
            painter: MaroonPatternPainter(
              color: bgColor.withOpacity(0.08),
            ),
          ),
        ),
      ],
    );
  }
}

class MaroonCornerPainter extends CustomPainter {
  final Color color;

  MaroonCornerPainter({
    @required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;

    Path path = Path();

    // Draw main corner flourish
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.4,
      size.width * 0.7,
      0,
    );

    // Draw inner flourish
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.25,
      size.width * 0.5,
      0,
    );

    // Draw delicate pattern lines
    for (int i = 1; i <= 3; i++) {
      double factor = i * 0.2;
      path.moveTo(0, size.height * factor);
      path.quadraticBezierTo(
        size.width * 0.1,
        size.height * (factor - 0.05),
        size.width * 0.3 * factor,
        0,
      );
    }

    canvas.drawPath(path, paint);

    // Draw dots at intersections
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.drawCircle(
        Offset(size.width * 0.25, size.height * 0.25), 2, dotPaint);
    canvas.drawCircle(
        Offset(size.width * 0.4, size.height * 0.15), 1.5, dotPaint);
    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.4), 1.5, dotPaint);
  }

  @override
  bool shouldRepaint(MaroonCornerPainter oldDelegate) =>
      oldDelegate.color != color;
}

class MaroonBorderPainter extends CustomPainter {
  final Color color;
  final bool isLeftSide;

  MaroonBorderPainter({
    @required this.color,
    this.isLeftSide = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = color;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.3);

    // Draw an elegant border design
    Path path = Path();

    // Main vertical line
    double xPosition = isLeftSide ? size.width * 0.7 : size.width * 0.3;
    path.moveTo(xPosition, 0);
    path.lineTo(xPosition, size.height);

    // Draw decorative elements
    for (int i = 0; i < 5; i++) {
      double yPos = size.height * (i + 0.5) / 5;

      // Create ornamental circles
      if (isLeftSide) {
        path.addOval(Rect.fromCircle(
          center: Offset(xPosition - size.width * 0.2, yPos),
          radius: size.width * 0.15,
        ));
      } else {
        path.addOval(Rect.fromCircle(
          center: Offset(xPosition + size.width * 0.2, yPos),
          radius: size.width * 0.15,
        ));
      }
    }

    canvas.drawPath(path, paint);

    // Draw accent details
    for (int i = 0; i < 5; i++) {
      double yPos = size.height * (i + 0.5) / 5;
      Offset center;

      if (isLeftSide) {
        center = Offset(xPosition - size.width * 0.2, yPos);
      } else {
        center = Offset(xPosition + size.width * 0.2, yPos);
      }

      // Draw small filled circle
      canvas.drawCircle(center, size.width * 0.05, fillPaint);
      canvas.drawCircle(center, size.width * 0.05, paint);
    }
  }

  @override
  bool shouldRepaint(MaroonBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isLeftSide != isLeftSide;
}

class MaroonPatternPainter extends CustomPainter {
  final Color color;

  MaroonPatternPainter({
    @required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = color;

    // Draw a traditional pattern
    Path path = Path();

    // Draw horizontal line
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, size.height / 2);

    // Draw decoration pattern
    double motifWidth = 40;
    int motifCount = (size.width / motifWidth).ceil();

    for (int i = 0; i < motifCount; i++) {
      double x = i * motifWidth + motifWidth / 2;

      // Draw decorative arch
      path.moveTo(x - motifWidth / 2, size.height / 2);
      path.quadraticBezierTo(
          x, size.height / 4, x + motifWidth / 2, size.height / 2);

      // Draw decorative arch (inverted)
      path.moveTo(x - motifWidth / 2, size.height / 2);
      path.quadraticBezierTo(
          x, size.height * 3 / 4, x + motifWidth / 2, size.height / 2);
    }

    canvas.drawPath(path, paint);

    // Draw dots at key points for added style
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.5);

    for (int i = 0; i < motifCount; i++) {
      double x = i * motifWidth + motifWidth / 2;
      canvas.drawCircle(Offset(x, size.height / 4), 1.5, dotPaint);
      canvas.drawCircle(Offset(x, size.height * 3 / 4), 1.5, dotPaint);
      canvas.drawCircle(
          Offset(x - motifWidth / 2, size.height / 2), 1.5, dotPaint);
      canvas.drawCircle(
          Offset(x + motifWidth / 2, size.height / 2), 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(MaroonPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}
