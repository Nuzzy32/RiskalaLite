import 'dart:math' as math;
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _rotateController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Floating up/down animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // Slow 3D rotation
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    // Pulsing glow rings
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDFF6F6),
              Color(0xFFF2FAFA),
              Color(0xFFF5F5DC),
            ],
            stops: [0.0, 0.5, 0.9],
          ),
        ),
        child: Stack(
          children: [
            // Decorative blur circle
            Positioned(
              bottom: -128,
              right: -128,
              child: Container(
                width: 384,
                height: 384,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Top gradient overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 128,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Main content
            Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated 3D person icon with glow rings
                      AnimatedBuilder(
                        floatAnimation: _floatController,
                        rotateAnimation: _rotateController,
                        pulseAnimation: _pulseController,
                      ),
                      const SizedBox(height: 48),
                      // Title
                      const Text(
                        'Welcome to',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF245A72),
                          letterSpacing: -0.75,
                          height: 1.25,
                        ),
                      ),
                      const Text(
                        'RISKALA Lite',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF245A72),
                          letterSpacing: -0.75,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your safe space for mental wellness',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A8A96),
                        ),
                      ),
                    ],
                  ),
                ),
                // Get Started button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 64),
                  child: SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF6ADBDD),
                            Color(0xFF58C6D6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(9999),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF61D1DB).withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.45,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedBuilder extends StatelessWidget {
  final AnimationController floatAnimation;
  final AnimationController rotateAnimation;
  final AnimationController pulseAnimation;

  const AnimatedBuilder({
    super.key,
    required this.floatAnimation,
    required this.rotateAnimation,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder3D(
      floatAnimation: floatAnimation,
      rotateAnimation: rotateAnimation,
      pulseAnimation: pulseAnimation,
    );
  }
}

class AnimatedBuilder3D extends StatelessWidget {
  final AnimationController floatAnimation;
  final AnimationController rotateAnimation;
  final AnimationController pulseAnimation;

  const AnimatedBuilder3D({
    super.key,
    required this.floatAnimation,
    required this.rotateAnimation,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder3DContent(
      floatAnimation: floatAnimation,
      rotateAnimation: rotateAnimation,
      pulseAnimation: pulseAnimation,
    );
  }
}

class AnimatedBuilder3DContent extends StatelessWidget {
  final AnimationController floatAnimation;
  final AnimationController rotateAnimation;
  final AnimationController pulseAnimation;

  const AnimatedBuilder3DContent({
    super.key,
    required this.floatAnimation,
    required this.rotateAnimation,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilderWidget(
      listenable: Listenable.merge([floatAnimation, rotateAnimation, pulseAnimation]),
      floatAnimation: floatAnimation,
      rotateAnimation: rotateAnimation,
      pulseAnimation: pulseAnimation,
    );
  }
}

class AnimatedBuilderWidget extends AnimatedWidget {
  final AnimationController floatAnimation;
  final AnimationController rotateAnimation;
  final AnimationController pulseAnimation;

  const AnimatedBuilderWidget({
    super.key,
    required super.listenable,
    required this.floatAnimation,
    required this.rotateAnimation,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final floatValue = Curves.easeInOut.transform(floatAnimation.value);
    final rotateValue = rotateAnimation.value;
    final pulseValue = Curves.easeInOut.transform(pulseAnimation.value);

    // Float offset: -12 to +12 pixels
    final floatOffset = -12.0 + (floatValue * 24.0);

    // 3D rotation angles
    final rotX = math.sin(rotateValue * 2 * math.pi) * 0.15;
    final rotY = math.cos(rotateValue * 2 * math.pi) * 0.15;

    // Pulse scale for rings
    final outerScale = 1.0 + (pulseValue * 0.08);
    final middleScale = 1.0 + (pulseValue * 0.05);
    final innerScale = 1.0 + (pulseValue * 0.03);

    // Shadow offset based on rotation for 3D depth
    final shadowOffsetX = rotY * 20;
    final shadowOffsetY = 10.0 + (rotX * 15) + (floatValue * 5);

    return Transform.translate(
      offset: Offset(0, floatOffset),
      child: SizedBox(
        width: 320,
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring - pulsing + rotating
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(rotX * 0.5)
                ..rotateY(rotY * 0.5)
                ..scale(outerScale, outerScale, 1.0),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFBEECEE)
                      .withValues(alpha: 0.15 + (pulseValue * 0.1)),
                  border: Border.all(
                    color: const Color(0xFFBEECEE)
                        .withValues(alpha: 0.1 + (pulseValue * 0.08)),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // Middle glow ring - pulsing + rotating (slightly offset)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(rotX * 0.8)
                ..rotateY(rotY * 0.8)
                ..scale(middleScale, middleScale, 1.0),
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFAEDFE3)
                      .withValues(alpha: 0.25 + (pulseValue * 0.1)),
                  border: Border.all(
                    color: const Color(0xFFAEDFE3)
                        .withValues(alpha: 0.15 + (pulseValue * 0.1)),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // Inner glow ring - pulsing + rotating
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(rotX)
                ..rotateY(rotY)
                ..scale(innerScale, innerScale, 1.0),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF9DD4D9)
                      .withValues(alpha: 0.35 + (pulseValue * 0.1)),
                  border: Border.all(
                    color: const Color(0xFF9DD4D9)
                        .withValues(alpha: 0.2 + (pulseValue * 0.1)),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // Glass circle with person icon - full 3D transform
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(rotX)
                ..rotateY(rotY),
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment(-0.5 + rotY, -0.5 + rotX),
                    end: Alignment(0.5 + rotY, 0.5 + rotX),
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF61D1DB).withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: Offset(shadowOffsetX, shadowOffsetY),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Opacity(
                    opacity: 0.6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5A9CA6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -8),
                          child: Container(
                            width: 64,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5A9CA6),
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
