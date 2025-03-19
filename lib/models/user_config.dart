import '../utils/keyboard_layouts.dart';

class UserConfig {
  String kanataHost;
  int kanataPort;
  List<KeyboardLayout> kanataLayers;
  String defaultLayer;

  UserConfig({
    this.kanataHost = '127.0.0.1',
    this.kanataPort = 4039,
    this.kanataLayers = const [
      KeyboardLayout(
        name: 'QWERTY',
        keys: [
          ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']'],
          ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', "'"],
          ['Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/'],
          [' '],
        ],
      ),
    ],
    this.defaultLayer = 'QWERTY',
  });

  factory UserConfig.fromJson(Map<String, dynamic> json) {
    // Convert the layers from JSON to KeyboardLayout objects
    List<KeyboardLayout> layers = [];
    if (json['kanataLayers'] != null) {
      for (var layerJson in json['kanataLayers']) {
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
      kanataLayers: layers,
      defaultLayer: json['defaultLayer'] ?? 'QWERTY',
    );
  }

  Map<String, dynamic> toJson() {
    // Convert KeyboardLayout objects to JSON
    List<Map<String, dynamic>> layersJson = kanataLayers
        .map((layer) => {
              'name': layer.name,
              'keys': layer.keys,
            })
        .toList();

    return {
      'kanataHost': kanataHost,
      'kanataPort': kanataPort,
      'kanataLayers': layersJson,
      'defaultLayer': defaultLayer,
    };
  }
}
