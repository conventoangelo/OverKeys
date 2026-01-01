# Ignored Keys

The ignored keys feature allows you to specify which keys should not trigger the keyboard overlay to appear. This is useful for keys that you don't want to display on the overlay, such as Print Screen, function keys used as layer triggers, or any keys not present in your current layout.

## Use Cases

- **Screenshot keys**: Prevent the keyboard from appearing when taking screenshots with Print Screen or similar keys
- **Layer trigger keys**: Hide the keyboard when pressing function keys (F13-F24) used as layer switching triggers
- **Unmapped keys**: Prevent the overlay from showing when pressing keys not included in your current layout
- **Media keys**: Ignore volume, play/pause, or other media control keys

## Configuration

To configure ignored keys, add an `ignoredKeys` field to your configuration file with an array of key names:

```json
{
	"ignoredKeys": ["PrintScreen", "F13", "F14", "F15"]
}
```

### Key Names

Use the same key names that OverKeys recognizes for keyboard layouts. Common examples include:

- Function keys: `F1`, `F2`, ..., `F24`
- Special keys: `PrintScreen`, `Pause`, `ScrollLock`
- Navigation keys: `Home`, `End`, `PageUp`, `PageDown`, `Insert`, `Delete`
- Media keys: Check the supported keys documentation for exact names

See the [Supported Keys](./supported-keys.md) documentation for a complete list of recognized key names.

## Example Configuration

Here's a complete example showing ignored keys alongside other configuration options:

```json
{
	"defaultUserLayout": "Canary",
	"altLayout": "QWERTY",
	"ignoredKeys": ["PrintScreen", "F13", "F14", "F15", "Pause", "ScrollLock"],
	"userLayouts": [
		{
			"name": "Extend",
			"keys": [
				["ESC", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
				["UNDO", "CUT", "COPY", "PASTE", "FIND", "DEV", "⇤", "↑", "⇥", "", "", ""],
				["1", "2", "3", "4", "5", "⤒", "←", "↓", "→", "⤓", ""],
				["6", "7", "8", "9", "0", "", "", "", "", ""],
				[" "]
			],
			"trigger": "F14",
			"type": "held"
		}
	]
}
```

In this example:

- `PrintScreen` is ignored so the keyboard won't appear during screenshots
- `F13`, `F14`, and `F15` are ignored because they're used as layer triggers
- `Pause` and `ScrollLock` are ignored as they're rarely used

## How It Works

When you press a key that's in the `ignoredKeys` list:

1. The key press is still processed normally by your system
2. OverKeys updates the key press state internally (if tracking it)
3. The keyboard overlay does NOT appear
4. No auto-hide timer is triggered

This ensures that ignored keys have minimal interaction with the OverKeys overlay while still allowing your system and other applications to process them normally.

## Tips

- If you're using layer switching with function keys, add those function keys to `ignoredKeys` to prevent the overlay from appearing when switching layers
- For screenshot workflows, adding `PrintScreen` ensures a clean capture
- If you have keys on your keyboard that aren't in your active layout, add them to prevent unnecessary overlay appearances

## Editing the Configuration File

To edit your configuration file:

1. Open OverKeys Preferences
2. Navigate to the **Advanced** tab
3. Click **Open config file**
4. Add or modify the `ignoredKeys` array
5. Save the file
6. Restart OverKeys for changes to take effect
