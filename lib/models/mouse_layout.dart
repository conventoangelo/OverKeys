class MouseLayout {
  final String name;
  final List<String> buttons;
  final bool hasSideButtons;

  const MouseLayout({
    required this.name,
    required this.buttons,
    required this.hasSideButtons,
  });
}

const simpleMouse = MouseLayout(
  name: 'Simple Mouse',
  buttons: [
    'Left Button',
    'Right Button',
    'Middle Button',
  ],
  hasSideButtons: false,
);

const standardMouse = MouseLayout(
  name: 'Standard Mouse',
  buttons: [
    'Left Button',
    'Right Button',
    'Middle Button',
    'Back Button',
    'Forward Button',
  ],
  hasSideButtons: true,
);

final List<MouseLayout> availableMouseLayouts = [
  simpleMouse,
  standardMouse,
];
