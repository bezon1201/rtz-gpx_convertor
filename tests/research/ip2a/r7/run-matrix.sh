#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
scratch=$(mktemp -d "${TMPDIR:-/tmp}/rtz-ip2a-r7.XXXXXX")
if [ "${KEEP_SCRATCH:-0}" = 1 ]; then
	trap 'printf "scratchRetained=%s\\n" "$scratch"' EXIT
else
	trap 'rm -rf "$scratch"' EXIT HUP INT TERM
fi
receiver="$scratch/R7IndependentReceiver"
ordinary="$scratch/R7OrdinaryReceiver"
app="$scratch/R7IndependentReceiver.app"
fixture="$scratch/synthetic files"
mkdir -p "$fixture"

swiftc -O -target arm64-apple-macosx26.0 -framework Security "$script_dir/Receiver.swift" -o "$ordinary"
codesign --force --sign - --identifier org.example.rtzgpx.ip2a-r7-ordinary-comparison "$ordinary"
mkdir -p "$app/Contents/MacOS"
cp "$script_dir/Info.plist" "$app/Contents/Info.plist"
cp "$ordinary" "$app/Contents/MacOS/R7IndependentReceiver"
codesign --force --sign - --identifier org.example.rtzgpx.ip2a-r7-independent-receiver --entitlements "$script_dir/IndependentReceiver-Entitlements.plist" "$app"
receiver="$app/Contents/MacOS/R7IndependentReceiver"
codesign --verify --deep --strict --verbose=2 "$app"

printf 'R7 synthetic readable payload\n' > "$fixture/readable é space.txt"
printf 'R7 synthetic second payload\n' > "$fixture/second Ω.txt"
printf 'R7 synthetic denied payload\n' > "$fixture/denied.txt"
chmod 000 "$fixture/denied.txt"
mkfifo "$fixture/fifo"
ln -s "$fixture/readable é space.txt" "$fixture/link"

printf '%s\n' '--- Host and signing ---'
sw_vers
uname -m
swift --version
clang --version | head -2
codesign -dv --verbose=4 "$receiver" 2>&1 | sed -n '1,16p'
codesign -d --entitlements :- "$receiver" 2>&1
printf '%s\n' '--- Independent sandboxed receiver: expected no user-selected-file authority ---'
"$receiver" --path "$fixture/readable é space.txt" --expected-id "$(stat -f '%d:%i' "$fixture/readable é space.txt")" --path "$fixture/second Ω.txt" --expected-id "$(stat -f '%d:%i' "$fixture/second Ω.txt")"
printf '%s\n' '--- Ordinary unsigned shell access control comparison (not a grant) ---'
for path in "$fixture/readable é space.txt" "$fixture/denied.txt"; do
	if test -r "$path"; then printf 'shell-readable=true\n'; else printf 'shell-readable=false\n'; fi
done
printf '%s\n' '--- Ordinary separately launched receiver: path opens are not an authority grant ---'
"$ordinary" --path "$fixture/readable é space.txt" --expected-id "$(stat -f '%d:%i' "$fixture/readable é space.txt")" --path "$fixture/second Ω.txt" --expected-id "$(stat -f '%d:%i' "$fixture/second Ω.txt")" --path "$fixture/denied.txt" --expected-id "$(stat -f '%d:%i' "$fixture/denied.txt")"
printf '%s\n' '--- Nonregular and symlink no-follow policy ---'
"$ordinary" --path "$fixture/fifo" --expected-id "$(stat -f '%d:%i' "$fixture/fifo")" --path "$fixture/link" --expected-id "$(stat -f '%d:%i' "$fixture/link")"

printf '%s\n' '--- Deterministic deletion before receiver open ---'
printf 'R7 delete payload\n' > "$fixture/delete-before-open.txt"
rm "$fixture/delete-before-open.txt"
"$ordinary" --path "$fixture/delete-before-open.txt" --expected-id missing

printf '%s\n' '--- Deterministic replacement before receiver open (ordinary host receiver) ---'
printf 'R7 original object\n' > "$fixture/replace.txt"
original_id=$(stat -f '%d:%i' "$fixture/replace.txt")
mv "$fixture/replace.txt" "$fixture/original-held.txt"
printf 'R7 replacement object\n' > "$fixture/replace.txt"
replacement_id=$(stat -f '%d:%i' "$fixture/replace.txt")
if [ "$original_id" != "$replacement_id" ]; then replacement_identity_changed=true; else replacement_identity_changed=false; fi
printf 'replacementIdentityChanged=%s\n' "$replacement_identity_changed"
"$ordinary" --path "$fixture/replace.txt" --expected-id "$original_id"

printf '%s\n' '--- Deterministic symlink retarget before receiver open ---'
printf 'R7 symlink target one\n' > "$fixture/target-one.txt"
printf 'R7 symlink target two\n' > "$fixture/target-two.txt"
ln -s "$fixture/target-one.txt" "$fixture/retarget.txt"
rm "$fixture/retarget.txt"
ln -s "$fixture/target-two.txt" "$fixture/retarget.txt"
"$ordinary" --path "$fixture/retarget.txt" --expected-id "$(stat -f '%d:%i' "$fixture/retarget.txt")"

printf '%s\n' '--- Cancellation before open: receiver gated, then terminated before gate release ---'
printf 'R7 cancellation payload\n' > "$fixture/cancel.txt"
gate="$scratch/release-receiver"
"$ordinary" --path "$fixture/cancel.txt" --gate "$gate" > "$scratch/cancel.out" 2>&1 &
pid=$!
sleep 0.2
kill -TERM "$pid"
set +e
wait "$pid"
cancel_status=$?
set -e
printf 'receiverExit=%s;gateReleased=false;openNotReached=true\n' "$cancel_status"
test ! -e "$gate"
printf '%s\n' '--- Cleanup ---'
printf 'scratchRemoval=automatic-on-exit\n'
