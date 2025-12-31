# Testing Documentation

## Overview

This document describes the testing setup for the OverKeys application. The test suite ensures code quality, detects breaking changes early, and provides confidence when refactoring.

## Test Structure

```text
test/
├── models/               # Unit tests for data models
│   ├── keyboard_layouts_test.dart
│   ├── mappings_test.dart
│   └── user_config_test.dart
├── providers/            # Tests for state providers
│   ├── app_state_provider_test.dart
│   ├── keyboard_provider_test.dart
│   └── preferences_provider_test.dart
├── services/             # Tests for service classes
│   ├── config_service_test.dart
│   ├── kanata_service_test.dart
│   ├── state_service_test.dart
│   └── startup_service_test.dart
├── utils/                # Tests for utility functions
│   └── key_code_test.dart
├── widgets/              # Widget tests
│   ├── color_option_test.dart
│   ├── dropdown_option_test.dart
│   ├── slider_option_test.dart
│   └── toggle_option_test.dart
└── helpers/              # Test helpers and utilities
    └── test_helpers.dart
```

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/models/user_config_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

View coverage report (requires `lcov`):

```bash
genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html  # Windows
```

### Run Tests in Watch Mode

```bash
flutter test --watch
```

## Test Categories

### 1. Model Tests (`test/models/`)

**Purpose**: Validate data structures, JSON serialization/deserialization, and data integrity.

**Coverage**:

- `user_config_test.dart` (8 tests): UserConfig JSON parsing, round-trip serialization
- `keyboard_layouts_test.dart` (15 tests): Layout structure validation, built-in layouts integrity
- `mappings_test.dart` (13 tests): Key symbol mappings, modifier key mappings

**Key Test Patterns**:

```dart
// JSON round-trip test
test('serialization and deserialization are symmetric', () {
  final original = UserConfig(/* ... */);
  final json = original.toJson();
  final roundTrip = UserConfig.fromJson(json);

  expect(roundTrip.property, original.property);
});
```

### 2. Utility Tests (`test/utils/`)

**Purpose**: Test pure functions and utilities, especially platform-specific key code mapping logic.

**Coverage**:

- `key_code_test.dart` (30 tests): Windows virtual key code mappings, shift key variations
- `font_options_test.dart` (12 tests): Available font families validation
- `theme_manager_test.dart` (11 tests): Light/dark color schemes

**Key Test Patterns**:

```dart
// Key mapping test
test('maps letter keys correctly', () {
  expect(defaultKeyCodeMap[VK_A], 'A');
  expect(defaultKeyCodeMap[VK_Z], 'Z');
});
```

### 3. Provider Tests (`test/providers/`)

**Purpose**: Test state management logic, state transitions, and copyWith operations.

**Coverage**:

- `app_state_provider_test.dart` (15 tests): AppState class, copyWith logic, JSON serialization
- `keyboard_provider_test.dart` (22 tests): KeyboardState class, layout management, colors, animations
- `preferences_provider_test.dart` (26 tests): PreferencesState class, user preferences, feature toggles

**Key Test Patterns**:

```dart
// State transition test
test('can toggle window visibility', () {
  var state = AppState(isWindowVisible: true);
  state = state.copyWith(isWindowVisible: false);

  expect(state.isWindowVisible, false);
});
```

## Testing Dependencies

Required packages (in `pubspec.yaml`):

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4 # For mocking dependencies
  fake_async: ^1.3.1 # For testing async/timer code
