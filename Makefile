SWIFT ?= swift
NPM ?= npm
CLI := fp-progress
PACKAGE_PATH := native
RAYCAST_PATH := raycast
INTERVAL ?= 10

.PHONY: help build test clean list status status-json watch watch-json raycast-install raycast-dev raycast-check raycast-sync-native raycast-verify-native raycast-bundle-swift-debug raycast-bundle-swift raycast-build raycast-lint raycast-store-lint raycast-typecheck raycast-publish

help:
	@printf "Important targets:\n"
	@printf "  make test             Run Swift tests\n"
	@printf "  make status           Show current File Provider progress\n"
	@printf "  make raycast-dev      Build ignored debug helper and open Raycast dev mode\n"
	@printf "  make raycast-check    Build the Store bundle and run Raycast/ESLint/TypeScript checks\n"
	@printf "  make raycast-publish  Build, validate, and publish the Raycast extension\n"
	@printf "\n"
	@printf "Useful CLI targets:\n"
	@printf "  make build            Build the Swift package\n"
	@printf "  make list             List discovered File Provider domains\n"
	@printf "  make status-json      Show current progress status as JSON\n"
	@printf "  make watch            Watch progress, waiting INTERVAL seconds between polls\n"
	@printf "  make watch-json       Watch JSON progress, waiting INTERVAL seconds between polls\n"
	@printf "                       Example: make watch INTERVAL=30\n"
	@printf "\n"
	@printf "Raycast helper targets:\n"
	@printf "  make raycast-install       Install Raycast extension dependencies\n"
	@printf "  make raycast-build         Sync native source, bundle release helper, and build extension\n"
	@printf "  make raycast-lint          Run Raycast lint, ESLint, and TypeScript checks\n"
	@printf "  make raycast-sync-native   Mirror native/ into ignored raycast/native/ for Store packaging\n"
	@printf "  make raycast-verify-native Verify raycast/native/ matches native/\n"
	@printf "\n"
	@printf "Low-level/debug targets:\n"
	@printf "  make raycast-bundle-swift-debug  Bundle debug Swift helper\n"
	@printf "  make raycast-bundle-swift        Bundle release Swift helper\n"
	@printf "  make raycast-store-lint          Run strict Raycast Store metadata lint\n"
	@printf "  make raycast-typecheck           Run Raycast TypeScript checks only\n"
	@printf "  make clean                       Remove SwiftPM and Raycast Swift build artifacts\n"

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

raycast-dev:
	cd $(RAYCAST_PATH) && $(NPM) run dev

raycast-sync-native:
	cd $(RAYCAST_PATH) && $(NPM) run sync-native

raycast-verify-native:
	cd $(RAYCAST_PATH) && $(NPM) run verify-native

raycast-bundle-swift-debug: raycast-sync-native
	cd $(RAYCAST_PATH) && $(NPM) run package-swift -- debug

raycast-bundle-swift: raycast-sync-native
	cd $(RAYCAST_PATH) && $(NPM) run package-swift -- release

raycast-build: raycast-bundle-swift
	cd $(RAYCAST_PATH) && $(NPM) run build

raycast-lint:
	cd $(RAYCAST_PATH) && $(NPM) run lint

raycast-check: raycast-build raycast-lint

raycast-store-lint:
	cd $(RAYCAST_PATH) && $(NPM) run lint:store

raycast-typecheck:
	cd $(RAYCAST_PATH) && $(NPM) run typecheck

raycast-publish:
	cd $(RAYCAST_PATH) && $(NPM) run publish

clean:
	$(SWIFT) package --package-path $(PACKAGE_PATH) clean
	rm -rf $(RAYCAST_PATH)/.raycast-swift-build
