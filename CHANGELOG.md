# Changelog

## [0.2.16](https://github.com/conventoangelo/OverKeys/compare/v0.2.15...v0.2.16) (2025-04-14)


### ✨ Features

* add drop shadow to keys ([#104](https://github.com/conventoangelo/OverKeys/issues/104)) ([7d5fc4c](https://github.com/conventoangelo/OverKeys/commit/7d5fc4c66ee4e2afd3667810f4053e5dbc59a866))


### 🐛 Bug Fixes

* change blur style to normal ([3acd87c](https://github.com/conventoangelo/OverKeys/commit/3acd87cb415e658129be343c29119724914a76d2))
* opacity hotkeys now only works when keyboard is visible ([56b2a7d](https://github.com/conventoangelo/OverKeys/commit/56b2a7db62e80b42052856f064c8905d2e80fc0b))

## [0.2.15](https://github.com/conventoangelo/OverKeys/compare/v0.2.14...v0.2.15) (2025-04-11)


### ✨ Features

* add hotkeys for increasing/decreasing opacity ([#98](https://github.com/conventoangelo/OverKeys/issues/98)) ([b5d7e65](https://github.com/conventoangelo/OverKeys/commit/b5d7e65847deeec79b3a21114f7e5096b2a4b08f))
* add hotkeys to tray menu label ([48c8bc6](https://github.com/conventoangelo/OverKeys/commit/48c8bc604875f43d5630eea0e3d1e3e6ed70acfa))
* add reload config option to tray menu ([#99](https://github.com/conventoangelo/OverKeys/issues/99)) ([48c8bc6](https://github.com/conventoangelo/OverKeys/commit/48c8bc604875f43d5630eea0e3d1e3e6ed70acfa))


### 🐛 Bug Fixes

* reload config every connect to kanata call ([48c8bc6](https://github.com/conventoangelo/OverKeys/commit/48c8bc604875f43d5630eea0e3d1e3e6ed70acfa))
* revert to correct font family after reloading config and turning custom font off ([48c8bc6](https://github.com/conventoangelo/OverKeys/commit/48c8bc604875f43d5630eea0e3d1e3e6ed70acfa))

## [0.2.14](https://github.com/conventoangelo/OverKeys/compare/v0.2.13...v0.2.14) (2025-04-08)


### ✨ Features

* add custom shift mappings in `overkeys_config.json` ([1cf6506](https://github.com/conventoangelo/OverKeys/commit/1cf6506d7758cd77edf3a0d6d1bb24ffa91a33c7))
* add ESC key tip in preferences window ([b22db49](https://github.com/conventoangelo/OverKeys/commit/b22db494cd249bb390e745e666ac7ef92e52b02c))
* add overkeys custom learn_mode picture by @MG240 ([#88](https://github.com/conventoangelo/OverKeys/issues/88)) ([ae3f554](https://github.com/conventoangelo/OverKeys/commit/ae3f554e6ef4263e35c4a63b96fcd6cc2ff7bb6f))
* add support for reactive shifted keys ([#94](https://github.com/conventoangelo/OverKeys/issues/94)) ([1cf6506](https://github.com/conventoangelo/OverKeys/commit/1cf6506d7758cd77edf3a0d6d1bb24ffa91a33c7))
* disable/enable specific hotkeys ([#95](https://github.com/conventoangelo/OverKeys/issues/95)) ([b22db49](https://github.com/conventoangelo/OverKeys/commit/b22db494cd249bb390e745e666ac7ef92e52b02c))
* restore focus to last active window on tray icon click ([6a469e6](https://github.com/conventoangelo/OverKeys/commit/6a469e6ddfe231ed1ca59243c02744c20987fe7b))
* use ESC to close preferences window ([66ad129](https://github.com/conventoangelo/OverKeys/commit/66ad129f3d0bb7fd3535da4de6a76a88ce896ddf))


### 🐛 Bug Fixes

* color picker now uses hex rgb format ([6e04243](https://github.com/conventoangelo/OverKeys/commit/6e0424390311d17603e0a05246caa91faa31fdf9))
* disabled color picker copy/paste buttons and shortcuts causing errors ([6e04243](https://github.com/conventoangelo/OverKeys/commit/6e0424390311d17603e0a05246caa91faa31fdf9))
* update color picker behavior ([#93](https://github.com/conventoangelo/OverKeys/issues/93)) ([6e04243](https://github.com/conventoangelo/OverKeys/commit/6e0424390311d17603e0a05246caa91faa31fdf9))

## [0.2.13](https://github.com/conventoangelo/OverKeys/compare/v0.2.12...v0.2.13) (2025-04-04)


### 🐛 Bug Fixes

* animate tactile markers together with key ([f2240be](https://github.com/conventoangelo/OverKeys/commit/f2240beb320a6f2168304425464293e94006e55d))
* apply learning mode color to grave key ([70060e0](https://github.com/conventoangelo/OverKeys/commit/70060e004b9a0400d454dc6aee1d5ac64bcdd0c0))

## [0.2.12](https://github.com/conventoangelo/OverKeys/compare/v0.2.11...v0.2.12) (2025-04-03)


### ✨ Features

* add hotkeys for toggling move and opening preferences ([536608d](https://github.com/conventoangelo/OverKeys/commit/536608db5f6339f2df98d266f107bd9fb76f08cf))
* add learning mode (overrides colors settings) ([#79](https://github.com/conventoangelo/OverKeys/issues/79)) ([3989ea1](https://github.com/conventoangelo/OverKeys/commit/3989ea1054e508f7701c9fe323905cec2b3fcbac))
* show initial hotkey on hotkey recorder dialog open ([536608d](https://github.com/conventoangelo/OverKeys/commit/536608db5f6339f2df98d266f107bd9fb76f08cf))


### 🐛 Bug Fixes

* advanced settings changes reflected without restarting ([#78](https://github.com/conventoangelo/OverKeys/issues/78)) ([536608d](https://github.com/conventoangelo/OverKeys/commit/536608db5f6339f2df98d266f107bd9fb76f08cf))
* correct icons for move enabled/disabled status overlays ([3989ea1](https://github.com/conventoangelo/OverKeys/commit/3989ea1054e508f7701c9fe323905cec2b3fcbac))
* only shrink keys longer than length 2 ([#77](https://github.com/conventoangelo/OverKeys/issues/77)) ([3f5dfab](https://github.com/conventoangelo/OverKeys/commit/3f5dfab5693b313f79b255f595010fb33d96075a))
* use LucideIcons for open config button ([536608d](https://github.com/conventoangelo/OverKeys/commit/536608db5f6339f2df98d266f107bd9fb76f08cf))

## [0.2.11](https://github.com/conventoangelo/OverKeys/compare/v0.2.10...v0.2.11) (2025-04-02)


### ✨ Features

* add key borders to improve key visibility ([#72](https://github.com/conventoangelo/OverKeys/issues/72)) ([6adfd6a](https://github.com/conventoangelo/OverKeys/commit/6adfd6a83c5a08db0bc901eda1fd5b471a6176b3))
* add keyboard follows mouse functionality ([#73](https://github.com/conventoangelo/OverKeys/issues/73)) ([ce6644c](https://github.com/conventoangelo/OverKeys/commit/ce6644c2b42dcef8414664b3da8bcc11d912c58b))
* add more fonts to options ([836c230](https://github.com/conventoangelo/OverKeys/commit/836c2302afdc34ea4b3dbf46b30dba95cbc98206))
* add support for custom fonts ([#71](https://github.com/conventoangelo/OverKeys/issues/71)) ([836c230](https://github.com/conventoangelo/OverKeys/commit/836c2302afdc34ea4b3dbf46b30dba95cbc98206))


### 🐛 Bug Fixes

* keyboard now remains hidden when auto-hide disabled ([0563c7c](https://github.com/conventoangelo/OverKeys/commit/0563c7c2b2132df5e9c48116f883afff2dacf00f))

## [0.2.10](https://github.com/conventoangelo/OverKeys/compare/v0.2.9...v0.2.10) (2025-04-01)


### ✨ Features

* add  status overlay for keyboard visibility ([a520b95](https://github.com/conventoangelo/OverKeys/commit/a520b95f476b556f3fa6618d252a129d3a601403))
* add animations on key press ([#66](https://github.com/conventoangelo/OverKeys/issues/66)) ([74bb7cf](https://github.com/conventoangelo/OverKeys/commit/74bb7cff5416094a16fcbb7a97ee728a0f12f6ec))
* add animations settings in preferences window ([74bb7cf](https://github.com/conventoangelo/OverKeys/commit/74bb7cff5416094a16fcbb7a97ee728a0f12f6ec))
* add status overlay for auto-hide ([a520b95](https://github.com/conventoangelo/OverKeys/commit/a520b95f476b556f3fa6618d252a129d3a601403))
* add status overlay for move ([a520b95](https://github.com/conventoangelo/OverKeys/commit/a520b95f476b556f3fa6618d252a129d3a601403))
* add status overlay for reset position ([a520b95](https://github.com/conventoangelo/OverKeys/commit/a520b95f476b556f3fa6618d252a129d3a601403))
* add status overlays for tray menu toggles and hotkeys ([#65](https://github.com/conventoangelo/OverKeys/issues/65)) ([a520b95](https://github.com/conventoangelo/OverKeys/commit/a520b95f476b556f3fa6618d252a129d3a601403))


### 🐛 Bug Fixes

* improve force hide logic to not conflict with auto-hide ([a520b95](https://github.com/conventoangelo/OverKeys/commit/a520b95f476b556f3fa6618d252a129d3a601403))

## [0.2.9](https://github.com/conventoangelo/OverKeys/compare/v0.2.8...v0.2.9) (2025-03-31)


### ✨ Features

* add lastRowSplitWidth settings for split matrix ([85ed250](https://github.com/conventoangelo/OverKeys/commit/85ed2506a04803ec99b8636adf772c4455a67418))
* add support for 6 column split keyboard layouts ([#61](https://github.com/conventoangelo/OverKeys/issues/61)) ([85ed250](https://github.com/conventoangelo/OverKeys/commit/85ed2506a04803ec99b8636adf772c4455a67418))
* add support for 6 column split keyboards ([85ed250](https://github.com/conventoangelo/OverKeys/commit/85ed2506a04803ec99b8636adf772c4455a67418))
* add support for custom keys in split matrix last row ([85ed250](https://github.com/conventoangelo/OverKeys/commit/85ed2506a04803ec99b8636adf772c4455a67418))
* improve preferences window UI ([9da0734](https://github.com/conventoangelo/OverKeys/commit/9da0734189d70b9cf8fe4ad36fb6ac2cf7bb46bf))
* improve preferences window UI ([#60](https://github.com/conventoangelo/OverKeys/issues/60)) ([9da0734](https://github.com/conventoangelo/OverKeys/commit/9da0734189d70b9cf8fe4ad36fb6ac2cf7bb46bf))
* refactor and add more tabs to preferences ([9da0734](https://github.com/conventoangelo/OverKeys/commit/9da0734189d70b9cf8fe4ad36fb6ac2cf7bb46bf))
* use lucide icons ([9da0734](https://github.com/conventoangelo/OverKeys/commit/9da0734189d70b9cf8fe4ad36fb6ac2cf7bb46bf))


### 🐛 Bug Fixes

* make modifiers default to left modifiers for now ([85ed250](https://github.com/conventoangelo/OverKeys/commit/85ed2506a04803ec99b8636adf772c4455a67418))
* split matrix errors due to changing space width ([bfdc418](https://github.com/conventoangelo/OverKeys/commit/bfdc41806b1096f5ce6f02bb7fa3144f37763d3f))

## [0.2.8](https://github.com/conventoangelo/OverKeys/compare/v0.2.7...v0.2.8) (2025-03-31)


### ✨ Features

* add window listener to try fixing focus behavior ([061485f](https://github.com/conventoangelo/OverKeys/commit/061485fcf862f4bc63402874261803bcd5336310))


### 🐛 Bug Fixes

* auto-hide in prefs window now updates even when closed ([061485f](https://github.com/conventoangelo/OverKeys/commit/061485fcf862f4bc63402874261803bcd5336310))
* force hide on tray icon click ([061485f](https://github.com/conventoangelo/OverKeys/commit/061485fcf862f4bc63402874261803bcd5336310))
* force single-instance of app ([061485f](https://github.com/conventoangelo/OverKeys/commit/061485fcf862f4bc63402874261803bcd5336310))
* force single-instance of preferences window ([061485f](https://github.com/conventoangelo/OverKeys/commit/061485fcf862f4bc63402874261803bcd5336310))
* tray menu now disappears when clicking anywhere after menu pops up ([061485f](https://github.com/conventoangelo/OverKeys/commit/061485fcf862f4bc63402874261803bcd5336310))
* tray menu, window logic, and UI fixes ([#57](https://github.com/conventoangelo/OverKeys/issues/57)) ([061485f](https://github.com/conventoangelo/OverKeys/commit/061485fcf862f4bc63402874261803bcd5336310))

## [0.2.7](https://github.com/conventoangelo/OverKeys/compare/v0.2.6...v0.2.7) (2025-03-30)


### ✨ Features

* add fade-in effect after toggling visibility on auto-hide enabled ([5e11aba](https://github.com/conventoangelo/OverKeys/commit/5e11aba5d152320f7f1140d4fc12f17b981f2a83))
* add hotkeys functionality ([#52](https://github.com/conventoangelo/OverKeys/issues/52)) ([5e11aba](https://github.com/conventoangelo/OverKeys/commit/5e11aba5d152320f7f1140d4fc12f17b981f2a83))


### 🐛 Bug Fixes

* add `enableAdvancedSettings` setting check for initialization tasks ([55c7569](https://github.com/conventoangelo/OverKeys/commit/55c75699add2103c90dffac1cc12bd2f57c5403f))
* correct user layout loading with Kanata and advanced settings ([55c7569](https://github.com/conventoangelo/OverKeys/commit/55c75699add2103c90dffac1cc12bd2f57c5403f))
* lastOpactiy now uses opactiy value on app open ([5e11aba](https://github.com/conventoangelo/OverKeys/commit/5e11aba5d152320f7f1140d4fc12f17b981f2a83))
* remove delay of applying advanced settings on app open ([5e11aba](https://github.com/conventoangelo/OverKeys/commit/5e11aba5d152320f7f1140d4fc12f17b981f2a83))
* show alt layout on startup only if advanced settings is on ([55c7569](https://github.com/conventoangelo/OverKeys/commit/55c75699add2103c90dffac1cc12bd2f57c5403f))
* trigger hide timer on app  ([55c7569](https://github.com/conventoangelo/OverKeys/commit/55c75699add2103c90dffac1cc12bd2f57c5403f))
* update keyboard layout only if no related advanced settings is on ([55c7569](https://github.com/conventoangelo/OverKeys/commit/55c75699add2103c90dffac1cc12bd2f57c5403f))
* use SharedPreferencesAsync from package ([2e1126f](https://github.com/conventoangelo/OverKeys/commit/2e1126fdd379dd47c9837c4cf7f495fcf1a61588))

## [0.2.6](https://github.com/conventoangelo/OverKeys/compare/v0.2.5...v0.2.6) (2025-03-27)


### ✨ Features

* make advanced settings toggle more intuitive/functional ([#40](https://github.com/conventoangelo/OverKeys/issues/40)) ([02cd74a](https://github.com/conventoangelo/OverKeys/commit/02cd74a532601f74df645e62227addf07906b175))


### 🐛 Bug Fixes

* remove unresponsive release-please on inno-setup script ([aad3f3c](https://github.com/conventoangelo/OverKeys/commit/aad3f3c52a6689a27173fe56d97a9fd88328c4d8))
* x-release-please touch inno-setup ([a3e0245](https://github.com/conventoangelo/OverKeys/commit/a3e0245b7c55e6fd07f2c434cfcdfd21cdffb758))


### 🧹 Miscellaneous Chores

* update README.md ([182e2dd](https://github.com/conventoangelo/OverKeys/commit/182e2ddf70c51cc88cb7a49e95c211657a39aedb))


### ⚙️ CI/CD Pipeline

* add .dlls and inno-setup script ([614dd42](https://github.com/conventoangelo/OverKeys/commit/614dd425b6a25accbfa68d6f8457570b981e91c8))
* add inno-setup script to release-please ([a0835a9](https://github.com/conventoangelo/OverKeys/commit/a0835a9a816f00183ac51ed17314db456131ab17))
* add winget-releaser to workflow ([0bb56b9](https://github.com/conventoangelo/OverKeys/commit/0bb56b94a613c78e45b6bfda6eef57db6f27b6a4))
* initialize release-please ([010e5ee](https://github.com/conventoangelo/OverKeys/commit/010e5ee9b9cc44d54386c185943e8a8bec9bd0a3))
* remove release-type in yaml file ([38b85c3](https://github.com/conventoangelo/OverKeys/commit/38b85c3d45b74b5a2973baa30b7570a94d96c8b7))
* update PR title pattern ([78a643e](https://github.com/conventoangelo/OverKeys/commit/78a643e5056a8071ec38ea5441b9da1481e738ca))
* update release-please action reference to googleapis ([093d5ab](https://github.com/conventoangelo/OverKeys/commit/093d5ab0995ace03a9aca808f3de74122b5c6ce2))
* update release-please configuration for improved changelog sections and patterns ([21af092](https://github.com/conventoangelo/OverKeys/commit/21af0920ec8968769a0f60e756283a2fc7e795dc))
* update release-please configuration with package details and changelog path ([706a3fe](https://github.com/conventoangelo/OverKeys/commit/706a3fe50e21c04df4a69024f4f9fc13cc3d17fd))


### ⏪ Reverts

* add back rp in inno-setup ([e528592](https://github.com/conventoangelo/OverKeys/commit/e528592c244d3acfded7aa8d50df4465ebde9a52))
