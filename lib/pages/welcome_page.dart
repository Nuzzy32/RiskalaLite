import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
                      // Person icon with glow rings
                      SizedBox(
                        width: 320,
                        height: 320,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring
                            Container(
                              width: 320,
                              height: 320,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFBEECEE).withValues(alpha: 0.2),
                              ),
                            ),
                            // Middle glow ring
                            Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFAEDFE3).withValues(alpha: 0.3),
                              ),
                            ),
                            // Inner glow ring
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF9DD4D9).withValues(alpha: 0.4),
                              ),
                            ),
                            // Glass circle with person icon
                            Container(
                              width: 128,
                              height: 128,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.4),
                                    Colors.white.withValues(alpha: 0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 10),
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
                          ],
                        ),
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
                            color: const Color(0xFF61D1DB).withValues(alpha: 0.4),
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
