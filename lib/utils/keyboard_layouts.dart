class KeyboardLayout {
  final String name;
  final List<List<String>> keys;

  const KeyboardLayout({required this.name, required this.keys});
}

const qwerty = KeyboardLayout(
  name: 'QWERTY',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', "'"],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/'],
    [' '],
  ],
);

const colemak = KeyboardLayout(
  name: 'Colemak',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['Q', 'W', 'F', 'P', 'G', 'J', 'L', 'U', 'Y', ';', '[', ']'],
    ['A', 'R', 'S', 'T', 'D', 'H', 'N', 'E', 'I', 'O', "'"],
    ['Z', 'X', 'C', 'V', 'B', 'K', 'M', ',', '.', '/'],
    [' '],
  ],
);

const dvorak = KeyboardLayout(
  name: 'Dvorak',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['\'', ',', '.', 'P', 'Y', 'F', 'G', 'C', 'R', 'L', '/', '='],
    ['A', 'O', 'E', 'U', 'I', 'D', 'H', 'T', 'N', 'S', '-'],
    [';', 'Q', 'J', 'K', 'X', 'B', 'M', 'W', 'V', 'Z'],
    [' '],
  ],
);

const colemakdh = KeyboardLayout(
  name: 'Colemak-DH',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['Q', 'W', 'F', 'P', 'B', 'J', 'L', 'U', 'Y', ';', '[', ']'],
    ['A', 'R', 'S', 'T', 'G', 'M', 'N', 'E', 'I', 'O', "'"],
    ['X', 'C', 'D', 'V', 'Z', 'K', 'H', ',', '.', '/'],
    [' '],
  ],
);

const colemakdhMatrix = KeyboardLayout(
  name: 'Colemak-DH Matrix',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['Q', 'W', 'F', 'P', 'B', 'J', 'L', 'U', 'Y', ';', '[', ']'],
    ['A', 'R', 'S', 'T', 'G', 'M', 'N', 'E', 'I', 'O', "'"],
    ['Z', 'X', 'C', 'D', 'V', 'K', 'H', ',', '.', '/'],
    [' '],
  ],
);

const canary = KeyboardLayout(
  name: 'Canary',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ["W", "L", "Y", "P", "K", "Z", "X", "O", "U", ";", "[", "]"],
    ["C", "R", "S", "T", "B", "F", "N", "E", "I", "A", "'"],
    ["J", "V", "D", "G", "Q", "M", "H", "/", ",", "."],
    [" "],
  ],
);

const canaryMatrix = KeyboardLayout(
  name: 'Canary Matrix',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ["W", "L", "Y", "P", "B", "Z", "F", "O", "U", "'", "[", "]"],
    ["C", "R", "S", "T", "G", "M", "N", "E", "I", "A", ";"],
    ["Q", "J", "V", "D", "K", "X", "H", "/", ",", "."],
    [" "],
  ],
);

const canaria = KeyboardLayout(
  name: 'Canaria',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ["W", "L", "Y", "P", "K", "Z", "J", "O", "U", ";", "[", "]"],
    ["C", "R", "S", "T", "B", "F", "N", "E", "I", "A", "'"],
    ["X", "V", "D", "G", "Q", "M", "H", "/", ",", "."],
    [" "],
  ],
);

const workman = KeyboardLayout(
  name: 'Workman',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['Q', 'D', 'R', 'W', 'B', 'J', 'F', 'U', 'P', ';', '[', ']'],
    ['A', 'S', 'H', 'T', 'G', 'Y', 'N', 'E', 'O', 'I', "'"],
    ['Z', 'X', 'M', 'C', 'V', 'K', 'L', ',', '.', '/'],
    [' '],
  ],
);

const nerps = KeyboardLayout(
  name: 'NERPS',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['X', 'L', 'D', 'P', 'V', 'Z', 'K', 'O', 'U', ';', '[', ']'],
    ['N', 'R', 'T', 'S', 'G', 'Y', 'H', 'E', 'I', 'A', "/"],
    ['J', 'M', 'C', 'W', 'Q', 'B', 'F', "'", ',', '.'],
    [' '],
  ],
);

const norman = KeyboardLayout(
  name: 'Norman',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['Q', 'W', 'D', 'F', 'K', 'J', 'U', 'R', 'L', ';', '[', ']'],
    ['A', 'S', 'E', 'T', 'G', 'Y', 'N', 'I', 'O', 'H', "'"],
    ['Z', 'X', 'C', 'V', 'B', 'P', 'M', ',', '.', '/'],
    [' '],
  ],
);

