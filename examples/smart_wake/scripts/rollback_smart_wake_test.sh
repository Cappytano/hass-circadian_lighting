#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${HA_CONFIG_DIR:-}" ]]; then
  echo "ERROR: HA_CONFIG_DIR is required."
  echo "Example: HA_CONFIG_DIR=/path/to/ha_config HA_CONTAINER=homeassistant $0"
  exit 1
fi

HA_CONTAINER="${HA_CONTAINER:-homeassistant}"
RESTART_HA_AFTER_VALIDATION="${RESTART_HA_AFTER_VALIDATION:-0}"

PACKAGES_DIR="${HA_CONFIG_DIR}/packages"
SNIPPETS_DIR="${HA_CONFIG_DIR}/dashboards/snippets"
BACKUPS_BASE="${HA_CONFIG_DIR}/_smart_wake_test_backups"

TARGET_SITE_CONFIG="${PACKAGES_DIR}/smart_wake_site_config_test.yaml"
TARGET_PACKAGE="${PACKAGES_DIR}/smart_wake_package_test.yaml"
TARGET_CARD="${SNIPPETS_DIR}/smart-wake-card-test.yaml"

rm -f "${TARGET_SITE_CONFIG}" "${TARGET_PACKAGE}" "${TARGET_CARD}"

LATEST_BACKUP=""
if [[ -d "${BACKUPS_BASE}" ]]; then
  LATEST_BACKUP="$(find "${BACKUPS_BASE}" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1 || true)"
fi

if [[ -n "${LATEST_BACKUP}" ]]; then
  echo "Latest backup found: ${LATEST_BACKUP}"

  if [[ -f "${LATEST_BACKUP}/smart_wake_site_config_test.yaml.bak" ]]; then
    cp "${LATEST_BACKUP}/smart_wake_site_config_test.yaml.bak" "${TARGET_SITE_CONFIG}"
  fi
  if [[ -f "${LATEST_BACKUP}/smart_wake_package_test.yaml.bak" ]]; then
    cp "${LATEST_BACKUP}/smart_wake_package_test.yaml.bak" "${TARGET_PACKAGE}"
  fi
  if [[ -f "${LATEST_BACKUP}/smart-wake-card-test.yaml.bak" ]]; then
    cp "${LATEST_BACKUP}/smart-wake-card-test.yaml.bak" "${TARGET_CARD}"
  fi
else
  echo "No backup directory found. Test files were removed only."
fi

docker exec "${HA_CONTAINER}" python -m homeassistant --script check_config --config /config

if [[ "${RESTART_HA_AFTER_VALIDATION}" == "1" ]]; then
  echo "Restart requested. Restarting HA container: ${HA_CONTAINER}"
  docker restart "${HA_CONTAINER}"
else
  echo "Rollback complete. No restart performed."
fi
