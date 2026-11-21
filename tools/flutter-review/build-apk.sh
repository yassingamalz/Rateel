#!/usr/bin/env bash
# Build the release APK for the owner's phone (cloud container).
# Idempotent: installs Flutter 3.50.1 and the Android SDK only when missing.
# Usage: tools/flutter-review/build-apk.sh   (from the repo root)
# Output: app_flutter/build/app/outputs/flutter-apk/app-release.apk
# Notes (see docs/flutter/PROCESS.md, "APK"):
# - Downloads go through the container's HTTPS proxy; Java/Gradle already trust it via
#   JAVA_TOOL_OPTIONS. Gradle runs with ONE worker (android/gradle.properties:
#   org.gradle.workers.max=1): parallel downloads hit the proxy's rate limits ("mirror" errors).
# - If a download still fails with a 429/timeout, re-run this script: Gradle resumes from its cache.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SDK=/opt/android-sdk
FLUTTER=/opt/flutter/bin/flutter

if [ ! -x "$FLUTTER" ]; then
  echo "== Flutter 3.50.1"
  curl -sSfL -o /tmp/flutter.tar.xz \
    https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.50.1-stable.tar.xz
  tar xf /tmp/flutter.tar.xz -C /opt && rm /tmp/flutter.tar.xz
  git config --global --add safe.directory /opt/flutter
fi

if [ ! -d "$SDK/platforms/android-36" ] || [ ! -d "$SDK/build-tools/36.0.0" ]; then
  echo "== Android SDK (cmdline-tools, platform-tools, android-36, build-tools 36.0.0)"
  mkdir -p "$SDK/cmdline-tools"
  if [ ! -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
    curl -sSfL -o /tmp/cmdtools.zip \
      https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip
    unzip -q -o /tmp/cmdtools.zip -d "$SDK/cmdline-tools"
    rm -rf "$SDK/cmdline-tools/latest"
    mv "$SDK/cmdline-tools/cmdline-tools" "$SDK/cmdline-tools/latest"
    rm /tmp/cmdtools.zip
  fi
  yes | "$SDK/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$SDK" --licenses >/dev/null 2>&1 || true
  "$SDK/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$SDK" \
    "platform-tools" "platforms;android-36" "build-tools;36.0.0"
fi

cd "$ROOT/app_flutter"
"$FLUTTER" config --android-sdk "$SDK" >/dev/null
"$FLUTTER" pub get >/dev/null
# Progressive version (owner, 2026-11-21): every build gets a higher versionCode, so the
# phone can update the installed app. versionCode = number of commits on HEAD (only grows);
# versionName = 1.0.<code>. NOTE: an update also needs the SAME signing key; the APK is
# signed with this container's debug key (~/.android/debug.keystore), see PROCESS.md.
CODE=$(git -C "$ROOT" rev-list --count HEAD)
echo "== flutter build apk (release, arm64), version 1.0.$CODE ($CODE)"
"$FLUTTER" build apk --release --target-platform android-arm64 \
  --build-name="1.0.$CODE" --build-number="$CODE"
cp build/app/outputs/flutter-apk/app-release.apk "build/app/outputs/flutter-apk/rateel-1.0.$CODE.apk"
ls -la "build/app/outputs/flutter-apk/rateel-1.0.$CODE.apk"