const halmak = KeyboardLayout(
  name: 'Halmak',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['W', 'L', 'R', 'B', 'Z', ';', 'Q', 'U', 'D', 'J', '[', ']'],
    ['S', 'H', 'N', 'T', ',', '.', 'A', 'E', 'O', 'I', "'"],
    ['F', 'M', 'V', 'C', '/', 'G', 'P', 'X', 'K', 'Y'],
    [' '],
  ],
);

const engram = KeyboardLayout(
  name: 'Engram',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['B', 'Y', 'O', 'U', "'", '"', 'L', 'D', 'W', 'V', 'Z', '#'],
    ['C', 'I', 'E', 'A', ',', '.', 'H', 'T', 'S', 'N', 'Q'],
    ['G', 'X', 'J', 'K', '-', '?', 'R', 'M', 'F', 'P'],
    [' '],
  ],
);

const graphite = KeyboardLayout(
  name: 'Graphite',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['B', 'L', 'D', 'W', 'Z', "'", 'F', 'O', 'U', 'J', ';', '='],
    ['N', 'R', 'T', 'S', 'G', 'Y', 'H', 'A', 'E', 'I', ','],
    ['Q', 'X', 'M', 'C', 'V', 'K', 'P', '.', '-', '/'],
    [' '],
  ],
);

const gallium = KeyboardLayout(
  name: 'Gallium',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['B', 'L', 'D', 'C', 'V', 'J', 'Y', 'O', 'U', ',', '[', ']'],
    ['N', 'R', 'T', 'S', 'G', 'P', 'H', 'A', 'E', 'I', '/'],
    ['X', 'Q', 'M', 'W', 'Z', 'K', "F", "'", ';', '.'],
    [' '],
  ],
);

const galliumV2 = KeyboardLayout(
  name: 'Gallium V2',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['B', 'L', 'D', 'C', 'V', 'J', 'F', 'O', 'U', ',', '[', ']'],
    ['N', 'R', 'T', 'S', 'G', 'Y', 'H', 'A', 'E', 'I', '/'],
    ['X', 'Q', 'M', 'W', 'Z', 'K', 'P', "'", ';', '.'],
    [' '],
  ],
);

const sturdy = KeyboardLayout(
  name: 'Sturdy',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['V', 'M', 'L', 'C', 'P', "X", 'F', 'O', 'U', 'J', '[', ']'],
    ['S', 'T', 'R', 'D', 'Y', '.', 'N', 'A', 'E', 'I', '/'],
    ['Z', 'K', 'Q', 'G', 'W', 'B', 'H', "'", ';', ','],
    [' '],
  ],
);

const sturdyAngle = KeyboardLayout(
  name: 'Sturdy Angle',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['V', 'M', 'L', 'C', 'P', "X", 'F', 'O', 'U', 'J', '[', ']'],
    ['S', 'T', 'R', 'D', 'Y', '.', 'N', 'A', 'E', 'I', '/'],
    ['K', 'Q', 'G', 'W', 'Z', 'B', 'H', "'", ';', ','],
    [' '],
  ],
);

const handsDown = KeyboardLayout(name: 'Hands Down', keys: [
  ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
  ['Q', 'C', 'H', 'P', 'V', 'K', 'Y', 'O', 'J', '/', '[', ']'],
  ['R', 'S', 'N', 'T', 'G', 'W', 'U', 'E', 'I', 'A', ';'],
  ['X', 'M', 'L', 'D', 'B', 'Z', 'F', "'", ',', '.'],
  [' '],
]);

const focal = KeyboardLayout(
  name: 'Focal',
  keys: [
    ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
    ['V', 'L', 'H', 'G', 'K', 'Q', 'F', 'O', 'U', 'J', '[', ']'],
    ['S', 'R', 'N', 'T', 'B', 'Y', 'C', 'A', 'E', 'I', '/'],
    ['Z', 'X', 'M', 'D', 'P', "'", 'W', '.', ';', ','],
    [' '],
  ],
);

final List<KeyboardLayout> availableLayouts = [
  qwerty,
  colemak,
  dvorak,
  canaria,
  canary,
  canaryMatrix,
  colemakdh,
  colemakdhMatrix,
  engram,
  focal,
  gallium,
  galliumV2,
  graphite,
  halmak,
  handsDown,
  nerps,
  norman,
  sturdy,
  sturdyAngle,
  workman,
];
