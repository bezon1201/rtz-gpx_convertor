#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
scratch=$(mktemp -d "${TMPDIR:-/tmp}/rtz-ip2a-r5.XXXXXX")
trap 'rm -rf "$scratch"' EXIT HUP INT TERM
app="$scratch/IP2AR5Probe.app"
mkdir -p "$app/Contents/MacOS"
cp "$script_dir/Info.plist" "$app/Contents/Info.plist"

swiftc -O -target arm64-apple-macosx26.0 "$script_dir/ProbeApp.swift" -framework AppKit -framework Security -o "$app/Contents/MacOS/R5Sender"
swiftc -O -target arm64-apple-macosx26.0 "$script_dir/ProbeReceiver.swift" -framework Security -o "$app/Contents/MacOS/R5Receiver"

codesign --force --sign - --identifier org.example.rtzgpx.ip2a-r5-probe.helper --entitlements "$script_dir/Receiver-Entitlements.plist" "$app/Contents/MacOS/R5Receiver"
codesign --force --sign - --identifier org.example.rtzgpx.ip2a-r5-probe --entitlements "$script_dir/App-Entitlements.plist" "$app"
codesign --verify --deep --strict --verbose=2 "$app"

fixture="$scratch/synthetic files"
mkdir -p "$fixture"
printf 'R5 synthetic payload one\n' > "$fixture/R5 selection one é.txt"
printf 'R5 synthetic payload two Ω\n' > "$fixture/R5 selection second é.txt"
printf 'R5 permission denied payload\n' > "$fixture/R5 permission denied.txt"
chmod 000 "$fixture/R5 permission denied.txt"

printf 'R5_APP_SANDBOX_ENTITLEMENT=true\n'
codesign -d --entitlements :- "$app" 2>&1 | sed -n '/com.apple.security.app-sandbox/,+3p'
printf 'R5_RECEIVER_INHERIT_ENTITLEMENT=true\n'
codesign -d --entitlements :- "$app/Contents/MacOS/R5Receiver" 2>&1 | sed -n '/com.apple.security.inherit/,+3p'
printf 'R5_SYNTHETIC_PICKER_DIRECTORY=%s\n' "$fixture"
"$app/Contents/MacOS/R5Sender"
