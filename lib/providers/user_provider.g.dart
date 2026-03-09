// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watched by profile_screen, edit_profile_screen as:
///   final profileAsync = ref.watch(userProfileProvider);

@ProviderFor(UserProfile)
final userProfileProvider = UserProfileProvider._();

/// Watched by profile_screen, edit_profile_screen as:
///   final profileAsync = ref.watch(userProfileProvider);
final class UserProfileProvider
    extends $AsyncNotifierProvider<UserProfile, UserModel> {
  /// Watched by profile_screen, edit_profile_screen as:
  ///   final profileAsync = ref.watch(userProfileProvider);
  UserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @$internal
  @override
  UserProfile create() => UserProfile();
}

String _$userProfileHash() => r'4e457873bc6d130ba5aaff4ef819399265df1445';

/// Watched by profile_screen, edit_profile_screen as:
///   final profileAsync = ref.watch(userProfileProvider);

abstract class _$UserProfile extends $AsyncNotifier<UserModel> {
  FutureOr<UserModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserModel>, UserModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserModel>, UserModel>,
              AsyncValue<UserModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
