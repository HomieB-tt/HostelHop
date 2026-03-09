import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../config/app_routes.dart';

// ── Slide data model ───────────────────────────────────────────────────────────
class _OnboardingSlide {
  const _OnboardingSlide({
    required this.emoji,
    required this.emojiBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.featureIcon,
    required this.featureTitle,
    required this.featureBody,
  });

  final String emoji;
  final Color emojiBackgroundColor;
  final String title;
  final String subtitle;
  final String featureIcon;
  final String featureTitle;
  final String featureBody;
}

const List<_OnboardingSlide> _slides = [
  _OnboardingSlide(
    emoji: '☀️',
    emojiBackgroundColor: Color(0xFFFFF3E0),
    title: 'Beat the Sun',
    subtitle: 'Find shaded, affordable rooms\nnear your campus — fast.',
    featureIcon: '🌡️',
    featureTitle: 'Sun Meter',
    featureBody:
        'Real-time Kampala heat index so you know when to move and when to stay indoors.',
  ),
  _OnboardingSlide(
    emoji: '🔒',
    emojiBackgroundColor: Color(0xFFE8F5E9),
    title: 'Lock Your Room',
    subtitle: 'Reserve your room with a small\ncommitment fee. No stress.',
    featureIcon: '🛡️',
    featureTitle: 'Escrow Protection',
    featureBody:
        'Your commitment fee is held safely in escrow until the landlord confirms your booking.',
  ),
  _OnboardingSlide(
    emoji: '⭐',
    emojiBackgroundColor: Color(0xFFFFF8E1),
    title: 'Verified Hostels',
    subtitle: 'Every hostel is vetted and reviewed\nby real students like you.',
    featureIcon: '✅',
    featureTitle: 'Campus Life Guarantee',
    featureBody:
        'If the hostel doesn\'t match the listing, you get a full refund. No questions asked.',
  ),
];

// ── Screen ─────────────────────────────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Illustration bounce animation
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      _onGetStarted();
    }
  }

  void _onGetStarted() => context.go(AppRoutes.login);

  void _onSkip() => _onGetStarted();

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF5F6368);

    return Scaffold(
      backgroundColor: bgColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip button ────────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 20),
                  child: _currentPage < _slides.length - 1
                      ? TextButton(
                          onPressed: _onSkip,
                          style: TextButton.styleFrom(
                            foregroundColor: textSecondary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox(height: 36),
                ),
              ),

              // ── Page view ──────────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => _SlidePage(
                    slide: _slides[i],
                    bounceAnim: _bounceAnim,
                    surfaceColor: surfaceColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isDark: isDark,
                  ),
                ),
              ),

              // ── Dots + button ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    // Page dots
                    _PageDots(count: _slides.length, current: _currentPage),

                    const SizedBox(height: 24),

                    // Next / Get Started button
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _currentPage < _slides.length - 1
                            ? _NextButton(
                                key: const ValueKey('next'),
                                onTap: _onNext,
                              )
                            : _GetStartedButton(
                                key: const ValueKey('start'),
                                onTap: _onGetStarted,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Individual slide page ──────────────────────────────────────────────────────
class _SlidePage extends StatelessWidget {
  const _SlidePage({
    required this.slide,
    required this.bounceAnim,
    required this.surfaceColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });

  final _OnboardingSlide slide;
  final Animation<double> bounceAnim;
  final Color surfaceColor;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Illustration ───────────────────────────────────────────────
          AnimatedBuilder(
            animation: bounceAnim,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, bounceAnim.value),
              child: child,
            ),
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: slide.emojiBackgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: slide.emojiBackgroundColor.withOpacity(0.6),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(slide.emoji, style: const TextStyle(fontSize: 64)),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── HostelHop brand ────────────────────────────────────────────
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Hostel',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orangeBright,
                  ),
                ),
                TextSpan(
                  text: 'Hop',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orangePrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Slide title ────────────────────────────────────────────────
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: textPrimary,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 10),

          // ── Subtitle ───────────────────────────────────────────────────
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // ── Feature card ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : const Color(0xFFE8EAED),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.20 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.orangeBright.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      slide.featureIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.featureTitle,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slide.featureBody,
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page dots ──────────────────────────────────────────────────────────────────
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 16 : 5,
          height: isActive ? 6 : 5,
          decoration: BoxDecoration(
            color: isActive ? AppColors.orangeBright : const Color(0xFFBDBDBD),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Next button ────────────────────────────────────────────────────────────────
class _NextButton extends StatelessWidget {
  const _NextButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style:
          ElevatedButton.styleFrom(
            backgroundColor: AppColors.orangeBright,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: const StadiumBorder(),
            elevation: 0,
            shadowColor: Colors.transparent,
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
              Colors.white.withOpacity(0.15),
            ),
          ),
      child: const Text(
        'Next →',
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Get Started button ─────────────────────────────────────────────────────────
class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.orangeBright, AppColors.orangePrimary],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppColors.orangeBright.withOpacity(0.40),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: const Text(
          '🚀 Get Started',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
