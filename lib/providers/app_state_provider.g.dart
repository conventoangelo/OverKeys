// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppStateNotifier)
final appStateProvider = AppStateNotifierProvider._();

final class AppStateNotifierProvider
    extends $NotifierProvider<AppStateNotifier, AppState> {
  AppStateNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appStateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appStateNotifierHash();

  @$internal
  @override
  AppStateNotifier create() => AppStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppState>(value),
    );
  }
}

String _$appStateNotifierHash() => r'75071a9643da88cea7967e2e8bdc04d8bdaec74f';

abstract class _$AppStateNotifier extends $Notifier<AppState> {
  AppState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppState, AppState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AppState, AppState>, AppState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
