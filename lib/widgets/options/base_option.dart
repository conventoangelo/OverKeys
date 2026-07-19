import 'dart:io';

import 'package:flutter/material.dart';

class OptionContainer extends StatelessWidget {
  final Widget child;

  const OptionContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final container = Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withAlpha(128)),
      ),
      child: child,
    );

    // Disable splash effects during widget tests to avoid engine shader
    // runtime issues (ink_sparkle.frag mismatches). Only override in test
    // environment so production behavior isn't changed.
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return Theme(
        data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
        child: container,
      );
    }

    return container;
  }
}
