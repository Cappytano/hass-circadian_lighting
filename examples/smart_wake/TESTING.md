# Smart Wake Test Checklist (Controlled Live Test)

This guide is for a cautious first live test of the Smart Wake example package.

## Safety First

- Do not test all lights first.
- Start with `Manual Time` source only.
- Start with `Custom` target area only.
- Put exactly one known safe light into `input_text.smart_wake_target_lights_custom_csv`.
- Keep ramp duration short (for example, 5 minutes).

## Recommended First Test Flow

1. Confirm helper entities are loaded from your package/include setup.
2. Paste `dashboard-card.example.yaml` into a Lovelace Manual card (optional, but useful).
3. Verify `input_boolean.smart_wake_enabled` is `off` before setup.
4. Set:
   - `input_select.smart_wake_source` = `Manual Time`
   - `input_select.smart_wake_target_preset` = `Custom`
   - `input_text.smart_wake_target_lights_custom_csv` = one safe light entity
   - `input_number.smart_wake_ramp_duration_minutes` = `5`
5. Set manual wake time a few minutes ahead.
6. Enable `input_boolean.smart_wake_enabled`.
7. Watch the target light through the ramp window.
8. Disable `input_boolean.smart_wake_enabled` after test completion.

Do not move to phone alarm or sunrise modes until Manual Time works cleanly.

## Verification Checklist

- Helpers exist and are editable.
- Target area dropdown reveals only the matching target helper in the dashboard.
- Manual card renders if you pasted the dashboard snippet.
- No Smart Wake template/config errors appear in logs.

## Log Check Example

```bash
HA_CONTAINER="${HA_CONTAINER:-homeassistant}"
docker logs --since=10m "$HA_CONTAINER" 2>&1 | grep -Ei "smart_wake|Smart Wake|TemplateError|Invalid config|Invalid data|Error while executing|yaml|package" || true
```

## Rollback

Use `scripts/rollback_smart_wake_test.sh` if you want to remove the test package/snippet files and restore the latest backup.

