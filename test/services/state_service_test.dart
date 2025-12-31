import 'package:flutter_test/flutter_test.dart';
import 'package:overkeys/models/keyboard_layouts.dart';
import 'package:overkeys/providers/app_state_provider.dart';
import 'package:overkeys/providers/keyboard_provider.dart';
import 'package:overkeys/providers/preferences_provider.dart';
import 'package:overkeys/services/state_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StateService', () {
    late StateService stateService;

    setUp(() {
      stateService = StateService();
      SharedPreferences.setMockInitialValues({});
    });

    group('KeyboardState persistence', () {
      test('saves and loads keyboard state', () async {
        final originalState = KeyboardState(
          layout: colemak,
          keymapStyle: 'Matrix',
          keySize: 60,
          animationEnabled: false,
          learningModeEnabled: true,
        );

        await stateService.saveKeyboardState(originalState);
        final loadedState = await stateService.loadKeyboardState();

        expect(loadedState, isNotNull);
        expect(loadedState!.layout.name, originalState.layout.name);
        expect(loadedState.keymapStyle, originalState.keymapStyle);
        expect(loadedState.keySize, originalState.keySize);
        expect(loadedState.animationEnabled, originalState.animationEnabled);
        expect(
            loadedState.learningModeEnabled, originalState.learningModeEnabled);
      });

      test('returns null when no keyboard state is saved', () async {
        final loadedState = await stateService.loadKeyboardState();
        expect(loadedState, isNull);
      });

      test('overwrites existing keyboard state', () async {
        final firstState = KeyboardState(
          layout: qwerty,
          keySize: 50,
        );
        final secondState = KeyboardState(
          layout: dvorak,
          keySize: 70,
        );

        await stateService.saveKeyboardState(firstState);
        await stateService.saveKeyboardState(secondState);

        final loadedState = await stateService.loadKeyboardState();
        expect(loadedState!.layout.name, 'Dvorak');
        expect(loadedState.keySize, 70);
      });

      test('handles save errors gracefully', () async {
        // Create a mock prefs provider that throws an exception
        Future<SharedPreferences> failingPrefsProvider() async {
          throw Exception('SharedPreferences save failed');
        }

        final failingStateService =
            StateService(prefsProvider: failingPrefsProvider);
        final state = KeyboardState(layout: qwerty);

        // Should not throw even if save fails - just completes silently
        await expectLater(
          failingStateService.saveKeyboardState(state),
          completes,
        );

        // Verify the state was not saved by checking with normal service
        final loadedState = await stateService.loadKeyboardState();
        expect(loadedState, isNull);
      });
    });

    group('PreferencesState persistence', () {
      test('saves and loads preferences state', () async {
        final originalState = PreferencesState(
          launchAtStartup: true,
          autoHideEnabled: true,
          autoHideDuration: 3.0,
          opacity: 0.8,
          kanataEnabled: true,
          kanataHost: 'localhost',
          kanataPort: 4039,
        );

        await stateService.savePreferencesState(originalState);
        final loadedState = await stateService.loadPreferencesState();

        expect(loadedState, isNotNull);
        expect(loadedState!.launchAtStartup, originalState.launchAtStartup);
        expect(loadedState.autoHideEnabled, originalState.autoHideEnabled);
        expect(loadedState.autoHideDuration, originalState.autoHideDuration);
        expect(loadedState.opacity, originalState.opacity);
        expect(loadedState.kanataEnabled, originalState.kanataEnabled);
        expect(loadedState.kanataHost, originalState.kanataHost);
        expect(loadedState.kanataPort, originalState.kanataPort);
      });

      test('returns null when no preferences state is saved', () async {
        final loadedState = await stateService.loadPreferencesState();
        expect(loadedState, isNull);
      });

      test('updates preferences state', () async {
        final firstState = PreferencesState(opacity: 0.5);
        final secondState = PreferencesState(opacity: 0.9);

        await stateService.savePreferencesState(firstState);
        await stateService.savePreferencesState(secondState);

        final loadedState = await stateService.loadPreferencesState();
        expect(loadedState!.opacity, 0.9);
      });
    });

    group('AppState persistence', () {
      test('saves and loads app state', () async {
        final originalState = AppState(
          hotKeysEnabled: false,
          enableVisibilityHotKey: false,
          enableAutoHideHotKey: true,
        );

        await stateService.saveAppState(originalState);
        final loadedState = await stateService.loadAppState();

        expect(loadedState, isNotNull);
        expect(loadedState!.hotKeysEnabled, originalState.hotKeysEnabled);
        expect(loadedState.enableVisibilityHotKey,
            originalState.enableVisibilityHotKey);
        expect(loadedState.enableAutoHideHotKey,
            originalState.enableAutoHideHotKey);
      });

      test('returns null when no app state is saved', () async {
        final loadedState = await stateService.loadAppState();
        expect(loadedState, isNull);
      });

      test('persists app state changes', () async {
        var state = AppState(hotKeysEnabled: true);
        await stateService.saveAppState(state);

        state = AppState(hotKeysEnabled: false);
        await stateService.saveAppState(state);

        final loadedState = await stateService.loadAppState();
        expect(loadedState!.hotKeysEnabled, false);
      });
    });

    group('Multiple state types', () {
      test('can save and load all state types independently', () async {
        final keyboardState = KeyboardState(
          layout: colemak,
          keySize: 55,
        );
        final preferencesState = PreferencesState(
          opacity: 0.75,
          autoHideEnabled: true,
        );
        final appState = AppState(
          hotKeysEnabled: false,
        );

        await stateService.saveKeyboardState(keyboardState);
        await stateService.savePreferencesState(preferencesState);
        await stateService.saveAppState(appState);

        final loadedKeyboard = await stateService.loadKeyboardState();
        final loadedPreferences = await stateService.loadPreferencesState();
        final loadedApp = await stateService.loadAppState();

        expect(loadedKeyboard!.layout.name, 'Colemak');
        expect(loadedPreferences!.opacity, 0.75);
        expect(loadedApp!.hotKeysEnabled, false);
      });

      test('each state type persists independently', () async {
        final keyboardState = KeyboardState(layout: qwerty);
        final preferencesState = PreferencesState(opacity: 0.5);

        await stateService.saveKeyboardState(keyboardState);
        await stateService.savePreferencesState(preferencesState);

        final loadedKeyboard = await stateService.loadKeyboardState();
        final loadedPreferences = await stateService.loadPreferencesState();

        expect(loadedKeyboard, isNotNull);
        expect(loadedPreferences, isNotNull);
        expect(loadedPreferences!.opacity, 0.5);
      });
    });

    group('Error handling', () {
      test('load methods return null on invalid JSON', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('keyboard_state', 'invalid json');

        final loadedState = await stateService.loadKeyboardState();
        expect(loadedState, isNull);
      });

      test('load methods handle missing keys gracefully', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('keyboard_state', '{"invalid": "data"}');

        // Should not throw and return null or default state
        final loadedState = await stateService.loadKeyboardState();
        // Test passes if no exception is thrown
        expect(loadedState, isNotNull); // Returns default from fromJson
      });
    });
  });
}
