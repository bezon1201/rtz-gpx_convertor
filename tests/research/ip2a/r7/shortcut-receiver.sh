#!/bin/sh
set -eu

printf 'shortcut-shell pid=%s ppid=%s uid=%s argc=%s\n' "$$" "$PPID" "$(id -u)" "$#"
if launchctl procinfo "$$" >/dev/null 2>&1; then
	printf 'launchctl-procinfo=available (details intentionally not persisted)\n'
else
	printf 'launchctl-procinfo=unavailable-or-denied\n'
fi

receiver=${RTZ_R7_RECEIVER:?Set only to the temporary R7 research receiver}
for path do
	"$receiver" --path "$path"
done
