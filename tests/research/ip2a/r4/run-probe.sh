#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
scratch=$(mktemp -d "${TMPDIR:-/tmp}/rtz-ip2a-r4.XXXXXX")
trap 'rm -rf "$scratch"' EXIT HUP INT TERM

swiftc -O "$script_dir/FileReferenceProbe.swift" -o "$scratch/FileReferenceProbe"
"$scratch/FileReferenceProbe" > "$scratch/results.json"
cat "$scratch/results.json"
