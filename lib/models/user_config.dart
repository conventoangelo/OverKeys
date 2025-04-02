import 'keyboard_layouts.dart';

class UserConfig {
  String kanataHost;
  int kanataPort;
  List<KeyboardLayout> userLayouts;
  String defaultUserLayout;
  String altLayout;
  String customFont;

  UserConfig({
    this.defaultUserLayout = 'Symbol',
    this.altLayout = 'Arabic',
    this.customFont = 'Segoe UI',
    this.userLayouts = const [
      KeyboardLayout(
        name: "Extend",
        keys: [
          ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
          ["UNDO", "CUT", "COPY", "PASTE", "FIND", "DEV", "⇤", "↑", "⇥", "", "", ""],
          ["1", "2", "3", "4", "5", "⤒", "←", "↓", "→", "⤓", ""],
          ["6", "7", "8", "9", "0", "", "", "", "", ""],
          [" "],
        ],
      ),
      KeyboardLayout(
        name: "Symbol",
        keys: [
          ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
          ["'", "<", ">", ":", "@", "~", "\"", "{", "}", "%", "[", "]"],
          ["!", "-", "+", "=", "`", "|", ".", "(", ")", "?", "'"],
          ["^", "/", "*", "_", "\\", "&", "\$", "[", "]", "#"],
          [" "],
        ],
      ),
      KeyboardLayout(
        name: "Arabic",
        keys: [
          ["ذ", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩", "٠", "", "", ""],
          ["ض", "ص", "ث", "ق", "ف", "غ", "ع", "ه", "خ", "ح", "ج", "د"],
          ["ش", "س", "ي", "ب", "ل", "ا", "ت", "ن", "م", "ك", "ط"],
          ["ئ", "ء", "ؤ", "ر", "لا", "ى", "ة", "و", "ز", "ظ"],
          [" "],
        ],
      ),
      KeyboardLayout(
        name: "Russian",
        keys: [
          ["", "", "", "", "", "", "", "", "", "", "", "", "", ""],
          ["й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х", "ъ"],
          ["ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э"],
          ["я", "ч", "с", "м", "и", "т", "ь", "б", "ю", "ё"],
          [" "],
        ],
      ),
    ],
    this.kanataHost = '127.0.0.1',
    this.kanataPort = 4039,
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
      defaultUserLayout: json['defaultUserLayout'] ?? 'Symbol',
      altLayout: json['altLayout'] ?? 'Arabic',
      customFont: json['customFont'] ?? 'Segoe UI',
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
      'altLayout': altLayout,
      'customFont': customFont,
    };
  }
}
