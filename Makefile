SWIFT ?= swift
CLI := fp-progress
PACKAGE_PATH := native
INTERVAL ?= 10

.PHONY: help build test clean list status status-json watch watch-json

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

clean:
	$(SWIFT) package --package-path $(PACKAGE_PATH) clean
