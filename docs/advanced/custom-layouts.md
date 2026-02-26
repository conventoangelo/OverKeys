# Custom Layouts

The custom layout feature in OverKeys allows you to use your own keyboard layouts defined in a configuration file. This is particularly useful for users who need:

- Specialized layouts not included in the default options
- Custom symbol or function key arrangements
- Language-specific layouts
- Modified versions of standard layouts

## Setup Instructions

### Turning the setting on

1. Open OverKeys
2. Right-click the OverKeys icon in the system tray
3. Select **Preferences**
4. Go to the **Advanced** tab
5. Toggle the **Turn on advanced settings** option
6. Toggle the **Use user layouts** option

### Using Configuration File

1. Right-click the OverKeys tray icon
2. Select **Preferences**
3. Go to the **Advanced** tab
4. Click **Open Config**
5. In the JSON file, edit the `userLayouts` array and set the `defaultUserLayout` field:

   ```json
   {
   	"userLayouts": [
   		{
   			"name": "MyCustomLayout",
   			"keys": [
   				["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
   				["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]"],
   				["A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'"],
   				["Z", "X", "C", "V", "B", "N", "M", ",", ".", "/"],
   				[" "]
   			]
   		}
   	],
   	"defaultUserLayout": "MyCustomLayout"
   }
   ```

6. Save the file
7. Right-click the tray icon and click **Reload config** to apply changes

## Default User Layouts

OverKeys no longer comes with default/pre-configured layouts. Instead, you can find sample layouts in the example configuration file at [sample_config.json](../examples/sample_config.json), which includes:

- Extend (navigation and editing keys)
- Symbol (special characters and symbols)
- Arabic (Arabic language keyboard)
- Russian (Russian language keyboard)

You can copy these layouts from the sample configuration to get started with your own custom layouts.

## Creating Custom Layouts

You can create custom layouts by adding them to the `userLayouts` section in the configuration file. Each layout requires a unique name and a keys array that defines the layout structure:

```jsonc
{
	"name": "MyCustomLayout",
	"keys": [
		// Top row (required)
		["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "BSPC"],
		// Second row
		["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]"],
		// Third row
		["A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'"],
		// Fourth row
		["Z", "X", "C", "V", "B", "N", "M", ",", ".", "/"],
		// Fifth row
		[" "],
	],
	// Optional: Set to true if the layout is in a foreign language (non-English alphabet)
	"foreign": false,
}
```

You can then set this layout as your default by updating the `defaultUserLayout` field:

```json
{
	"defaultUserLayout": "MyCustomLayout"
}
```

## Customizing Tactile Marker Positions

By default, tactile (homerow) markers appear on the home row at specific positions (row 2, columns 3 and 6 - the F and J keys in QWERTY). For layouts with modifications like wide mods or non-standard key arrangements, you can override these default positions using the `tactileMarkers` property:

```jsonc
{
	"name": "Colemak-DH Wide Mod",
	"keys": [
		["`", "1", "2", "3", "4", "5", "6", "=", "7", "8", "9", "0", "-", "BSPC"],
		["Q", "W", "F", "P", "B", "[", "]", "J", "L", "U", "Y", ";"],
		["A", "R", "S", "T", "G", "'", "M", "N", "E", "I", "O"],
		["Z", "X", "C", "D", "V", "/", "K", "H", ",", "."],
		[" "],
	],
	"tactileMarkers": {
		"left": [2, 3], // Row 2, Column 3 (T key)
		"right": [2, 7], // Row 2, Column 7 (N key - shifted right for wide mod)
	},
}
```

The `tactileMarkers` property accepts:

- `left`: A two-element array `[row, column]` for the left marker position
- `right`: A two-element array `[row, column]` for the right marker position

**Note:** Row and column indices are zero-based, meaning the first row is 0, the second row is 1, etc.

If `tactileMarkers` is not specified, the default positions will be used (row 2, columns 3 and 6).

## Format Guidelines

1. **Key Names**: Use standard key symbols or their aliases as defined in the system. For key names and their aliases, see [Supported Keys](../advanced/supported-keys.md).
2. **Layout Structure**: Each row should be defined as an array of keys. At minimum, a layout must have a top row defined.
3. **Language Support**: Unicode characters are supported for international layouts. You may use `foreign: true` especially if the language is mostly non-English alphabet characters (e.g., Russian, Greek, Arabic). Otherwise, refer to the [Locales](../advanced/locales.md) documentation for better handling of locale-specific keys (e.g., German QWERTZ).
4. **Flexible Row Lengths**: Your custom layout doesn't need to follow standard row lengths. You can create layouts of any dimension. Here's an example of a compact 4×4 layout:

   ```jsonc
   {
   	"name": "Compact4x4",
   	"keys": [
   		[""], // Mandatory top row, show top row setting turned off
   		["1", "2", "3", "A"],
   		["4", "5", "6", "B"],
   		["7", "8", "9", "C"],
   		["*", "0", "#", "D"],
   	],
   }
   ```

## Row Length Guidelines

While you have flexibility in defining your layout dimensions, the following row lengths are recommended to ensure compatibility across different key styles and visual presentations:

- Top row: 14 keys (including backspace)
- Second row: 12 keys
- Third row: 11 keys
- Fourth row: 10 keys
- Bottom row: 1 key (space bar)

Following these recommendations will help ensure your custom layout displays correctly with different keymap styles in OverKeys.

## Implementation Notes

- Custom layouts are loaded when OverKeys starts or when you toggle the setting.
- If the Kanata integration is enabled, your custom layout will be used as the base layout/layer, and Kanata will control layer switching.
- Custom layouts can be used simultaneously with the alternative layout feature.
- Custom layouts with names identical to the natively supported layouts will override the native ones.

## Troubleshooting

- If your layout displays incorrectly, verify the JSON format in your configuration file.
- Ensure your layout name in `defaultUserLayout` exactly matches one of the names in your `userLayouts` array.
- If you're using symbols or special characters, make sure they're properly escaped in the JSON.
