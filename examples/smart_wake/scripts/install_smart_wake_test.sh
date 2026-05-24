#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${HA_CONFIG_DIR:-}" ]]; then
  echo "ERROR: HA_CONFIG_DIR is required."
  echo "Example: HA_CONFIG_DIR=/path/to/ha_config HA_CONTAINER=homeassistant $0"
  exit 1
fi

HA_CONTAINER="${HA_CONTAINER:-homeassistant}"
RESTART_HA_AFTER_VALIDATION="${RESTART_HA_AFTER_VALIDATION:-0}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SMART_WAKE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="${HA_CONFIG_DIR}/_smart_wake_test_backups/${STAMP}"
PACKAGES_DIR="${HA_CONFIG_DIR}/packages"
SNIPPETS_DIR="${HA_CONFIG_DIR}/dashboards/snippets"

TARGET_SITE_CONFIG="${PACKAGES_DIR}/smart_wake_site_config_test.yaml"
TARGET_PACKAGE="${PACKAGES_DIR}/smart_wake_package_test.yaml"
TARGET_CARD="${SNIPPETS_DIR}/smart-wake-card-test.yaml"

SRC_SITE_CONFIG="${SMART_WAKE_DIR}/site_config.example.yaml"
SRC_PACKAGE="${SMART_WAKE_DIR}/package.example.yaml"
SRC_CARD="${SMART_WAKE_DIR}/dashboard-card.example.yaml"

mkdir -p "${PACKAGES_DIR}" "${SNIPPETS_DIR}" "${BACKUP_ROOT}"

SITE_CONFIG_HAD_PRIOR=0
PACKAGE_HAD_PRIOR=0
CARD_HAD_PRIOR=0

if [[ -f "${TARGET_SITE_CONFIG}" ]]; then
  cp "${TARGET_SITE_CONFIG}" "${BACKUP_ROOT}/smart_wake_site_config_test.yaml.bak"
  SITE_CONFIG_HAD_PRIOR=1
fi
if [[ -f "${TARGET_PACKAGE}" ]]; then
  cp "${TARGET_PACKAGE}" "${BACKUP_ROOT}/smart_wake_package_test.yaml.bak"
  PACKAGE_HAD_PRIOR=1
fi
if [[ -f "${TARGET_CARD}" ]]; then
  cp "${TARGET_CARD}" "${BACKUP_ROOT}/smart-wake-card-test.yaml.bak"
  CARD_HAD_PRIOR=1
fi

cp "${SRC_SITE_CONFIG}" "${TARGET_SITE_CONFIG}"
cp "${SRC_PACKAGE}" "${TARGET_PACKAGE}"
cp "${SRC_CARD}" "${TARGET_CARD}"

set +e
docker exec "${HA_CONTAINER}" python -m homeassistant --script check_config --config /config
CHECK_EXIT=$?
set -e

if [[ ${CHECK_EXIT} -ne 0 ]]; then
  echo "Config check failed. Rolling back test files..."

  if [[ ${SITE_CONFIG_HAD_PRIOR} -eq 1 ]]; then
    cp "${BACKUP_ROOT}/smart_wake_site_config_test.yaml.bak" "${TARGET_SITE_CONFIG}"
  else
    rm -f "${TARGET_SITE_CONFIG}"
  fi

  if [[ ${PACKAGE_HAD_PRIOR} -eq 1 ]]; then
    cp "${BACKUP_ROOT}/smart_wake_package_test.yaml.bak" "${TARGET_PACKAGE}"
  else
    rm -f "${TARGET_PACKAGE}"
  fi

  if [[ ${CARD_HAD_PRIOR} -eq 1 ]]; then
    cp "${BACKUP_ROOT}/smart-wake-card-test.yaml.bak" "${TARGET_CARD}"
  else
    rm -f "${TARGET_CARD}"
  fi

  echo "Re-checking config after rollback..."
  docker exec "${HA_CONTAINER}" python -m homeassistant --script check_config --config /config || true
  exit 1
fi

if [[ "${RESTART_HA_AFTER_VALIDATION}" == "1" ]]; then
  echo "Restart requested. Restarting HA container: ${HA_CONTAINER}"
  docker restart "${HA_CONTAINER}"
else
  echo "Config check passed. No restart performed."
fi

cat <<EOF
Install complete.

Copied:
  ${TARGET_SITE_CONFIG}
  ${TARGET_PACKAGE}
  ${TARGET_CARD}

Backup dir:
  ${BACKUP_ROOT}

Next manual test steps:
  1) In Home Assistant, ensure helpers from smart_wake_site_config_test.yaml are present.
  2) Set Wake Room / Target Area to "Custom".
  3) Put exactly one safe light in input_text.smart_wake_target_lights_custom_csv.
  4) Set source to Manual Time and set wake time a few minutes ahead.
  5) Enable input_boolean.smart_wake_enabled for the test window.
  6) Disable input_boolean.smart_wake_enabled after testing.
EOF

