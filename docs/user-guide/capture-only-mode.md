# Only Visible in Recordings

This option hides the OverKeys keyboard on your own screen while recording and clipping software can still capture it. Viewers of your stream or clips see your keyboard, but your screen stays clean.

## How to Enable

1. Open OverKeys
2. Right-click the OverKeys icon in the system tray
3. Select **Preferences**
4. Go to the **General** tab
5. Toggle the **Only visible in recordings** option

The setting is saved with your other preferences and applied automatically when OverKeys starts. It is off by default.

## Using it with OBS

1. Start OverKeys and leave **Only visible in recordings** switched off for now.
2. In OBS, add a new source: **Window Capture**.
3. Select the window `[OverKeys.exe]: OverKeys`.
4. Set **Capture Method** to **Windows 10 (1903 and up)**.
5. Disable **Capture Cursor**. If available, enable **Allow Transparency**.
6. Place the source above your game or display source and position it where the keyboard should appear.
7. Switch **Only visible in recordings** on in OverKeys. The keyboard disappears from your screen but stays in the OBS preview and your recording.

Other clipping software works the same way as long as it can record a single window using the Windows Graphics Capture method.

## How It Works

When enabled, the main OverKeys window is cloaked through the Windows Desktop Window Manager (`DwmSetWindowAttribute` with `DWMWA_CLOAK`). A cloaked window is not drawn on the physical screen, but Windows keeps composing it, so tools that capture the window itself still receive its content.

## Implementation Notes

- Display Capture and Game Capture only record what is on screen, so they do not show the cloaked window. Add OverKeys as its own Window Capture source instead.
- Add the window as a source before enabling the option, because hidden windows often do not appear in the window list of capture tools.
- Behavior depends on the capture software and Windows version. Windows 10 (1903) or newer is required for the capture method above.
