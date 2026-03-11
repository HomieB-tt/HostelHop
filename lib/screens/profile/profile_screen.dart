import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/common/async_value_widget.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/fade_up_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: AsyncValueWidget<UserModel>(
        value: profileAsync,
        data: (profile) => FadeUpWidget(child: _ProfileBody(profile: profile)),
      ),
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────
class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});
  final UserModel profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // ── Header ────────────────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: AppColors.orangePrimary,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: _ProfileHeader(profile: profile),
          ),
          title: const Text(
            'My Profile',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit profile',
              onPressed: () => context.push(AppRoutes.editProfile),
            ),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Account info ────────────────────────────────────────────
                _SectionCard(
                  children: [
                    _InfoTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Full Name',
                      value: profile.fullName,
                    ),
                    _divider(),
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: profile.phone,
                    ),
                    _divider(),
                    _InfoTile(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: profile.email.isNotEmpty
                          ? profile.email
                          : 'Not set',
                    ),
                    if (profile.university != null) ...[
                      _divider(),
                      _InfoTile(
                        icon: Icons.school_outlined,
                        label: 'University',
                        value: profile.university!,
                      ),
                    ],
                    if (profile.studentId != null) ...[
                      _divider(),
                      _InfoTile(
                        icon: Icons.badge_outlined,
                        label: 'Student ID',
                        value: profile.studentId!,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // ── Quick links ────────────────────────────────────────────
                const _SectionTitle(title: 'Account'),
                const SizedBox(height: 8),
                _SectionCard(
                  children: [
                    _LinkTile(
                      icon: Icons.book_outlined,
                      label: 'My Bookings',
                      onTap: () => context.push(AppRoutes.myBookings),
                    ),
                    _divider(),
                    _LinkTile(
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile',
                      onTap: () => context.push(AppRoutes.editProfile),
                    ),
                    _divider(),
                    _LinkTile(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                    _divider(),
                    _LinkTile(
                      icon: Icons.notifications_outlined,
                      label: 'Notification Settings',
                      onTap: () => context.push(AppRoutes.notificationSettings),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Support ────────────────────────────────────────────────
                const _SectionTitle(title: 'Support'),
                const SizedBox(height: 8),
                _SectionCard(
                  children: [
                    _LinkTile(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & FAQ',
                      onTap: () {},
                    ),
                    _divider(),
                    _LinkTile(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _divider(),
                    _LinkTile(
                      icon: Icons.description_outlined,
                      label: 'Terms of Service',
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Sign out ──────────────────────────────────────────────
                _SectionCard(
                  children: [
                    _LinkTile(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      labelColor: AppColors.error,
                      iconColor: AppColors.error,
                      showChevron: false,
                      onTap: () async {
                        await ref.read(authProvider.notifier).signOut();
                        if (context.mounted) {
                          context.go(AppRoutes.login);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 46, color: AppColors.borderLight);
}

// ── Profile header ─────────────────────────────────────────────────────────────
class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader({required this.profile});
  final UserModel profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.orangePrimary, AppColors.orangeDim],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Avatar
            Stack(
              children: [
                AppNetworkImage.avatar(
                  url: profile.avatarUrl,
                  size: 44,
                  initials: profile.firstName.isNotEmpty
                      ? profile.firstName[0].toUpperCase()
                      : '?',
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () async {
                      await ref
                          .read(userProfileProvider.notifier)
                          .updateAvatar();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 14,
                        color: AppColors.orangeBright,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Name
            Text(
              profile.fullName,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                profile.role.name[0].toUpperCase() +
                    profile.role.name.substring(1),
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable tiles & helpers ───────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      fontFamily: 'Sora',
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.textSecondaryLight,
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textHintLight),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 11,
                  color: AppColors.textHintLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.iconColor,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? iconColor;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: iconColor ?? AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: labelColor ?? AppColors.textPrimaryLight,
                ),
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textHintLight,
              ),
          ],
        ),
      ),
    );
  }
}
