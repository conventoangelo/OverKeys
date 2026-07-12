// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KeyboardNotifier)
final keyboardProvider = KeyboardNotifierProvider._();

final class KeyboardNotifierProvider
    extends $NotifierProvider<KeyboardNotifier, KeyboardState> {
  KeyboardNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'keyboardProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$keyboardNotifierHash();

  @$internal
  @override
  KeyboardNotifier create() => KeyboardNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KeyboardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KeyboardState>(value),
    );
  }
}

String _$keyboardNotifierHash() => r'17e99a7e87520c3bbcd9a85ee7bdf027688bcafe';

abstract class _$KeyboardNotifier extends $Notifier<KeyboardState> {
  KeyboardState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<KeyboardState, KeyboardState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<KeyboardState, KeyboardState>,
        KeyboardState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