```

## Best Practices

### 1. Test Naming

- Use descriptive test names that explain the behavior being tested
- Group related tests using `group()`
- Start test descriptions with lowercase

```dart
group('UserConfig', () {
  group('fromJson', () {
    test('creates UserConfig from minimal JSON', () {
      // Test implementation
    });
  });
});
```

### 2. Arrange-Act-Assert Pattern

```dart
test('description', () {
  // Arrange - Set up test data
  final config = UserConfig(/* ... */);

  // Act - Perform the operation
  final json = config.toJson();

  // Assert - Verify the result
  expect(json['property'], expectedValue);
});
```

### 3. Test Isolation

- Each test should be independent
- Use `setUp()` and `tearDown()` for common initialization
- Reset global state between tests

```dart
setUp(() {
  // Reset state before each test
  activeKeyCodeShiftMap = Map.from(defaultKeyCodeShiftMap);
});
```

### 4. Edge Cases

Always test:

- Empty/null inputs
- Boundary values
- Default values
- Error conditions

## Current Test Coverage

| Category  | Files  | Tests   | Notes                                        |
| --------- | ------ | ------- | -------------------------------------------- |
| Models    | 3      | 36      | Full coverage of data models                 |
| Utils     | 3      | 53      | Key codes, fonts, and themes                 |
| Providers | 3      | 63      | All three state providers covered            |
| Services  | 4      | 67      | State, config, Kanata, startup               |
| Widgets   | 6      | 57      | Options widgets and overlays                 |
| **Total** | **19** | **276** | Comprehensive coverage of core functionality |

### 4. Service Tests (`test/services/`)

**Purpose**: Test service layer logic, I/O operations, and message parsing.

**Coverage**:

- `config_service_test.dart` (22 tests): Configuration file I/O and caching
- `kanata_service_test.dart` (28 tests): Kanata message parsing and layout matching
- `startup_service_test.dart` (3 tests): Startup service instantiation
- `state_service_test.dart` (14 tests): Application state management, state transitions, and persistence/caching behavior

**Key Test Patterns**:

```dart
// Service method test
test('loads config from file', () async {
  final service = ConfigService();
  final config = await service.loadConfig(path);

  expect(config.defaultUserLayout, isNotNull);
});
```

### 5. Widget Tests (`test/widgets/`)

**Purpose**: Test UI components, user interactions, and visual rendering.

**Coverage**:

- `toggle_option_test.dart` (3 tests): ToggleOption widget, switch interactions
- `slider_option_test.dart` (8 tests): SliderOption widget, value formatting
- `dropdown_option_test.dart` (10 tests): DropdownOption widget, menu interaction
- `color_option_test.dart` (10 tests): ColorOption widget, color picker dialog
- `hotkey_option_test.dart` (13 tests): HotKeyOption widget, change button
- `status_overlay_test.dart` (13 tests): StatusOverlay widget, animations

**Key Test Patterns**:

```dart
// Widget interaction test
testWidgets('widget updates on user interaction', (tester) async {
  await tester.pumpWidget(TestWidget());
  await tester.tap(find.byType(Switch));
  await tester.pump();

  expect(find.text('Updated'), findsOneWidget);
});
```

### Additional Services

- [ ] `visibility_service_test.dart` - Window visibility logic
- [ ] `window_service_test.dart` - Window sizing and positioning
- [ ] `auto_hide_manager_test.dart` - Auto-hide timer logic
- [ ] `hotkey_service_test.dart` - Global hotkey handling
- [ ] `key_event_service_test.dart` - Event processing

### Additional Widget Tests

- [ ] Dialog widgets tests
- [ ] Tab widgets tests
- [ ] Keyboard screen tests

### Integration Tests

- [ ] Layout switching workflow
- [ ] Auto-hide with key events
- [ ] Preferences persistence workflow

## Future Testing Roadmap

### Phase 1: Core Services (Next Priority)

- [ ] `config_service_test.dart` - File I/O and caching
- [ ] `state_service_test.dart` - Persistence logic
- [ ] `kanata_service_test.dart` - TCP message parsing
- [ ] `key_event_service_test.dart` - Event processing

### Phase 2: More Widget Tests

- [ ] Option widgets tests
- [ ] Keyboard screen tests
- [ ] Tab widgets tests

### Phase 3: Integration Tests

- [ ] Layout switching workflow
- [ ] Auto-hide with key events
- [ ] Preferences persistence

## Continuous Integration

Tests run automatically on:

- Every push to any branch
- Every pull request
- Before merging to main

See `.github/workflows/test.yml` for CI configuration.

## Troubleshooting

### Tests Fail Locally But Pass in CI

- Ensure you have the latest dependencies: `flutter pub get`
- Check Flutter version matches CI (see `.github/workflows/test.yml`)
- Clean build: `flutter clean && flutter pub get`

### Platform-Specific Tests

Some tests use Windows-only packages (win32, hotkey_manager). These are skipped on non-Windows platforms automatically.

### Slow Tests

- Use `flutter test --plain-name "specific test"` to run individual tests
- Consider mocking expensive operations (file I/O, network calls)

## Contributing

When adding new features:

1. Write tests first (TDD approach) or alongside your implementation
2. Ensure all existing tests still pass
3. Aim for >80% coverage on new code
4. Add integration tests for critical workflows

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Riverpod Testing](https://riverpod.dev/docs/essentials/testing)
