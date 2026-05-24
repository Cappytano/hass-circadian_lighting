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
- `package.example.yaml`
  - Example automation and script behavior for staged wake ramp logic.
  - Uses only helper-driven configuration.

## Current Framing

This folder is currently best treated as an advanced example package pattern.

- It is not an integration runtime feature.
- It is not yet a formal Home Assistant blueprint.
- It can serve as a blueprint candidate later, after broader validation and UX simplification.

## Install and Use (Example Workflow)

These are example artifacts, not auto-loaded by Home Assistant from this repository path.

1. Copy `site_config.example.yaml` and `package.example.yaml` into your own Home Assistant config layout.
2. Include them in your Home Assistant configuration using your package/include approach.
3. Replace placeholder entities before enabling behavior (lights, phone alarm sensor, wake settings).
4. Run configuration validation before enabling the automations/scripts.

Suggested local/private override naming:
- `site_config.local.yaml`

Important:
- Home Assistant only loads files that you explicitly include in your configuration.
- A `.local.yaml` file name is just a convention until you wire it into your include setup.

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
- Phone alarm behavior depends on providing a valid next-alarm-like sensor in `input_text.smart_wake_phone_alarm_sensor`.
- Sunrise behavior depends on `sun.sun`.

The package intentionally does not:
- modify integration runtime code
- merge wake behavior into `input_boolean.circadian_rhythm`
- force restore-to-off behavior for wake lights

Light capability behavior in the example:
- CCT-capable lights use `color_temp_kelvin` first.
- RGB/XY fallback depends on `sensor.circadian_values` attributes being available.
- Brightness-only lights receive brightness updates only.

## Validation (Repo-Local)

Run from repo root:

```bash
git status
git diff --check
```

Home Assistant validation should be run in your own environment:

- Home Assistant UI path: `Developer Tools -> YAML -> Check configuration` (wording may vary by release).
- Container CLI example (adjust config path for your setup):

```bash
python -m homeassistant --script check_config --config /config
```

## Public Fork vs Upstream PR

- `PUBLIC_READINESS_AUDIT.md` is useful in a fork as a contribution/privacy checklist.
- A likely upstream PR scope is `examples/smart_wake/*`, and optionally `.gitignore` if maintainers want those rules.
- `PUBLIC_READINESS_AUDIT.md` can be omitted from an upstream PR unless a maintainer explicitly requests it.
