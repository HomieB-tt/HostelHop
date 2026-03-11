import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/async_value_widget.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.borderLight),
        ),
      ),
      body: AsyncValueWidget<UserModel>(
        value: profileAsync,
        data: (profile) => _EditForm(profile: profile),
      ),
    );
  }
}

// ── Edit form ──────────────────────────────────────────────────────────────────
class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.profile});
  final UserModel profile;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _universityCtrl;
  late final TextEditingController _studentIdCtrl;

  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final parts = widget.profile.fullName.split(' ');
    _firstNameCtrl = TextEditingController(
      text: parts.isNotEmpty ? parts.first : '',
    );
    _lastNameCtrl = TextEditingController(
      text: parts.length > 1 ? parts.sublist(1).join(' ') : '',
    );
    _phoneCtrl = TextEditingController(text: widget.profile.phone);
    _universityCtrl = TextEditingController(
      text: widget.profile.university ?? '',
    );
    _studentIdCtrl = TextEditingController(
      text: widget.profile.studentId ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _universityCtrl.dispose();
    _studentIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _uploadAvatar() async {
    setState(() => _isUploadingAvatar = true);
    try {
      await ref.read(userProfileProvider.notifier).updateAvatar();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avatar upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    try {
      await ref
          .read(userProfileProvider.notifier)
          .updateProfile(
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated ✅'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).value ?? widget.profile;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Avatar ────────────────────────────────────────────────────────
          Center(
            child: Stack(
              children: [
                _isUploadingAvatar
                    ? Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.borderLight,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.orangeBright,
                            ),
                          ),
                        ),
                      )
                    : AppNetworkImage.avatar(
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
                    onTap: _isUploadingAvatar ? null : _uploadAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.orangeBright,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: TextButton(
              onPressed: _isUploadingAvatar ? null : _uploadAvatar,
              child: const Text(
                'Change Photo',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.orangeBright,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Name ──────────────────────────────────────────────────────────
          _Card(
            title: 'Personal Info',
            children: [
              AppTextField(
                label: 'First Name',
                hint: 'e.g. James',
                controller: _firstNameCtrl,
                validator: Validators.firstName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Last Name',
                hint: 'e.g. Ssali',
                controller: _lastNameCtrl,
                validator: Validators.lastName,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Phone Number',
                hint: '0700000000',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
                textInputAction: TextInputAction.next,
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '🇺🇬 +256',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Academic info ─────────────────────────────────────────────────
          _Card(
            title: 'Academic Info (Optional)',
            children: [
              AppTextField(
                label: 'University',
                hint: 'e.g. Makerere University',
                controller: _universityCtrl,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Student ID',
                hint: 'e.g. 21/U/12345',
                controller: _studentIdCtrl,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Save ──────────────────────────────────────────────────────────
          AppButton(
            label: 'Save Changes',
            onPressed: _isSaving ? null : _save,
            isLoading: _isSaving,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Card wrapper ───────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
