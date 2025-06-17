import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constant/app_info.dart';

class CustomAppBackground extends StatelessWidget {
  final Widget child;
  final bool useDiagonalGradient;
  final bool useGoldPattern;

  const CustomAppBackground({
    Key key,
    @required this.child,
    this.useDiagonalGradient = true,
    this.useGoldPattern = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background design layer
        Positioned.fill(
          child: useDiagonalGradient
              ? DiagonalGradientBackground(useGoldPattern: useGoldPattern)
              : ShimmerPatternBackground(),
        ),

        // Decorative elements
        Positioned.fill(
          child: DecorativeOverlay(),
        ),

        // Content layer
        child,
      ],
    );
  }
}

/// Creates a beautiful diagonal gradient background with subtle animation
class DiagonalGradientBackground extends StatefulWidget {
  final bool useGoldPattern;

  const DiagonalGradientBackground({
    Key key,
    this.useGoldPattern = true,
  }) : super(key: key);

  @override
  State<DiagonalGradientBackground> createState() =>
      _DiagonalGradientBackgroundState();
}

class _DiagonalGradientBackgroundState extends State<DiagonalGradientBackground>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
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
          painter: DiagonalGradientPainter(
            animationValue: _controller.value,
            useGoldPattern: widget.useGoldPattern,
          ),
          child: Container(),
        );
      },
    );
  }
}

class DiagonalGradientPainter extends CustomPainter {
  final double animationValue;
  final bool useGoldPattern;

  DiagonalGradientPainter({
    @required this.animationValue,
    this.useGoldPattern = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Use app theme colors with complementary gradients
    final paint = Paint();

    // Create a rich gradient using brand colors
    final primaryGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        bgColor.withOpacity(0.05),
        Color(0xFFFFF9E3).withOpacity(0.3),
        goldColor.withOpacity(0.1),
      ],
      stops: [0.0, 0.5, 1.0],
      transform: GradientRotation(math.pi * 2 * animationValue * 0.1),
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    paint.shader = primaryGradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Add diagonal patterns
    final patternPaint = Paint()
      ..color = bgColor.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Create diagonal pattern with subtle animation
    for (int i = 0; i < 10; i++) {
      double offset =
          size.width * 0.2 * i + (size.width * animationValue * 0.1);
      Path path = Path()
        ..moveTo(offset, 0)
        ..lineTo(offset + size.width * 0.2, 0)
        ..lineTo(0, offset + size.width * 0.2)
        ..lineTo(0, offset)
        ..close();
      canvas.drawPath(path, patternPaint);
    }

    if (useGoldPattern) {
      // Add luxury gold pattern
      _drawGoldPattern(canvas, size);
    }

    // Add sparkling gold dots
    final random = math.Random(animationValue.toInt() * 100);
    final dotPaint = Paint()
      ..color = goldColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
  }

  void _drawGoldPattern(Canvas canvas, Size size) {
    final goldPatternPaint = Paint()
      ..color = goldColor.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Create a repeating damask-like pattern suitable for a jewelry store
    final patternSize = size.width * 0.15;
    for (double x = 0; x < size.width; x += patternSize) {
      for (double y = 0; y < size.height; y += patternSize) {
        // Draw floral pattern at each grid point
        _drawFloralPattern(canvas, Offset(x, y), patternSize, goldPatternPaint);
      }
    }
  }

  void _drawFloralPattern(
      Canvas canvas, Offset center, double size, Paint paint) {
    // Draw a stylized floral pattern for luxury feel
    final path = Path();

    // Draw petals
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + animationValue * 0.2;
      final petalPath = Path();
      petalPath.moveTo(center.dx, center.dy);
      petalPath.quadraticBezierTo(
        center.dx + math.cos(angle) * size * 0.4,
        center.dy + math.sin(angle) * size * 0.4,
        center.dx + math.cos(angle) * size * 0.5,
        center.dy + math.sin(angle) * size * 0.5,
      );
      canvas.drawPath(petalPath, paint);
    }

    // Draw small circle in center
    canvas.drawCircle(center, size * 0.1, paint..style = PaintingStyle.fill);

