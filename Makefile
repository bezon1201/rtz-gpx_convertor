BIN := build/rtz-gpx-converter
SOURCE := Sources/RTZGPXPrototype.swift
LOCAL_INSTALL_DIR := $(HOME)/Applications/RTZ-GPX Converter
LOCAL_BIN := $(LOCAL_INSTALL_DIR)/rtz-gpx-converter

.PHONY: build test install-local clean

build: $(BIN)

$(BIN): $(SOURCE)
	@mkdir -p build
	swiftc -O $(SOURCE) -o $(BIN)

test: $(BIN)
	bash ./tests/prototype/test-converter.sh ./$(BIN)

install-local: $(BIN)
	@set -eu; \
	install_dir='$(LOCAL_INSTALL_DIR)'; \
	target='$(LOCAL_BIN)'; \
	mkdir -p "$$install_dir"; \
	tmp="$$(mktemp "$$install_dir/.rtz-gpx-converter.XXXXXX")"; \
	trap 'rm -f "$$tmp"' EXIT; \
	install -m 755 "$(BIN)" "$$tmp"; \
	mv -f "$$tmp" "$$target"; \
	printf 'Installed %s\n' "$$target"

clean:
	rm -rf build
