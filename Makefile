BIN := build/rtz-gpx-converter
SOURCE := Sources/RTZGPXPrototype.swift

.PHONY: build test clean

build: $(BIN)

$(BIN): $(SOURCE)
	@mkdir -p build
	swiftc -O $(SOURCE) -o $(BIN)

test: $(BIN)
	bash ./tests/prototype/test-converter.sh ./$(BIN)

clean:
	rm -rf build
