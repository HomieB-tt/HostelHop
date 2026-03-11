// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Use `ref.read(bookingProvider.notifier)` to call actions.
/// State is the last created/updated booking — mainly used for loading guards.

@ProviderFor(Booking)
final bookingProvider = BookingProvider._();

/// Use `ref.read(bookingProvider.notifier)` to call actions.
/// State is the last created/updated booking — mainly used for loading guards.
final class BookingProvider
    extends $NotifierProvider<Booking, AsyncValue<BookingModel?>> {
  /// Use `ref.read(bookingProvider.notifier)` to call actions.
  /// State is the last created/updated booking — mainly used for loading guards.
  BookingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingHash();

  @$internal
  @override
  Booking create() => Booking();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<BookingModel?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<BookingModel?>>(value),
    );
  }
}

String _$bookingHash() => r'a337d891566c7d6831bfb2df5cb5eefff4538f2f';

/// Use `ref.read(bookingProvider.notifier)` to call actions.
/// State is the last created/updated booking — mainly used for loading guards.

abstract class _$Booking extends $Notifier<AsyncValue<BookingModel?>> {
  AsyncValue<BookingModel?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<BookingModel?>, AsyncValue<BookingModel?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BookingModel?>, AsyncValue<BookingModel?>>,
              AsyncValue<BookingModel?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Watched by payment_screen and booking_confirmation_screen as:
///   final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

@ProviderFor(bookingDetail)
final bookingDetailProvider = BookingDetailFamily._();

/// Watched by payment_screen and booking_confirmation_screen as:
///   final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

final class BookingDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookingModel>,
          BookingModel,
          FutureOr<BookingModel>
        >
    with $FutureModifier<BookingModel>, $FutureProvider<BookingModel> {
  /// Watched by payment_screen and booking_confirmation_screen as:
  ///   final bookingAsync = ref.watch(bookingDetailProvider(bookingId));
  BookingDetailProvider._({
    required BookingDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookingDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingDetailHash();

  @override
  String toString() {
    return r'bookingDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BookingModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BookingModel> create(Ref ref) {
    final argument = this.argument as String;
    return bookingDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingDetailHash() => r'ef96e612aa1e9b1b606cb088e507f7bffd6aaa28';

/// Watched by payment_screen and booking_confirmation_screen as:
///   final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

final class BookingDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BookingModel>, String> {
  BookingDetailFamily._()
    : super(
        retry: null,
        name: r'bookingDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Watched by payment_screen and booking_confirmation_screen as:
  ///   final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

  BookingDetailProvider call(String bookingId) =>
      BookingDetailProvider._(argument: bookingId, from: this);

  @override
  String toString() => r'bookingDetailProvider';
}

/// Watched by my_bookings_screen as:
///   final bookingsAsync = ref.watch(myBookingsProvider);

@ProviderFor(myBookings)
final myBookingsProvider = MyBookingsProvider._();

/// Watched by my_bookings_screen as:
///   final bookingsAsync = ref.watch(myBookingsProvider);

final class MyBookingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BookingModel>>,
          List<BookingModel>,
          FutureOr<List<BookingModel>>
        >
    with
        $FutureModifier<List<BookingModel>>,
        $FutureProvider<List<BookingModel>> {
  /// Watched by my_bookings_screen as:
  ///   final bookingsAsync = ref.watch(myBookingsProvider);
  MyBookingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBookingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBookingsHash();

  @$internal
  @override
  $FutureProviderElement<List<BookingModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BookingModel>> create(Ref ref) {
    return myBookings(ref);
  }
}

String _$myBookingsHash() => r'43cd3b14b62a8619962ea0a8e6c2bbe6524904b1';
