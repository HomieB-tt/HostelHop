import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_theme.dart';
import '../models/hostel_model.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';

import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/owner_login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/hostel/hostel_detail_screen.dart';
import '../screens/hostel/hostel_gallery_screen.dart';
import '../screens/hostel/hostel_reviews_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/booking/booking_confirmation_screen.dart';
import '../screens/booking/my_bookings_screen.dart';
import '../screens/booking/payment_screen.dart';
import '../screens/owner/owner_dashboard_screen.dart';
import '../screens/owner/manage_hostel_screen.dart';
import '../screens/owner/manage_rooms_screen.dart';
import '../screens/owner/manage_bookings_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/settings/settings_screen.dart';
import '../screens/profile/settings/notification_settings_screen.dart';

import 'app_routes.dart';

part 'app_router.g.dart';

// ── Router provider ────────────────────────────────────────────────────────────
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  // Watch our own AppAuthState — not Supabase's raw AuthState
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) => _guard(authState, state),
    routes: [
      // ── Splash ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (_, __) => _fadePage(const SplashScreen()),
      ),

      // ── Onboarding ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, __) => _slidePage(const OnboardingScreen()),
      ),

      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (_, __) => _fadePage(const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.ownerLogin,
        pageBuilder: (_, __) => _slidePage(const OwnerLoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (_, __) => _slidePage(const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (_, __) => _slidePage(const ForgotPasswordScreen()),
      ),

      // ── Shell — bottom nav tabs ────────────────────────────────────────────
      // Home, Search, Bookings, Profile share a persistent bottom nav.
      // Each branch is a separate navigator so state is preserved on tab switch.
      StatefulShellRoute.indexedStack(
        builder: (_, __, navigationShell) =>
            _ShellScaffold(navigationShell: navigationShell),
        branches: [
          // Home branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (_, __) => _fadePage(const HomeScreen()),
              ),
            ],
          ),

          // Search branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.search,
                pageBuilder: (_, __) => _fadePage(const SearchScreen()),
              ),
            ],
          ),

          // Bookings branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.myBookings,
                pageBuilder: (_, __) => _fadePage(const MyBookingsScreen()),
              ),
            ],
          ),

          // Profile branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (_, __) => _fadePage(const ProfileScreen()),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (_, __) =>
                        _slidePage(const EditProfileScreen()),
                  ),
                  GoRoute(
                    path: 'settings',
                    pageBuilder: (_, __) => _slidePage(const SettingsScreen()),
                    routes: [
                      GoRoute(
                        path: 'notifications',
                        pageBuilder: (_, __) =>
                            _slidePage(const NotificationSettingsScreen()),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Hostel ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.pathHostelDetail,
        pageBuilder: (_, state) {
          final hostelId = state.pathParameters['hostelId']!;
          return _slidePage(HostelDetailScreen(hostelId: hostelId));
        },
        routes: [
          GoRoute(
            path: 'gallery',
            pageBuilder: (_, state) {
              final hostelId = state.pathParameters['hostelId']!;
              return _slidePage(HostelGalleryScreen(hostelId: hostelId));
            },
          ),
          GoRoute(
            path: 'reviews',
            pageBuilder: (_, state) {
              final hostelId = state.pathParameters['hostelId']!;
              return _slidePage(HostelReviewsScreen(hostelId: hostelId));
            },
          ),
        ],
      ),

      // ── Booking flow ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.pathBooking,
        pageBuilder: (_, state) {
          final hostelId = state.pathParameters['hostelId']!;
          return _slidePage(BookingScreen(hostelId: hostelId));
        },
      ),
      GoRoute(
        path: AppRoutes.pathPayment,
        pageBuilder: (_, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return _slidePage(PaymentScreen(bookingId: bookingId));
        },
      ),
      GoRoute(
        path: AppRoutes.pathBookingConfirmation,
        pageBuilder: (_, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return _fadePage(BookingConfirmationScreen(bookingId: bookingId));
        },
      ),

      // ── Owner ─────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.ownerDashboard,
        pageBuilder: (_, __) => _fadePage(const OwnerDashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.manageHostel,
        pageBuilder: (_, state) {
          // extra is HostelModel? — null = create mode, non-null = edit mode
          final hostel = state.extra as HostelModel?;
          return _slidePage(ManageHostelScreen(hostel: hostel));
        },
      ),
      GoRoute(
        path: AppRoutes.manageRooms,
        pageBuilder: (_, state) {
          final hostelId = state.extra as String;
          return _slidePage(ManageRoomsScreen(hostelId: hostelId));
        },
      ),
      GoRoute(
        path: AppRoutes.manageBookings,
        pageBuilder: (_, state) {
          final hostelId = state.extra as String;
          return _slidePage(ManageBookingsScreen(hostelId: hostelId));
        },
      ),
    ],
  );
}

// ── Auth guard ─────────────────────────────────────────────────────────────────
// authState is our own AppAuthState from auth_provider.dart (not Supabase's AuthState)
String? _guard(AppAuthState authState, GoRouterState state) {
  final location = state.matchedLocation;

  // While auth is resolving, stay put — prevents login flicker on cold start
  if (authState.isLoading) return null;

  // Public routes — always accessible
  const publicRoutes = {
    AppRoutes.splash,
    AppRoutes.onboarding,
    AppRoutes.login,
    AppRoutes.ownerLogin,
    AppRoutes.register,
    AppRoutes.forgotPassword,
  };

  final isPublic = publicRoutes.contains(location);
  final isLoggedIn = authState.user != null;
  final isOwner = authState.isOwner;

  // Not logged in → redirect to login (except public routes)
  if (!isLoggedIn && !isPublic) return AppRoutes.login;

  // Logged in + trying to access auth screens → redirect to appropriate home
  if (isLoggedIn && isPublic && location != AppRoutes.splash) {
    return isOwner ? AppRoutes.ownerDashboard : AppRoutes.home;
  }

  // Owner-only routes — non-owners get redirected to home
  const ownerRoutes = {
    AppRoutes.ownerDashboard,
    AppRoutes.manageHostel,
    AppRoutes.manageRooms,
    AppRoutes.manageBookings,
  };

  if (ownerRoutes.contains(location) && !isOwner) {
    return AppRoutes.home;
  }

  return null; // no redirect
}

// ── Shell scaffold — persistent bottom nav ─────────────────────────────────────
class _ShellScaffold extends ConsumerWidget {
  const _ShellScaffold({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for notification deep links — navigate to booking detail on tap
    ref.listen(notificationDeepLinkProvider, (_, next) {
      next.whenData((bookingId) {
        if (bookingId != null && context.mounted) {
          context.push(AppRoutes.bookingConfirmation(bookingId));
        }
      });
    });

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          // Return to branch root when re-tapping active tab
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ── App bottom nav ─────────────────────────────────────────────────────────────
class _AppBottomNav extends StatelessWidget {
  const _AppBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
      ),
      _NavItem(icon: Icons.search, activeIcon: Icons.search, label: 'Explore'),
      _NavItem(
        icon: Icons.bookmark_border,
        activeIcon: Icons.bookmark,
        label: 'Bookings',
      ),
      _NavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EAED))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: List.generate(items.length, (i) {
              final isActive = i == currentIndex;
              final item = items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: 20,
                        color: isActive
                            ? AppColors.orangeBright
                            : const Color(0xFF9AA0A6),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppColors.orangeBright
                              : const Color(0xFF9AA0A6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 4 : 0,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.orangeBright,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ── Page transition helpers ────────────────────────────────────────────────────
CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 220),
  );
}

CustomTransitionPage<void> _slidePage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}
