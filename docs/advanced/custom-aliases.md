# Custom Aliases

OverKeys allows you to define custom aliases for key combinations. This is useful for visualizing shortcuts or macros on your on-screen keyboard. For example, you can map `Ctrl + Z` to display as "UNDO" on your layout.

## Setup Instructions

1. Right-click the OverKeys tray icon
2. Select **Preferences**
3. Go to the **Advanced** tab
4. Toggle the **Turn on advanced settings** option
5. Click the **Open Config** button
6. In the JSON file, add or modify the `customAliases` field to match your desired aliases

   ```jsonc
   {
    "customAliases": {
     "UNDO": ["Control", "Z"],
     "PASTE": ["Control", "Shift", "V"],
     "Ability 1": ["Q"],
     "ULT": ["X"],
     "Item 1": ["Alt", "Q"]
    }
   }
   ```

7. Save the file
8. Right-click the tray icon and click **Reload config** to apply changes

## Configuration Details

### Structure

The `customAliases` field is a map where:

- The **key** is the name of the alias (e.g., "UNDO", "PASTE").
- The **value** is a list of keys that must be pressed simultaneously to trigger the alias.

### Supported Modifiers

You can use the following modifiers in your key combinations:

- `Control` (matches both Left and Right Control)
- `Shift` (matches both Left and Right Shift)
- `Alt` (matches both Left and Right Alt)
- `Win` (matches both Left and Right Windows key)

You can also specify specific sides if needed (e.g., `LControl`, `RShift`), but the generic modifiers are usually more convenient.

## Usage in Layouts

Once you have defined your aliases, you can use them as key names in your custom layouts.

```jsonc
{
    "name": "Gaming",
    "keys": [
        ["ESC", "1", "2", "3", "4", "5"],
        ["TAB", "Ability 1", "W", "E", "R", "T"],
        ["CAPS", "A", "S", "D", "F", "G"],
        ["LSFT", "Z", "X", "C", "V", "B"],
        ["CTRL", "ALT", "SPC", "Item 1", "ULT"]
    ]
}
```

In this example:

- When you press `Q`, the key labeled "Ability 1" will light up.
- When you press `Alt + Q`, the key labeled "Item 1" will light up.
- When you press `X`, the key labeled "ULT" will light up.

## Notes

- Aliases are case-sensitive. Ensure the name in `customAliases` matches the name in your layout exactly.
- If an alias shares the same key combination as a regular key (e.g., "Ability 1" is just "Q"), both keys will light up if present in the layout.
