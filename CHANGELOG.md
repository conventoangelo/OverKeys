# Changelog

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
