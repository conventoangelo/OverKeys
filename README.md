<a id="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <img src="assets/images/OK.png" alt="OverKeys Logo" width="160" height="160">
  <h1 align="center">OverKeys</h1>
  <p align="center">
    A customizable, open-source on-screen keyboard for alternative layouts!
    <br />
    <a href="https://github.com/conventoangelo/OverKeys"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/conventoangelo/OverKeys/releases">Download Release</a>
    ·
    <a href="https://github.com/conventoangelo/OverKeys/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/conventoangelo/OverKeys/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#features">Features</a></li>
    <li><a href="#getting-started">Getting Started</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About The Project

![OverKeys Demo](https://github.com/conventoangelo/OverKeys/blob/main/assets/images/OverKeysDemo.gif)

OverKeys is an open-source on-screen keyboard designed for users to practice alternative keyboard layouts, such as **Canary**, **Colemak**, **Dvorak**, and many more. Built in [**Flutter**](https://flutter.dev/), it allows full customizability, making it perfect for users learning or working with non-traditional layouts.

This project was initially developed to help with system-wide practice of the **Canary layout**, but has since evolved to support multiple layouts and customization options.

### Samples

<table>
  <tr>
    <td>
      <img src="assets/images/aurora1.png" alt="aurora dark background">
      <p align="center">Aurora (On Dark Background)</p>
    </td>
    <td>
      <img src="assets/images/aurora2.png" alt="aurora light background">
      <p align="center">Aurora (On Light Background)</p>
    </td>
  </tr>
  <tr>
    <td>
      <img src="assets/images/eyco1.png" alt="custom dark background">
      <p align="center">Custom (On Dark Background)</p>
    </td>
    <td>
      <img src="assets/images/eyco2.png" alt="custom light background">
      <p align="center">Custom (On Light Background)</p>
    </td>
  </tr>
  <tr>
    <td>
      <img src="assets/images/catpuccin.png" alt="catpuccin">
      <p align="center">Catppuccin</p>
    </td>
    <td>
      <img src="assets/images/redsamurai.png" alt="split matrix">
      <p align="center">Red Samurai</p>
    </td>
    </tr>
    <tr>
    <td>
      <img src="assets/images/splitmatrix.png" alt="red samurai">
      <p align="center">Split Matrix Style</p>
    </td>
    <td>
      <img src="assets/images/matrix.png" alt="matrix">
      <p align="center">Matrix Style</p>
    </td>
  </tr>
</table>
<sub>Note: The themes are not provided by default and were instead manually configured. Colors were based on the MonkeyType themes of the same name.</sub>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Features

- **Multi-layout support**: The following layouts are currently supported:
  - QWERTY
  - Colemak
  - Dvorak
  - Canaria
  - Canary
  - Canary Matrix
  - Colemak DH
  - Colemak DH Matrix
  - Engram
  - Gallium (Col-Stag)
  - Gallium V2 (Row-Stag)
  - Graphite
  - Halmak
  - Hands Down
  - NERPS
  - Norman
  - Sturdy
  - Sturdy Angle (Staggered)
  - Workman
- **Customizable styles**: Change colors, fonts, sizes, offsets, and key styles to fit your preference.
- **Always on top**: Keep the keyboard on top of all windows for constant access.
- **Auto-hide**: The keyboard hides automatically when not in use.
- **Keymap layouts**: Supports keymap layouts such as staggered, matrix, and split matrix.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

Follow these instructions to set up OverKeys on your local machine.

### Prerequisites

- Windows OS

### Installation

1. Download the latest [EXE installer](https://github.com/conventoangelo/OverKeys/releases).
2. Run the installer and follow the on-screen instructions.
3. Once installed, OverKeys will be available for use immediately.

### Configuration

To change the app settings, right-click the OverKeys icon in the system tray and select **Preferences**. A separate window will open, displaying the available settings.

### Loading Your Own Layout

To load your own keyboard layout, follow these steps:

1. **Install Flutter**:

   - Follow the official [Flutter installation guide](https://flutter.dev/docs/get-started/install) to set up Flutter on your machine.

2. **Make Changes to `keyboard_layout.dart`**:

   - Navigate to the `lib\utils` directory in the project.
   - Open the `keyboard_layout.dart` file.
   - Modify the file to define your custom keyboard layout.
   - Make sure to add your new custom keyboard layout to the `availableLayouts` list at the bottom of the file.

3. **Build the Project Locally**:

   - Open a terminal and navigate to the root directory of the project.
   - Run the following command to get the Flutter dependencies:

     ```sh
     flutter pub get
     ```

   - Build the project by running:

     ```sh
     flutter build windows
     ```

   - Once the build is complete, you can find the executable file in `OverKeys\build\windows\x64\runner\Release`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contributing

Contributions are what make the open-source community such an amazing place to learn and collaborate. Any contributions to **OverKeys** are greatly appreciated.

1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

Distributed under the GPL-3.0 License. See `LICENSE` file for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contact

### Angelo Convento

GitHub: [conventoangelo](https://github.com/conventoangelo)  
Email: <convento.angelo@gmail.com>

Project Link: [https://github.com/conventoangelo/OverKeys](https://github.com/conventoangelo/OverKeys)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Acknowledgments

- [win32](https://win32.pub/) - Access common Win32 APIs directly from Dart using FFI — no C required!
- [leanflutter.dev](https://leanflutter.dev/our-packages/)
  - [window_manager](https://pub.dev/packages/window_manager) - A plugin that allows Flutter desktop apps to resizing and repositioning the window.
  - [tray_manager](https://pub.dev/packages/tray_manager) - A plugin that allows Flutter desktop apps to defines system tray.
  - [launch_at_startup](https://pub.dev/packages/launch_at_startup) - A plugin that allows Flutter desktop apps to Auto launch on startup / login.
- [desktop_multi_window](https://pub.dev/packages/desktop_multi_window) - A flutter plugin that create and manager multi window in desktop.
- [flex_color_picker](https://github.com/rydmike/flex_color_picker) - A highly customizable Flutter color picker.
- [Best-README-Template](https://github.com/othneildrew/Best-README-Template) - An awesome README template to jumpstart your projects!
- Alaine - for the OverKeys logo.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
