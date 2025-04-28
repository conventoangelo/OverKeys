# 6-Column Layouts

The 6-column layout feature in OverKeys allows you to visualize 6-column split matrix keyboard layouts.

## Overview

6-column layouts are a specialized type of [custom layout](custom-layouts.md) that limits the keyboard to just 6 columns per hand. These layouts must be created using the custom layout feature and cannot/should not be used with the default built-in layouts.

![Screenshot 2025-04-26 105446](https://github.com/user-attachments/assets/ec4f677b-699a-4ce4-ac62-4a668d8dade2)
![Screenshot 2025-04-26 105349](https://github.com/user-attachments/assets/ccfad8e4-84cc-447d-9549-ae5332b5f113)

## Setup Instructions

### Turning the setting on

1. Open OverKeys
2. Right-click the OverKeys icon in the system tray
3. Select **Preferences**
4. Go to the **General** tab
5. Toggle the **Enable advanced settings** option
6. Toggle the **Use 6 column layout** option

### Using Configuration File

1. Right-click the OverKeys tray icon
2. Select **Preferences**
3. Go to the **General** tab
4. Click **Open Config**
5. In the JSON file, edit the `userLayouts` array and set the `defaultUserLayout` field:

    ```json
    {
        // other settings...
        "userLayouts": [
            //other user layouts...
            {
                "name": "My6Col",
                "keys": [
                    // Mandatory top row but can be hidden with show top row setting
                    ["ESC", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "BSPC"],
                    ["TAB", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "DEL"],
                    ["CAPS", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "ENT"],
                    ["LSFT", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "RSFT"],
                    ["LCTL", "WIN", "LALT", "SPC", "RALT", "RCTL"]
                ]
            }
        ],
        "defaultUserLayout": "My6Col"
    }
    ```

6. Save the file
7. Toggle the **Use user layouts** option off then on again to apply change

## Implementation Notes

- Each row must contain exactly 12 keys for proper display (except for the bottom row and the top row when hidden via settings)
- The bottom row will automatically be split into two sections (one for each half of the keyboard), regardless of how many keys are defined

For more details on working with custom layouts, see [Custom Layouts](custom-layouts.md).
