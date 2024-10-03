class MatrixLayout {
  final String name;
  final List<List<String>> keys;

  const MatrixLayout({required this.name, required this.keys});
}

const matrixQwerty = MatrixLayout(
  name: 'QWERTY',
  keys: [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', "'"],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/'],
    [' '],
  ],
);

const matrixCanaria = MatrixLayout(
  name: 'Canaria',
  keys: [
    ["W", "L", "Y", "P", "B", "F", "J", "O", "U", "'", "[", "]"],
    ["C", "R", "S", "T", "G", "M", "N", "E", "I", "A", ";"],
    ["Q", "Z", "V", "D", "K", "X", "H", "/", ",", "."],
    [" "],
  ],
);

final List<MatrixLayout> availableMatrixLayout = [
  matrixQwerty,
  matrixCanaria,
];