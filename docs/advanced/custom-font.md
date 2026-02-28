# Custom Font

The custom font feature in OverKeys allows you to use your own font for the keyboard display. This is particularly useful for users who need:

- Better readability
- Specific fonts for language support
- Custom font preferences

## Overview

When enabled, OverKeys will use the font specified in your configuration file for displaying keyboard keys. The font must be installed on your system for this feature to work correctly.

## Setup Instructions

### Turning the setting on

1. Open OverKeys
2. Right-click the OverKeys icon in the system tray
3. Select **Preferences**
4. Go to the **General** tab
5. Toggle the **Enable advanced settings** option
6. Toggle the **Use custom font** option

### Using Configuration File

1. Right-click the OverKeys tray icon
2. Select **Preferences**
3. Go to the **General** tab
4. Click **Open Config**
5. In the JSON file, set the `customFont` field to your preferred font name:

    ```json
    {
        "customFont": "Lexend"
    }
    ```

6. Save the file
7. Right-click the tray icon and click **Reload config** to apply changes

## Implementation Notes

- Custom fonts must be installed on your system
- Font names are case-sensitive
- If the specified font is not found, OverKeys will fall back to the default app font, i.e., Geist Mono
- Custom fonts is applied to all layout types including alternative layouts and layers
- Some fonts may not display certain special characters correctly

## Troubleshooting

- If your custom font isn't displaying correctly, verify the font name exactly matches the installed font name
- Make sure the font is properly installed on your system
