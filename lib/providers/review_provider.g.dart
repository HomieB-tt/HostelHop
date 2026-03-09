// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Watched by hostel_reviews_screen as:
///   final reviewsAsync = ref.watch(hostelReviewsProvider(hostelId));

@ProviderFor(HostelReviews)
final hostelReviewsProvider = HostelReviewsFamily._();

/// Watched by hostel_reviews_screen as:
///   final reviewsAsync = ref.watch(hostelReviewsProvider(hostelId));
final class HostelReviewsProvider
    extends $AsyncNotifierProvider<HostelReviews, List<ReviewModel>> {
  /// Watched by hostel_reviews_screen as:
  ///   final reviewsAsync = ref.watch(hostelReviewsProvider(hostelId));
  HostelReviewsProvider._({
    required HostelReviewsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hostelReviewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostelReviewsHash();

  @override
  String toString() {
    return r'hostelReviewsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HostelReviews create() => HostelReviews();

  @override
  bool operator ==(Object other) {
    return other is HostelReviewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostelReviewsHash() => r'393a966af95b2001d6b85e461bbed70708f474b4';

/// Watched by hostel_reviews_screen as:
///   final reviewsAsync = ref.watch(hostelReviewsProvider(hostelId));

final class HostelReviewsFamily extends $Family
    with
        $ClassFamilyOverride<
          HostelReviews,
          AsyncValue<List<ReviewModel>>,
          List<ReviewModel>,
          FutureOr<List<ReviewModel>>,
          String
        > {
  HostelReviewsFamily._()
    : super(
        retry: null,
        name: r'hostelReviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watched by hostel_reviews_screen as:
  ///   final reviewsAsync = ref.watch(hostelReviewsProvider(hostelId));

  HostelReviewsProvider call(String hostelId) =>
      HostelReviewsProvider._(argument: hostelId, from: this);

  @override
  String toString() => r'hostelReviewsProvider';
}

/// Watched by hostel_reviews_screen as:
///   final reviewsAsync = ref.watch(hostelReviewsProvider(hostelId));

abstract class _$HostelReviews extends $AsyncNotifier<List<ReviewModel>> {
  late final _$args = ref.$arg as String;
  String get hostelId => _$args;

  FutureOr<List<ReviewModel>> build(String hostelId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ReviewModel>>, List<ReviewModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ReviewModel>>, List<ReviewModel>>,
              AsyncValue<List<ReviewModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
