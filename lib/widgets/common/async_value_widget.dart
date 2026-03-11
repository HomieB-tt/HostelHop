import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_empty_state.dart';
import 'app_error_widget.dart';
import 'app_loading_indicator.dart';

/// A generic widget that handles all three Riverpod [AsyncValue] states
/// — loading, error, and data — in one place.
///
/// Basic usage:
///   AsyncValueWidget<List<HostelModel>>(
///     value: ref.watch(hostelListProvider),
///     data: (hostels) => HostelList(hostels),
///   )
///
/// With empty state:
///   AsyncValueWidget<List<HostelModel>>(
///     value: ref.watch(hostelListProvider),
///     data: (hostels) => HostelList(hostels),
///     isEmpty: (hostels) => hostels.isEmpty,
///     empty: AppEmptyState.noHostels(),
///   )
///
/// With custom loading / error:
///   AsyncValueWidget<HostelModel>(
///     value: ref.watch(hostelDetailProvider(id)),
///     data: (hostel) => HostelDetailBody(hostel),
///     loading: const AppLoadingScreen(message: 'Loading hostel…'),
///     error: (e, st) => AppErrorWidget(
///       message: e.toString(),
///       onRetry: () => ref.refresh(hostelDetailProvider(id)),
///     ),
///   )
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.empty,
    this.isEmpty,
  });

  /// The [AsyncValue] from a Riverpod provider.
  final AsyncValue<T> value;

  /// Builder called when data is available (and not empty).
  final Widget Function(T data) data;

  /// Widget shown while loading. Defaults to [AppLoadingScreen].
  final Widget? loading;

  /// Builder called on error. Defaults to [AppErrorWidget].
  final Widget Function(Object error, StackTrace? stackTrace)? error;

  /// Widget shown when [isEmpty] returns true.
  /// If omitted, empty data falls through to [data].
  final Widget? empty;

  /// Predicate that determines whether [T] is considered empty.
  /// Only evaluated when [empty] is also provided.
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading ?? const AppLoadingScreen(),
      error: (e, st) =>
          error != null ? error!(e, st) : AppErrorWidget(message: e.toString()),
      data: (d) {
        // ── Empty state check ───────────────────────────────────────────────
        if (empty != null && isEmpty != null && isEmpty!(d)) {
          return empty!;
        }
        return data(d);
      },
    );
  }
}

/// A sliver-compatible variant of [AsyncValueWidget].
/// Use inside [CustomScrollView] / [NestedScrollView].
///
/// Usage:
///   CustomScrollView(
///     slivers: [
///       SliverAsyncValueWidget<List<HostelModel>>(
///         value: ref.watch(hostelListProvider),
///         data: (hostels) => SliverList(...),
///         empty: const SliverToBoxAdapter(child: AppEmptyState.noHostels()),
///         isEmpty: (h) => h.isEmpty,
///       ),
///     ],
///   )
class SliverAsyncValueWidget<T> extends StatelessWidget {
  const SliverAsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.empty,
    this.isEmpty,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final Widget Function(Object error, StackTrace? stackTrace)? error;
  final Widget? empty;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () =>
          loading ?? const SliverFillRemaining(child: AppLoadingScreen()),
      error: (e, st) => SliverFillRemaining(
        child: error != null
            ? error!(e, st)
            : AppErrorWidget(message: e.toString()),
      ),
      data: (d) {
        if (empty != null && isEmpty != null && isEmpty!(d)) {
          return empty!;
        }
        return data(d);
      },
    );
  }
}
