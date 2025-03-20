import '../utils/keyboard_layouts.dart';

class UserConfig {
  String kanataHost;
  int kanataPort;
  List<KeyboardLayout> userLayouts;
  String defaultUserLayout;

  UserConfig({
    this.kanataHost = '127.0.0.1',
    this.kanataPort = 4039,
    this.userLayouts = const [
      KeyboardLayout(
        name: "Extend",
        keys: [
          ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
          ["UNDO", "CUT", "COPY", "PASTE", "FIND", "DEV", "⇤", "↑", "⇥", "", "", ""],
          ["1", "2", "3", "4", "5", "⤒", "←", "↓", "→", "⤓", ""],
          ["6", "7", "8", "9", "0", "", "", "", "", ""],
          [" "],
        ],
      ),
      KeyboardLayout(
        name: "Symbol",
        keys: [
          ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
          ["'", "<", ">", ":", "@", "~", "\"", "{", "}", "%", "[", "]"],
          ["!", "-", "+", "=", "`", "|", ".", "(", ")", "?", "'"],
          ["^", "/", "*", "_", "\\", "&", "\$", "[", "]", "#"],
          [" "],
        ],
      ),
    ],
    this.defaultUserLayout = 'Symbol',
  });

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    List<KeyboardLayout> layers = [];
    if (json['userLayouts'] != null) {
      for (var layerJson in json['userLayouts']) {
        layers.add(KeyboardLayout(
          name: layerJson['name'],
          keys: List<List<String>>.from(
            layerJson['keys'].map((row) => List<String>.from(row)),
          ),
        ));
      }
    }

    return UserConfig(
      kanataHost: json['kanataHost'] ?? '127.0.0.1',
      kanataPort: json['kanataPort'] ?? 4039,
      userLayouts: layers,
      defaultUserLayout: json['defaultUserLayout'] ?? 'QWERTY',
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> layersJson = userLayouts
        .map((layer) => {
              'name': layer.name,
              'keys': layer.keys,
            })
        .toList();

    return {
      'kanataHost': kanataHost,
      'kanataPort': kanataPort,
      'userLayouts': layersJson,
      'defaultUserLayout': defaultUserLayout,
    };
  }
}
