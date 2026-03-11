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

String _$userProfileHash() => r'a25dbda38b910925d7a32c3e579a8536bfae7da5';

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
