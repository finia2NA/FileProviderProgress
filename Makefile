SWIFT ?= swift
NPM ?= npm
CLI := fp-progress
PACKAGE_PATH := native
RAYCAST_PATH := raycast
INTERVAL ?= 10

.PHONY: help build test clean list status status-json watch watch-json raycast-install raycast-dev raycast-bundle-swift-debug raycast-bundle-swift raycast-build raycast-lint raycast-store-lint raycast-typecheck

help:
	@printf "Targets:\n"
	@printf "  make build        Build the Swift package\n"
	@printf "  make test         Run automated tests\n"
	@printf "  make list         List discovered File Provider domains\n"
	@printf "  make status       Show current progress status\n"
	@printf "  make status-json  Show current progress status as JSON\n"
	@printf "  make watch        Watch current progress status, waiting INTERVAL seconds between polls\n"
	@printf "  make watch-json   Watch current progress status as JSON, waiting INTERVAL seconds between polls\n"
	@printf "                   Example: make watch INTERVAL=30\n"
	@printf "  make raycast-install      Install Raycast extension dependencies\n"
	@printf "  make raycast-dev          Bundle Swift debug CLI and run Raycast development mode\n"
	@printf "  make raycast-bundle-swift-debug Build Swift debug CLI and copy it into raycast/assets/bin\n"
	@printf "  make raycast-bundle-swift Build Swift release CLI and copy it into raycast/assets/bin\n"
	@printf "  make raycast-build        Bundle Swift release CLI and build the Raycast extension\n"
	@printf "  make raycast-lint         Run local Raycast extension lint\n"
	@printf "  make raycast-store-lint   Run strict Raycast Store metadata lint\n"
	@printf "  make raycast-typecheck    Run Raycast extension TypeScript checks\n"
	@printf "  make clean        Remove SwiftPM build artifacts\n"

build:
	$(SWIFT) build --package-path $(PACKAGE_PATH)

test:
	$(SWIFT) test --package-path $(PACKAGE_PATH)

list:
	$(SWIFT) run --package-path $(PACKAGE_PATH) $(CLI) list

status:
	$(SWIFT) run --package-path $(PACKAGE_PATH) $(CLI) status

status-json:
	$(SWIFT) run --package-path $(PACKAGE_PATH) $(CLI) status --json

watch:
	$(SWIFT) run --package-path $(PACKAGE_PATH) $(CLI) watch --interval $(INTERVAL)

watch-json:
	$(SWIFT) run --package-path $(PACKAGE_PATH) $(CLI) watch --json --interval $(INTERVAL)

raycast-install:
	cd $(RAYCAST_PATH) && $(NPM) install

raycast-dev: raycast-bundle-swift-debug
	cd $(RAYCAST_PATH) && $(NPM) run dev

raycast-bundle-swift-debug:
	cd $(RAYCAST_PATH) && $(NPM) run package-swift -- debug

raycast-bundle-swift:
	cd $(RAYCAST_PATH) && $(NPM) run package-swift -- release

raycast-build: raycast-bundle-swift
	cd $(RAYCAST_PATH) && $(NPM) run build

raycast-lint:
	cd $(RAYCAST_PATH) && $(NPM) run lint

raycast-store-lint:
	cd $(RAYCAST_PATH) && $(NPM) run lint:store

raycast-typecheck:
	cd $(RAYCAST_PATH) && $(NPM) run typecheck

clean:
	$(SWIFT) package --package-path $(PACKAGE_PATH) clean
