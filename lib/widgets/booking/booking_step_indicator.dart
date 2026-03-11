import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

/// Animated 3-step progress indicator for the booking flow.
///
/// Usage:
///   BookingStepIndicator(currentStep: BookingStep.details)   // booking_screen
///   BookingStepIndicator(currentStep: BookingStep.payment)   // payment_screen
///   BookingStepIndicator(currentStep: BookingStep.confirmed) // confirmation
enum BookingStep { details, payment, confirmed }

class BookingStepIndicator extends StatelessWidget {
  const BookingStepIndicator({super.key, required this.currentStep});
  final BookingStep currentStep;

  static const _labels = ['Details', 'Payment', 'Confirmed'];

  int get _activeIndex => BookingStep.values.indexOf(currentStep);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(BookingStep.values.length * 2 - 1, (i) {
          // Even indices = step circles, odd = connectors
          if (i.isOdd) {
            final leftStepIndex = i ~/ 2;
            final filled = leftStepIndex < _activeIndex;
            return Expanded(child: _AnimatedConnector(filled: filled));
          }
          final stepIndex = i ~/ 2;
          return _StepCircle(
            index: stepIndex,
            label: _labels[stepIndex],
            state: stepIndex < _activeIndex
                ? _StepState.completed
                : stepIndex == _activeIndex
                ? _StepState.active
                : _StepState.upcoming,
          );
        }),
      ),
    );
  }
}

// ── Step states ────────────────────────────────────────────────────────────────
enum _StepState { completed, active, upcoming }

// ── Animated connector line ────────────────────────────────────────────────────
class _AnimatedConnector extends StatelessWidget {
  const _AnimatedConnector({required this.filled});
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: filled ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      builder: (_, value, __) {
        return Stack(
          children: [
            // Track
            Container(height: 2, color: AppColors.borderLight),
            // Fill
            FractionallySizedBox(
              widthFactor: value,
              child: Container(height: 2, color: AppColors.orangeBright),
            ),
          ],
        );
      },
    );
  }
}

// ── Step circle ────────────────────────────────────────────────────────────────
class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.index,
    required this.label,
    required this.state,
  });
  final int index;
  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final isCompleted = state == _StepState.completed;
    final isActive = state == _StepState.active;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.7, end: 1.0),
          duration: const Duration(milliseconds: 350),
          curve: Curves.elasticOut,
          builder: (_, scale, child) =>
              Transform.scale(scale: isActive ? scale : 1.0, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isActive ? 32 : 26,
            height: isActive ? 32 : 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted || isActive
                  ? AppColors.orangeBright
                  : Colors.white,
              border: Border.all(
                color: isCompleted || isActive
                    ? AppColors.orangeBright
                    : AppColors.borderLight,
                width: isActive ? 2.5 : 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.orangeBright.withOpacity(0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: isActive ? 13 : 11,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF9AA0A6),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive
                ? AppColors.orangeBright
                : isCompleted
                ? AppColors.textSecondaryLight
                : AppColors.textHintLight,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
