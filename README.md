# MyScaleNoz

**Keep using your MyKronoz / Yolanda body-composition scale after its cloud
service was shut down.**

MyScaleNoz is a free, open-source Android app that talks to the scale directly
over Bluetooth, reads the weight and the bioelectrical impedance, and computes
the full body composition **on your phone** — with the same algorithm the
original app used. No account, no cloud, no internet access.

> Unofficial. Not affiliated with, endorsed by or connected to MyKronoz,
> Yolanda or Qingniu. All product names and trademarks belong to their owners.

## Download

Get the APK from the [Releases](https://github.com/atanas-mavrov/myscalenoz/releases)
page and install it (Android 7.0 or newer; allow installing from this source
when Android asks). Every release is signed with the same key, so newer
versions install over older ones and keep your data.

## Features

- Live measurement: step on the scale, the app connects by itself and chimes
  when you can step off.
- 14 values per measurement: BMI, body fat, lean mass, subcutaneous and
  visceral fat, body water, BMR, skeletal muscle, muscle mass, bone mass,
  protein, body score, body age and body type — each with a plain-language
  explanation in the app.
- Several users on one scale; each measurement goes to the selected user (and
  can be moved to another one).
- Statistics: line, bar or scatter charts over any period, for any value.
- Backup and restore (JSON), export to CSV. The backup format is documented,
  so data from elsewhere can be imported too — see
  [docs/BACKUP_FORMAT.md](docs/BACKUP_FORMAT.md).
- English, Bulgarian, German, Spanish and French; follows the phone's
  language or a language you choose. Light and dark theme.

## Supported scales

Tested with the **MyKronoz MyScale** Wi-Fi body-composition scale, which
advertises over Bluetooth as `QN-Scale`. Other scales built on the same
Yolanda / Qingniu platform that use the standard Bluetooth weight and
body-composition profiles may work too, but have not been tested. Reports are
welcome — please open an issue.

Heart rate is not available: the scale does not send it in this mode.

## Privacy

All data stays on the phone. The app does not even request internet access;
there are no analytics and no accounts. Data leaves the device only when you
export or share it yourself.

## How it works

- **Bluetooth:** the scale stays silent until the vendor app's session start-up
  is reproduced: the app sets the scale's clock and opens a temporary "visitor"
  session. Nothing is stored on the scale — no users are registered there.
  It then reads the weight (`0x2A9D`) and the impedance at 50 and 500 kHz from
  the body-composition frame (`0x2A9C`).
- **Body composition:** computed from weight, impedance, height, sex and age by
  a re-implementation of the vendor's algorithm, verified bit for bit against
  the original library. See [reference/ALGORITHM.md](reference/ALGORITHM.md).
  No vendor code is included.

The values are estimates for following trends over time, not a medical
diagnosis.

## Building

Requirements: Flutter 3.47 or newer, Android SDK with platform 37.

```sh
flutter pub get
flutter test
flutter build apk --release
```

Android 7.0 (API 24) or newer is required.

Release builds are signed with the key described in `android/key.properties`
(not in the repository); without that file they are signed with the debug key.
GitHub Actions builds and tests every push and publishes a release with the
APK for every `v*` tag — see [.github/workflows/build.yml](.github/workflows/build.yml).

## License

Copyright © 2026 Atanas Mavrov.

MyScaleNoz is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License, version 3 or (at your option)
any later version. See [LICENSE](LICENSE).
