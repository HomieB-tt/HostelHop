// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hostel_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watched by home_screen.dart as:
///   final hostelState = ref.watch(hostelListProvider);
///   hostelState.when(loading:..., error:..., data:...)

@ProviderFor(HostelList)
final hostelListProvider = HostelListProvider._();

/// Watched by home_screen.dart as:
///   final hostelState = ref.watch(hostelListProvider);
///   hostelState.when(loading:..., error:..., data:...)
final class HostelListProvider
    extends $AsyncNotifierProvider<HostelList, List<HostelModel>> {
  /// Watched by home_screen.dart as:
  ///   final hostelState = ref.watch(hostelListProvider);
  ///   hostelState.when(loading:..., error:..., data:...)
  HostelListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hostelListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hostelListHash();

  @$internal
  @override
  HostelList create() => HostelList();
}

String _$hostelListHash() => r'fa77cc1c8a81a9c563be7a5c10c1a6efee1a180d';

/// Watched by home_screen.dart as:
///   final hostelState = ref.watch(hostelListProvider);
///   hostelState.when(loading:..., error:..., data:...)

abstract class _$HostelList extends $AsyncNotifier<List<HostelModel>> {
  FutureOr<List<HostelModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<HostelModel>>, List<HostelModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<HostelModel>>, List<HostelModel>>,
              AsyncValue<List<HostelModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Watched by hostel_detail_screen and booking_screen as:
///   final hostelAsync = ref.watch(hostelDetailProvider(hostelId));

@ProviderFor(hostelDetail)
final hostelDetailProvider = HostelDetailFamily._();

/// Watched by hostel_detail_screen and booking_screen as:
///   final hostelAsync = ref.watch(hostelDetailProvider(hostelId));

final class HostelDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostelModel>,
          HostelModel,
          FutureOr<HostelModel>
        >
    with $FutureModifier<HostelModel>, $FutureProvider<HostelModel> {
  /// Watched by hostel_detail_screen and booking_screen as:
  ///   final hostelAsync = ref.watch(hostelDetailProvider(hostelId));
  HostelDetailProvider._({
    required HostelDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostelDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostelDetailHash();

  @override
  String toString() {
    return r'hostelDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HostelModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostelModel> create(Ref ref) {
    final argument = this.argument as String;
    return hostelDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostelDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostelDetailHash() => r'7faaa0a1032f15b47ee636644835459781e4c3c9';

/// Watched by hostel_detail_screen and booking_screen as:
///   final hostelAsync = ref.watch(hostelDetailProvider(hostelId));

final class HostelDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<HostelModel>, String> {
  HostelDetailFamily._()
    : super(
        retry: null,
        name: r'hostelDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watched by hostel_detail_screen and booking_screen as:
  ///   final hostelAsync = ref.watch(hostelDetailProvider(hostelId));

  HostelDetailProvider call(String hostelId) =>
      HostelDetailProvider._(argument: hostelId, from: this);

  @override
  String toString() => r'hostelDetailProvider';
}

/// Watched by owner dashboard as:
///   final hostelsAsync = ref.watch(ownerHostelListProvider);

@ProviderFor(ownerHostelList)
final ownerHostelListProvider = OwnerHostelListProvider._();

/// Watched by owner dashboard as:
///   final hostelsAsync = ref.watch(ownerHostelListProvider);

final class OwnerHostelListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HostelModel>>,
          List<HostelModel>,
          FutureOr<List<HostelModel>>
        >
    with
        $FutureModifier<List<HostelModel>>,
        $FutureProvider<List<HostelModel>> {
  /// Watched by owner dashboard as:
  ///   final hostelsAsync = ref.watch(ownerHostelListProvider);
  OwnerHostelListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ownerHostelListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ownerHostelListHash();

  @$internal
  @override
  $FutureProviderElement<List<HostelModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HostelModel>> create(Ref ref) {
    return ownerHostelList(ref);
  }
}

String _$ownerHostelListHash() => r'b4f9992b7779345f3a182725c31c743805eb9643';
