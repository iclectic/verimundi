#!/usr/bin/env bash
# Reports whether this machine can build VeriMundi Android artefacts.
# Exit 0 when SDK looks usable; exit 1 with guidance when blocked.
set -euo pipefail

echo "VeriMundi Android SDK check"
echo "---------------------------"
echo "Docs: docs/release/android_sdk_blocker.md"
echo "      docs/release/android_signing_checklist.md"
echo "      docs/release/android_ci_notes.md"

if [[ -z "${ANDROID_HOME:-}" && -z "${ANDROID_SDK_ROOT:-}" ]]; then
  echo "BLOCKED: ANDROID_HOME / ANDROID_SDK_ROOT not set."
  echo "CI note: Flutter workflow does not build APK/AAB without an SDK runner."
  exit 1
fi

SDK_ROOT="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
echo "SDK root: $SDK_ROOT"

if [[ ! -d "$SDK_ROOT" ]]; then
  echo "BLOCKED: SDK root directory does not exist."
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "BLOCKED: flutter not on PATH."
  exit 1
fi

echo "Running: flutter doctor (Android section)"
flutter doctor -v | sed -n '1,80p' || true

if [[ -f android/key.properties ]]; then
  echo "Signing: android/key.properties present (do not commit)."
else
  echo "Signing: android/key.properties missing — release Gradle tasks will fail until created."
fi

if flutter build apk --debug -t lib/main.dart --dry-run 2>/dev/null; then
  echo "OK: flutter reports an Android build toolchain."
  exit 0
fi

# dry-run may be unsupported; fall back to devices / doctor Android line
if flutter doctor 2>/dev/null | grep -qi 'Android toolchain.*✓'; then
  echo "OK: Android toolchain present per flutter doctor."
  exit 0
fi

echo "BLOCKED: Android toolchain not ready for APK/AAB builds."
echo "Install SDK, accept licences, then re-run this script."
exit 1
