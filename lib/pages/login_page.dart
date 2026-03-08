import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nipController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nipController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.4, -1),
            end: Alignment(0.4, 1),
            colors: [
              Color(0xFFF2FAFA),
              Color(0xFFDFF6F6),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Bottom decorative blur
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  color: const Color(0xFF61D1DB).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Center(
                        child: const Text(
                          'RISKALA Lite',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF245A72),
                            letterSpacing: -0.45,
                          ),
                        ),
                      ),
                    ),
                    // Main content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                      child: Column(
                        children: [
                          // Title section
                          Column(
                            children: [
                              // Lotus icon
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF13A4EC).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(
                                  Icons.spa,
                                  color: Color(0xFF13A4EC),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF245A72),
                                  letterSpacing: -0.75,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          // Form
                          Column(
                            children: [
                              // NIP Input
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(9999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 40,
                                      offset: const Offset(0, 10),
                                      spreadRadius: -10,
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _nipController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'NIP',
                                    hintStyle: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.only(left: 20, right: 12),
                                      child: Icon(
                                        Icons.mail_outline,
                                        color: Color(0xFF94A3B8),
                                        size: 20,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 16,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Password Input
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(9999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 40,
                                      offset: const Offset(0, 10),
                                      spreadRadius: -10,
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: !_showPassword,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.only(left: 20, right: 12),
                                      child: Icon(
                                        Icons.lock_outline,
                                        color: Color(0xFF94A3B8),
                                        size: 20,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() => _showPassword = !_showPassword);
                                      },
                                      icon: Icon(
                                        _showPassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: _showPassword
                                            ? const Color(0xFF61D1DB)
                                            : const Color(0xFF94A3B8),
                                        size: 20,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 16,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    'Lupa Password?',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFF6ADBDD),
                                        Color(0xFF58C6D6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(9999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF13A4EC).withValues(alpha: 0.4),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    onPressed: _isLoading ? null : _handleLogin,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Log In',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.arrow_forward,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
