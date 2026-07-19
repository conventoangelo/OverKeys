import 'keyboard_layouts.dart';

class UserConfig {
  String? defaultUserLayout;
  String? altLayout;
  String? customFont;
  List<KeyboardLayout>? userLayouts;
  Map<String, String>? customShiftMappings;
  String? kanataHost;
  int? kanataPort;
  Map<String, dynamic>? customKeys;
  Map<String, dynamic>? customAliases;
  List<String>? ignoredKeys;

  UserConfig({
    this.defaultUserLayout,
    this.altLayout,
    this.customFont,
    this.userLayouts,
    this.customShiftMappings,
    this.kanataHost,
    this.kanataPort,
    this.customKeys,
    this.customAliases,
    this.ignoredKeys,
  });

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    List<KeyboardLayout> userLayouts = [];
    if (json['userLayouts'] != null) {
      for (var userLayout in json['userLayouts']) {
        final parsedRows = <List<String>>[];
        final keySpecs = <List<KeyboardKeySpec?>>[];

        final rawRows = userLayout['keys'] as List<dynamic>;
        for (int rowIndex = 0; rowIndex < rawRows.length; rowIndex++) {
          final rawRow = rawRows[rowIndex] as List<dynamic>;
          final parsedRow = <String>[];
          final parsedSpecs = <KeyboardKeySpec?>[];

          for (int keyIndex = 0; keyIndex < rawRow.length; keyIndex++) {
            final rawKey = rawRow[keyIndex];

            if (rawKey is String) {
              parsedRow.add(rawKey);
              parsedSpecs.add(null);
              continue;
            }

            if (rawKey is Map) {
              final topLabel = rawKey['h'] as String?;
              final trackedKey =
                  (rawKey['t'] as String?) ?? topLabel ?? '';
              final type = rawKey['type'] as String?;

              parsedRow.add(trackedKey);
              parsedSpecs.add(
                KeyboardKeySpec(
                  trackedKey: trackedKey,
                  topLabel: topLabel,
                  type: type,
                ),
              );
              continue;
            }

            final fallbackKey = rawKey?.toString() ?? '';
            parsedRow.add(fallbackKey);
            parsedSpecs.add(null);
          }

          parsedRows.add(parsedRow);
          keySpecs.add(parsedSpecs);
        }

        userLayouts.add(KeyboardLayout(
          name: userLayout['name'],
          keys: parsedRows,
          keySpecs: keySpecs,
          trigger: userLayout['trigger'],
          type: userLayout['type'],
          foreign: userLayout['foreign'],
          wide: userLayout['wide'],
        ));
      }
    }

    Map<String, String> customShiftMappings = {};
    if (json['customShiftMappings'] != null) {
      customShiftMappings =
          Map<String, String>.from(json['customShiftMappings']);
    }

    Map<String, dynamic>? customKeys;
    if (json['customKeys'] != null) {
      customKeys = Map<String, dynamic>.from(json['customKeys']);
    }

    Map<String, dynamic>? customAliases;
    if (json['customAliases'] != null) {
      customAliases = Map<String, dynamic>.from(json['customAliases']);
    }

    List<String>? ignoredKeys;
    if (json['ignoredKeys'] != null) {
      ignoredKeys = List<String>.from(json['ignoredKeys']);
    }

    return UserConfig(
      defaultUserLayout: json['defaultUserLayout'],
      altLayout: json['altLayout'],
      customFont: json['customFont'],
      userLayouts: userLayouts,
      customShiftMappings: customShiftMappings,
      kanataHost: json['kanataHost'],
      kanataPort: json['kanataPort'] != null ? json['kanataPort'] as int : null,
      customKeys: customKeys,
      customAliases: customAliases,
      ignoredKeys: ignoredKeys,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> userLayoutsJson = userLayouts != null
        ? userLayouts!
            .map((userLayout) => {
                  'name': userLayout.name,
                  'keys': userLayout.keys.asMap().entries.map((rowEntry) {
                    return rowEntry.value.asMap().entries.map((keyEntry) {
                      final keySpec = userLayout.keySpecAt(
                        rowEntry.key,
                        keyEntry.key,
                      );

                      if (keySpec == null) {
                        return keyEntry.value;
                      }

                      return {
                        if (keySpec.topLabel != null) 'h': keySpec.topLabel,
                        't': keySpec.trackedKey,
                        if (keySpec.type != null) 'type': keySpec.type,
                      };
                    }).toList();
                  }).toList(),
                  if (userLayout.trigger != null) 'trigger': userLayout.trigger,
                  if (userLayout.type != null) 'type': userLayout.type,
                  if (userLayout.foreign != null) 'foreign': userLayout.foreign,
                  if (userLayout.wide != null) 'wide': userLayout.wide,
                })
            .toList()
        : [];

    return {
      if (defaultUserLayout != null) 'defaultUserLayout': defaultUserLayout,
      if (altLayout != null) 'altLayout': altLayout,
      if (customFont != null) 'customFont': customFont,
      if (userLayoutsJson.isNotEmpty) 'userLayouts': userLayoutsJson,
      if (customShiftMappings != null && customShiftMappings!.isNotEmpty)
        'customShiftMappings': customShiftMappings,
      if (kanataHost != null) 'kanataHost': kanataHost,
      if (kanataPort != null) 'kanataPort': kanataPort,
      if (customKeys != null && customKeys!.isNotEmpty)
        'customKeys': customKeys,
      if (customAliases != null && customAliases!.isNotEmpty)
        'customAliases': customAliases,
      if (ignoredKeys != null && ignoredKeys!.isNotEmpty)
        'ignoredKeys': ignoredKeys,
    };
  }
}
