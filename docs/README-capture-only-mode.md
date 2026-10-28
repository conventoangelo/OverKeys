# Only Visible in Recordings (Capture-Only Mode)

This option hides the OverKeys keyboard on your own screen while recording and clipping software can still capture it. Viewers of your stream or clips see your keyboard, but your screen stays clean.

## How to enable

1. Right-click the OverKeys icon in the system tray
2. Select **Preferences**
3. Go to the **General** tab
4. Toggle **Only visible in recordings**

The setting is saved with your other preferences and applied automatically when OverKeys starts. It is off by default.

## Using it with OBS

1. Start OverKeys and leave the option switched off for now.
2. In OBS, add a new source: **Window Capture**.
3. Select the window `[OverKeys.exe]: OverKeys`.
4. Set **Capture Method** from **Automatic** to **Windows 10 (1903 and up)**.
5. Disable **Capture Cursor**. If available, enable **Allow Transparency**.
6. Place the source above your game or display source and position it where the keyboard should appear.
7. Switch **Only visible in recordings** on in OverKeys. The keyboard disappears from your screen but stays in the OBS preview and your recording.

Other clipping software works the same way as long as it can record a single window using the Windows Graphics Capture method.

## How it works

When enabled, the main OverKeys window is cloaked through the Windows Desktop Window Manager (`DwmSetWindowAttribute` with `DWMWA_CLOAK`). A cloaked window is not drawn on the physical screen, but Windows keeps composing it, so tools that capture the window itself still receive its content.


## What was added in the code

- `lib/services/capture_mode_service.dart` (new): cloaks or uncloaks the main window via `user32.dll` and `dwmapi.dll`
- `lib/providers/preferences_provider.dart`: new preference `captureOnlyMode` (saved and loaded with the other settings)
- `lib/widgets/tabs/general_tab.dart`: new toggle in the General tab
- `lib/services/method_call_handler.dart`: syncs the toggle from the Preferences window to the main window and applies it
- `lib/app.dart`: applies the setting on startup
