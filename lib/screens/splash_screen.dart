import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../config/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Halo rotation ──────────────────────────────────────────────────────────
  late final AnimationController _haloController;

  // ── Sun orb pulse ──────────────────────────────────────────────────────────
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  // ── Dot loader pulse ───────────────────────────────────────────────────────
  late final AnimationController _dotsController;

  // ── Fade-in for brand text ─────────────────────────────────────────────────
  late final AnimationController _fadeController;
  late final Animation<double> _fadeOpacity;
  late final Animation<Offset> _fadeSlide;

  @override
  void initState() {
    super.initState();

    // Force light status bar icons on the orange bg
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    // Halo: continuous slow rotation, 8 s per revolution
    _haloController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Sun pulse: scale 1.0 → 1.08 → 1.0, opacity 0.6 → 1.0 → 0.6, 2 s loop
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Dots loader: 0 → 1 loop, each dot offset-staggered in the builder
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Brand text: fade + slide up over 800 ms, starts after 400 ms delay
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadeController.forward();
    });

    // Navigate after 3 s — GoRouter will redirect based on auth state
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) context.go(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _haloController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orangeBright,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.orangeBright, // #F57C00
                AppColors.orangePrimary, // #E65100
                AppColors.orangeDim, // #BF360C
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // ── Sun orb + rotating halo ──────────────────────────────
                _SunOrb(
                  haloController: _haloController,
                  pulseScale: _pulseScale,
                  pulseOpacity: _pulseOpacity,
                ),

                const SizedBox(height: 36),

                // ── Brand text ───────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeOpacity,
                  child: SlideTransition(
                    position: _fadeSlide,
                    child: const _BrandText(),
                  ),
                ),

                const Spacer(flex: 3),

                // ── Dot loader ───────────────────────────────────────────
                _DotLoader(controller: _dotsController),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sun Orb widget ─────────────────────────────────────────────────────────────
class _SunOrb extends StatelessWidget {
  const _SunOrb({
    required this.haloController,
    required this.pulseScale,
    required this.pulseOpacity,
  });

  final AnimationController haloController;
  final Animation<double> pulseScale;
  final Animation<double> pulseOpacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating dashed halo ring
          AnimatedBuilder(
            animation: haloController,
            builder: (_, __) => Transform.rotate(
              angle: haloController.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(160, 160),
                painter: _HaloPainter(),
              ),
            ),
          ),

          // Pulsing glowing sun orb
          AnimatedBuilder(
            animation: pulseScale,
            builder: (_, child) => Transform.scale(
              scale: pulseScale.value,
              child: Opacity(opacity: pulseOpacity.value, child: child),
            ),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.35),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: AppColors.orangeBright.withOpacity(0.50),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Text('☀️', style: TextStyle(fontSize: 44)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Halo painter — dashed circle ───────────────────────────────────────────────
class _HaloPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 76.0;
    const dashCount = 24;
    const dashAngle = (2 * math.pi) / dashCount;
    const gapFraction = 0.45; // fraction of arc that is gap

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      const sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Brand text ─────────────────────────────────────────────────────────────────
class _BrandText extends StatelessWidget {
  const _BrandText();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // "HostelHop"
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Hostel',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Hop',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white60,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Tagline
        const Text(
          'CAMPUS LIFE, SORTED.',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.white60,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }
}

// ── Dot loader ─────────────────────────────────────────────────────────────────
class _DotLoader extends StatelessWidget {
  const _DotLoader({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Stagger each dot by 0.2 of the animation cycle
            final offset = i * 0.2;
            final raw = (controller.value - offset) % 1.0;
            // Map to a sine-like pulse: peak opacity at raw ≈ 0.5
            final t = math.sin(raw * math.pi).clamp(0.0, 1.0);
            final opacity = 0.30 + 0.70 * t;
            final scale = 0.75 + 0.35 * t;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
