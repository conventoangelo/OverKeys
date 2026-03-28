import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:overkeys/providers/app_state_provider.dart';

void main() {
  group('AppState', () {
    group('Constructor', () {
      test('creates AppState with default values', () {
        final state = AppState();

        expect(state.isWindowVisible, true);
        expect(state.ignoreMouseEvents, true);
        expect(state.forceHide, false);
        expect(state.autoHideBeforeForceHide, false);
        expect(state.hotKeysEnabled, true);
        expect(state.enableVisibilityHotKey, true);
        expect(state.enableAutoHideHotKey, true);
        expect(state.enableToggleMoveHotKey, true);
        expect(state.enableToggleTopRowHotKey, true);
        expect(state.enablePreferencesHotKey, true);
        expect(state.showStatusOverlay, false);
        expect(state.overlayMessage, '');
        expect(state.activeTriggers, isEmpty);
      });

      test('creates AppState with custom values', () {
        final state = AppState(
          isWindowVisible: false,
          ignoreMouseEvents: false,
          forceHide: true,
          hotKeysEnabled: false,
          enableVisibilityHotKey: false,
          showStatusOverlay: true,
          overlayMessage: 'Test message',
        );

        expect(state.isWindowVisible, false);
        expect(state.ignoreMouseEvents, false);
        expect(state.forceHide, true);
        expect(state.hotKeysEnabled, false);
        expect(state.enableVisibilityHotKey, false);
        expect(state.showStatusOverlay, true);
        expect(state.overlayMessage, 'Test message');
      });

      test('initializes with default hotkeys', () {
        final state = AppState();

        expect(state.visibilityHotKey, isNotNull);
        expect(state.autoHideHotKey, isNotNull);
        expect(state.toggleMoveHotKey, isNotNull);
        expect(state.toggleTopRowHotKey, isNotNull);
        expect(state.preferencesHotKey, isNotNull);
        expect(state.increaseOpacityHotKey, isNotNull);
        expect(state.decreaseOpacityHotKey, isNotNull);
      });

      test('uses custom hotkeys when provided', () {
        final customHotKey = HotKey(
          key: PhysicalKeyboardKey.keyA,
          modifiers: [HotKeyModifier.shift],
        );

        final state = AppState(visibilityHotKey: customHotKey);

        expect(state.visibilityHotKey, equals(customHotKey));
      });
    });

    group('copyWith', () {
      test('creates copy with updated visibility state', () {
        final original = AppState(isWindowVisible: true);
        final updated = original.copyWith(isWindowVisible: false);

        expect(updated.isWindowVisible, false);
        expect(original.isWindowVisible, true); // Original unchanged
      });

      test('creates copy with updated force hide state', () {
        final original = AppState(forceHide: false);
        final updated = original.copyWith(forceHide: true);

        expect(updated.forceHide, true);
        expect(original.forceHide, false);
      });

      test('creates copy with updated hotkey enabled flags', () {
        final original = AppState(
          enableVisibilityHotKey: true,
          enableAutoHideHotKey: true,
          enableToggleTopRowHotKey: true,
        );

        final updated = original.copyWith(
          enableVisibilityHotKey: false,
          enableAutoHideHotKey: false,
          enableToggleTopRowHotKey: false,
        );

        expect(updated.enableVisibilityHotKey, false);
        expect(updated.enableAutoHideHotKey, false);
        expect(updated.enableToggleTopRowHotKey, false);
        expect(original.enableVisibilityHotKey, true);
        expect(original.enableAutoHideHotKey, true);
        expect(original.enableToggleTopRowHotKey, true);
      });

      test('creates copy with updated overlay state', () {
        final original = AppState(
          showStatusOverlay: false,
          overlayMessage: '',
        );

        final updated = original.copyWith(
          showStatusOverlay: true,
          overlayMessage: 'New message',
        );

        expect(updated.showStatusOverlay, true);
        expect(updated.overlayMessage, 'New message');
      });

      test('creates copy with updated hotkey', () {
        final original = AppState();
        final newHotKey = HotKey(
          key: PhysicalKeyboardKey.keyZ,
          modifiers: [HotKeyModifier.control],
        );

        final updated = original.copyWith(visibilityHotKey: newHotKey);

        expect(updated.visibilityHotKey, equals(newHotKey));
        expect(original.visibilityHotKey, isNot(equals(newHotKey)));
      });

      test('creates copy with updated active triggers', () {
        final original = AppState(activeTriggers: {'trigger1'});
        final updated =
            original.copyWith(activeTriggers: {'trigger2', 'trigger3'});

        expect(updated.activeTriggers, {'trigger2', 'trigger3'});
        expect(original.activeTriggers, {'trigger1'});
      });

      test('preserves unchanged properties', () {
        final original = AppState(
          isWindowVisible: true,
          hotKeysEnabled: false,
          overlayMessage: 'Keep this',
        );

        final updated = original.copyWith(forceHide: true);

        expect(updated.isWindowVisible, true);
        expect(updated.hotKeysEnabled, false);
        expect(updated.overlayMessage, 'Keep this');
        expect(updated.forceHide, true);
      });
    });

    group('toJson and fromJson', () {
      test('serializes AppState to JSON', () {
        final state = AppState(
          hotKeysEnabled: false,
          enableVisibilityHotKey: false,
          enableAutoHideHotKey: true,
          enableToggleTopRowHotKey: false,
        );

        final json = state.toJson();

        // Only hotkey-related fields are serialized
        expect(json['hotKeysEnabled'], false);
        expect(json['enableVisibilityHotKey'], false);
        expect(json['enableAutoHideHotKey'], true);
        expect(json['enableToggleTopRowHotKey'], false);
        expect(json.containsKey('isWindowVisible'), false); // Not serialized
        expect(json.containsKey('forceHide'), false); // Not serialized
      });

      test('deserializes AppState from JSON', () {
        final json = {
          'hotKeysEnabled': false,
          'enableVisibilityHotKey': false,
          'enableAutoHideHotKey': true,
          'enableToggleTopRowHotKey': false,
        };

        final state = AppState.fromJson(json);

        // Only these fields are deserialized in fromJson
        expect(state.hotKeysEnabled, false);
        expect(state.enableVisibilityHotKey, false);
        expect(state.enableAutoHideHotKey, true);
        expect(state.enableToggleTopRowHotKey, false);
      });

      test('round-trip serialization preserves state', () {
        final original = AppState(
          hotKeysEnabled: false,
          enableVisibilityHotKey: true,
          enableAutoHideHotKey: false,
          enableToggleTopRowHotKey: false,
        );

        final json = original.toJson();
        final roundTrip = AppState.fromJson(json);

        // Only these fields are actually serialized/deserialized
        expect(roundTrip.hotKeysEnabled, original.hotKeysEnabled);
        expect(
            roundTrip.enableVisibilityHotKey, original.enableVisibilityHotKey);
        expect(roundTrip.enableAutoHideHotKey, original.enableAutoHideHotKey);
        expect(roundTrip.enableToggleTopRowHotKey,
            original.enableToggleTopRowHotKey);
      });

      test('handles empty JSON', () {
        final state = AppState.fromJson({});

        // Should use default values
        expect(state.isWindowVisible, true);
        expect(state.hotKeysEnabled, true);
      });
    });

    group('State transitions', () {
      test('can toggle window visibility', () {
        var state = AppState(isWindowVisible: true);
        state = state.copyWith(isWindowVisible: false);
        state = state.copyWith(isWindowVisible: true);

        expect(state.isWindowVisible, true);
      });

      test('can manage force hide workflow', () {
        var state = AppState(
          isWindowVisible: true,
          forceHide: false,
        );

        // Force hide
        state = state.copyWith(
          forceHide: true,
          isWindowVisible: false,
        );
        expect(state.forceHide, true);
        expect(state.isWindowVisible, false);

        // Restore
        state = state.copyWith(
          forceHide: false,
          isWindowVisible: true,
        );
        expect(state.forceHide, false);
        expect(state.isWindowVisible, true);
      });

      test('can toggle multiple hotkey enable flags', () {
        var state = AppState(
          enableVisibilityHotKey: true,
          enableAutoHideHotKey: true,
          enableToggleMoveHotKey: true,
          enableToggleTopRowHotKey: true,
        );

        state = state.copyWith(
          enableVisibilityHotKey: false,
          enableAutoHideHotKey: false,
        );

        expect(state.enableVisibilityHotKey, false);
        expect(state.enableAutoHideHotKey, false);
        expect(state.enableToggleMoveHotKey, true); // Unchanged
        expect(state.enableToggleTopRowHotKey, true); // Unchanged
      });
    });
  });
}
