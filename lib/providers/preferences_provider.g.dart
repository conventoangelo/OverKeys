// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PreferencesNotifier)
final preferencesProvider = PreferencesNotifierProvider._();

final class PreferencesNotifierProvider
    extends $NotifierProvider<PreferencesNotifier, PreferencesState> {
  PreferencesNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'preferencesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$preferencesNotifierHash();

  @$internal
  @override
  PreferencesNotifier create() => PreferencesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreferencesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreferencesState>(value),
    );
  }
}

String _$preferencesNotifierHash() =>
    r'93fcdbcdf48599b6ff9a013e3bb98d4c15f778de';

abstract class _$PreferencesNotifier extends $Notifier<PreferencesState> {
  PreferencesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PreferencesState, PreferencesState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<PreferencesState, PreferencesState>,
        PreferencesState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