    // Draw outline circle
    canvas.drawCircle(center, size * 0.3, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(DiagonalGradientPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.useGoldPattern != useGoldPattern;
}

/// Creates a shimmer pattern background with animated effects
class ShimmerPatternBackground extends StatefulWidget {
  const ShimmerPatternBackground({Key key}) : super(key: key);

  @override
  State<ShimmerPatternBackground> createState() =>
      _ShimmerPatternBackgroundState();
}

class _ShimmerPatternBackgroundState extends State<ShimmerPatternBackground>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
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
          painter: ShimmerPatternPainter(
            animationValue: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class ShimmerPatternPainter extends CustomPainter {
  final double animationValue;

  ShimmerPatternPainter({
    @required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base gradient background
    final baseGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        Color(0xFFFAF6E9),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final basePaint = Paint()..shader = baseGradient;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // Draw shimmer waves
    final shimmerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = goldColor.withOpacity(0.05);

    for (int i = 0; i < 5; i++) {
      double wavePhase = (animationValue + i * 0.2) % 1.0;
      Path wavePath = Path();
      wavePath.moveTo(
          0,
          size.height * 0.3 +
              size.height * 0.1 * math.sin(wavePhase * math.pi * 2));

      for (double x = 0; x <= size.width; x += size.width / 20) {
        double phaseOffset = x / size.width * math.pi * 4;
        double y = size.height * (0.3 + i * 0.15) +
            size.height *
                0.05 *
                math.sin(wavePhase * math.pi * 2 + phaseOffset);
        wavePath.lineTo(x, y);
      }

      wavePath.lineTo(size.width, size.height);
      wavePath.lineTo(0, size.height);
      wavePath.close();

      canvas.drawPath(wavePath, shimmerPaint);
    }

    // Draw decorative patterns
    final patternPaint = Paint()
      ..color = bgColor.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      double y = size.height * (i / 20.0);
      double amplitude = size.width * 0.05;
      double frequency = 10;
      double phase = animationValue * math.pi * 2;

      Path linePath = Path();
      linePath.moveTo(0, y);

      for (double x = 0; x <= size.width; x += size.width / 40) {
        double newY = y +
            amplitude *
                math.sin((x / size.width) * frequency * math.pi + phase);
        linePath.lineTo(x, newY);
      }

      canvas.drawPath(linePath, patternPaint..strokeWidth = 1.0);
    }
  }

  @override
  bool shouldRepaint(ShimmerPatternPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

/// Adds decorative elements on top of the background
class DecorativeOverlay extends StatelessWidget {
  const DecorativeOverlay({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gold corner flourishes
        Positioned(
          top: 0,
          left: 0,
          child: CustomPaint(
            size: Size(60, 60),
            painter: CornerFlourishPainter(
              color: goldColor.withOpacity(0.15),
            ),
          ),
        ),

        Positioned(
          top: 0,
          right: 0,
          child: Transform(
            transform: Matrix4.identity()..scale(-1.0, 1.0),
            child: CustomPaint(
              size: Size(60, 60),
              painter: CornerFlourishPainter(
                color: goldColor.withOpacity(0.15),
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
              size: Size(60, 60),
              painter: CornerFlourishPainter(
                color: goldColor.withOpacity(0.15),
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
              size: Size(60, 60),
              painter: CornerFlourishPainter(
                color: goldColor.withOpacity(0.15),
              ),
            ),
          ),
        ),

        // Add decorative diamond elements
        Positioned(
          top: 100,
          right: 20,
          child: CustomPaint(
            size: Size(20, 20),
            painter: DiamondPainter(
              color: goldColor.withOpacity(0.2),
            ),
          ),
        ),

        Positioned(
          top: 150,
          left: 30,
          child: CustomPaint(
            size: Size(15, 15),
            painter: DiamondPainter(
              color: goldColor.withOpacity(0.15),
            ),
          ),
        ),

        Positioned(
          bottom: 120,
          right: 40,
          child: CustomPaint(
            size: Size(25, 25),
            painter: DiamondPainter(
              color: goldColor.withOpacity(0.15),
            ),
          ),
        ),

        // Add subtle chain design
        Positioned(
          top: 200,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(double.infinity, 30),
            painter: ChainPainter(
              color: goldColor.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }
}

class CornerFlourishPainter extends CustomPainter {
  final Color color;

  CornerFlourishPainter({
    @required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;

    Path path = Path();

    // Draw curved corner flourish
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.3,
      size.width * 0.6,
      0,
    );

    // Draw decorative swirls
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.2,
      size.width * 0.4,
      0,
    );

    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.2,
      0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CornerFlourishPainter oldDelegate) =>
      oldDelegate.color != color;
}

class DiamondPainter extends CustomPainter {
  final Color color;

  DiamondPainter({
    @required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = color;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity(0.1);

    // Draw diamond shape
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();

    // Draw internal facets
    final facetPath = Path();
    facetPath.moveTo(size.width / 2, 0);
    facetPath.lineTo(size.width / 2, size.height);
    facetPath.moveTo(0, size.height / 2);
    facetPath.lineTo(size.width, size.height / 2);

    // Draw diagonal facets
    facetPath.moveTo(size.width * 0.25, size.height * 0.25);
    facetPath.lineTo(size.width * 0.75, size.height * 0.75);
    facetPath.moveTo(size.width * 0.75, size.height * 0.25);
    facetPath.lineTo(size.width * 0.25, size.height * 0.75);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);
    canvas.drawPath(facetPath, paint..strokeWidth = 0.5);
  }

  @override
  bool shouldRepaint(DiamondPainter oldDelegate) => oldDelegate.color != color;
}

class ChainPainter extends CustomPainter {
  final Color color;

  ChainPainter({
    @required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = color;

    final linkWidth = 10.0;
    final linkHeight = 5.0;
    final linkSpacing = 2.0;

    // Draw a decorative chain across the screen
    for (double x = 0; x < size.width; x += linkWidth + linkSpacing) {
      // Draw a chain link
      final rect = Rect.fromLTWH(
          x, size.height / 2 - linkHeight / 2, linkWidth, linkHeight);
      canvas.drawOval(rect, paint);
    }
  }

  @override
  bool shouldRepaint(ChainPainter oldDelegate) => oldDelegate.color != color;
}
