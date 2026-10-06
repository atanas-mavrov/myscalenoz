# MyScaleNoz backup file format

MyScaleNoz imports and exports its data as a single **JSON** file (UTF-8). A
file made with *Settings → Export and import → Backup (JSON)* can be imported
back as is. You can also write such a file yourself — for example to bring in
measurements from another app or from a spreadsheet. This page describes what
the importer accepts.

The same description is available inside the app: *Settings → Export and
import → ⓘ next to "Import from backup"*.

## Structure

```json
{
  "format": "myscalenoz-backup",
  "version": 1,
  "profiles": [ ... ],
  "measurements": [ ... ]
}
```

| Key            | Required | Meaning |
|----------------|----------|---------|
| `profiles`     | yes      | List of users (may be empty only if there are no measurements). |
| `measurements` | no       | List of measurements. Missing = profiles only. |
| `format`, `version`, `exportedAt` | no | Written by the app; ignored on import. |

## Profile

| Field           | Required | Type / format | Meaning |
|-----------------|----------|---------------|---------|
| `id`            | yes¹     | integer       | Any number, unique within the file. Only used to link measurements to the profile; the app assigns its own id. |
| `name`          | yes      | text          | User name. |
| `gender`        | yes      | `"male"` or `"female"` | Sex; used by the body-composition formula. |
| `height_cm`     | yes      | number        | Height in centimetres. |
| `birthday`      | yes      | `"YYYY-MM-DD"` | Date of birth. |
| `ref_weight_kg` | no       | number        | Usual weight in kg. |
| `created_at`    | no       | ISO 8601 date-time | When the profile was created. Missing = time of import. |

¹ Needed when the file has measurements.

## Measurement

| Field           | Required | Type / format | Meaning |
|-----------------|----------|---------------|---------|
| `profile_id`    | yes      | integer       | The `id` of a profile **in the same file**. Measurements pointing to an unknown profile are skipped. |
| `timestamp_utc` | yes      | ISO 8601 date-time | When it was measured, e.g. `"2026-10-01T07:30:00Z"`. With `Z` (or an offset) the time is exact; without, it is read as the phone's local time. |
| `weight_kg`     | yes      | number        | Weight in kilograms. |
| `r50`           | no       | integer       | Body impedance at 50 kHz, in ohms. `0` or missing = weight only. |
| `r500`          | no       | integer       | Body impedance at 500 kHz, in ohms. `0` or missing if the scale has no second frequency. |
| `source`        | no       | text          | Free label; `"import"` if missing. |
| `id`            | no       | integer       | Ignored. |

**Body composition** fields are optional: `bmi`, `fat_pct`, `lean_mass_kg`,
`subcut_fat_pct`, `visceral`, `water_pct`, `bmr`, `skel_muscle_pct`,
`muscle_mass_kg`, `bone_mass_kg`, `protein_pct`, `body_score`, `body_age`,
`body_shape` (units as in the app: % for `*_pct`, kg for `*_kg`, kcal for
`bmr`, years for `body_age`, 1–9 for `body_shape`).

- Values present in the file are imported **as they are** — also without
  impedance, e.g. values already calculated by another app or scale. They are
  not recalculated, so they may differ from what this app's formula would give.
- Missing values are **computed on import** from the weight, the impedance and
  the profile (height, sex, age at the time of the measurement) — the same way
  as for a new measurement. Without impedance only the BMI can be computed.

## Rules on import

- Existing data is never changed or deleted; the file is **added** to it.
- A profile with the same `name`, `gender`, `height_cm` and `birthday` as an
  existing user is treated as that user (no duplicate is created).
- A measurement with the same user, time, weight and impedance as an existing
  one is skipped, so importing the same file twice adds nothing.
- If the file is not valid (not JSON, a required field missing, a wrong
  `gender`, an unreadable date), **nothing** is imported and the app says the
  file is not a backup.
- Numbers use a dot as the decimal separator (`78.6`), as JSON requires.

## Minimal example

Two measurements of one user; body composition will be computed on import.

```json
{
  "profiles": [
    { "id": 1, "name": "Anna", "gender": "female",
      "height_cm": 168, "birthday": "1985-04-12" }
  ],
  "measurements": [
    { "profile_id": 1, "timestamp_utc": "2026-09-01T06:45:00Z",
      "weight_kg": 64.2, "r50": 512, "r500": 461 },
    { "profile_id": 1, "timestamp_utc": "2026-09-08T06:50:00Z",
      "weight_kg": 63.8 }
  ]
}
```

The second measurement has no impedance, so only its weight and BMI are kept.

Values already calculated elsewhere, without impedance:

```json
{ "profile_id": 1, "timestamp_utc": "2025-03-15T07:00:00Z",
  "weight_kg": 66.0, "fat_pct": 29.4, "water_pct": 51.2, "bmr": 1310 }
```
