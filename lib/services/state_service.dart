import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/keyboard_provider.dart';
import '../providers/preferences_provider.dart';
import '../providers/app_state_provider.dart';

/// Service for loading and saving application state across sessions
/// Uses SharedPreferences to persist keyboard, preferences, and app state
class StateService {
  static const String _keyboardStateKey = 'keyboard_state';
  static const String _preferencesStateKey = 'preferences_state';
  static const String _appStateKey = 'app_state';

  /// Load keyboard state from persistence
  Future<KeyboardState?> loadKeyboardState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyboardStateKey);
      if (jsonString == null) return null;

      final Map<String, dynamic> json = jsonDecode(jsonString);
      return KeyboardState.fromJson(json);
    } catch (e) {
      if (kDebugMode) print('Error loading keyboard state: $e');
      return null;
    }
  }

  /// Save keyboard state to persistence
  Future<void> saveKeyboardState(KeyboardState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_keyboardStateKey, jsonString);
    } catch (e) {
      if (kDebugMode) print('Error saving keyboard state: $e');
    }
  }

  /// Load preferences state from persistence
  Future<PreferencesState?> loadPreferencesState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_preferencesStateKey);
      if (jsonString == null) return null;

      final Map<String, dynamic> json = jsonDecode(jsonString);
      return PreferencesState.fromJson(json);
    } catch (e) {
      if (kDebugMode) print('Error loading preferences state: $e');
      return null;
    }
  }

  /// Save preferences state to persistence
  Future<void> savePreferencesState(PreferencesState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_preferencesStateKey, jsonString);
    } catch (e) {
      if (kDebugMode) print('Error saving preferences state: $e');
    }
  }

  /// Load app state from persistence
  Future<AppState?> loadAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_appStateKey);
      if (jsonString == null) return null;

      final Map<String, dynamic> json = jsonDecode(jsonString);
      return AppState.fromJson(json);
    } catch (e) {
      if (kDebugMode) print('Error loading app state: $e');
      return null;
    }
  }

  /// Save app state to persistence
  Future<void> saveAppState(AppState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString(_appStateKey, jsonString);
    } catch (e) {
      if (kDebugMode) print('Error saving app state: $e');
    }
  }

  /// Load all states at once
  Future<Map<String, dynamic>> loadAllStates() async {
    final keyboard = await loadKeyboardState();
    final preferences = await loadPreferencesState();
    final appState = await loadAppState();

    return {
      'keyboard': keyboard,
      'preferences': preferences,
      'appState': appState,
    };
  }

  /// Save all states at once
  Future<void> saveAllStates({
    KeyboardState? keyboard,
    PreferencesState? preferences,
    AppState? appState,
  }) async {
    final futures = <Future>[];

    if (keyboard != null) {
      futures.add(saveKeyboardState(keyboard));
    }
    if (preferences != null) {
      futures.add(savePreferencesState(preferences));
    }
    if (appState != null) {
      futures.add(saveAppState(appState));
    }

    await Future.wait(futures);
  }

  /// Load states from persistence and update providers
  Future<void> loadStatesIntoProviders(WidgetRef ref) async {
    final states = await loadAllStates();

    if (states['keyboard'] != null) {
      ref
          .read(keyboardNotifierProvider.notifier)
          .updateKeyboardState(states['keyboard']!);
    }

    if (states['preferences'] != null) {
      ref
          .read(preferencesNotifierProvider.notifier)
          .updatePreferencesState(states['preferences']!);
    }

    if (states['appState'] != null) {
      ref
          .read(appStateNotifierProvider.notifier)
          .updateAppState(states['appState']!);
    }
  }
}
