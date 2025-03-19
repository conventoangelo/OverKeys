class SymbolMappings {
  static const Map<String, String> keyMappings = {
    '◄': 'Left',
    '►': 'Right',
    '▲': 'Up',
    '▼': 'Down',
  };
  static String getKeyForSymbol(String symbol) {
    return keyMappings[symbol] ?? symbol;
  }
}
