# Smart Wake Example (Upstream-Safe)

This folder contains reusable Home Assistant example artifacts for Smart Wake / Sunrise Alarm lighting.

Design goals:
- Keep Smart Wake behavior separate from `input_boolean.circadian_rhythm`.
- Keep private/local deployment details out of publishable files.
- Use `sensor.circadian_values` as a value source when RGB/XY fallback is needed.
- Never use `effect: "Circadian rhythm"`.

## Files

- `site_config.example.yaml`
  - Helper entities and user-tunable settings.
  - Copy to a local override file before editing values.
- `package.example.yaml`
  - Example automation and script behavior for staged wake ramp logic.
  - Uses only helper-driven configuration.

## Public/Private Boundary

Public example files should include placeholders only:
- `light.bedroom_lamp`
- `light.kitchen_ceiling`
- `sensor.phone_next_alarm`
- `America/New_York` (as an example only)

Do not commit private values such as:
- real host paths
- private room names
- private light entity IDs
- personal phone alarm sensor IDs
- backup/log folders and troubleshooting artifacts

## Local Override Pattern

Recommended local workflow:
1. Copy `site_config.example.yaml` to `site_config.local.yaml`.
2. Replace placeholders with local entity IDs and preferences.
3. Keep local files excluded by `.gitignore` (`*.local.yaml`, `local_config/`, `private/`, `_local/`).

## Behavior Notes

The example package is designed for iterative rollout:
- Stage B helpers are configured in `site_config.example.yaml`.
- Stage C behavior (manual-time wake ramp) is active in `package.example.yaml`.
- Optional sources (phone alarm, sunrise, earliest/latest) are included via `input_select.smart_wake_source`.

The package intentionally does not:
- modify integration runtime code
- merge wake behavior into `input_boolean.circadian_rhythm`
- force restore-to-off behavior for wake lights

## Validation (Repo-Local)

Run from repo root:

```bash
git status
git diff --check
```

Home Assistant validation should be run in your own environment:

- Home Assistant UI path: `Developer Tools -> YAML -> Check configuration` (wording may vary by release).
- Container example (adjust config path for your setup):

```bash
python -m homeassistant --script check_config --config /config
```
