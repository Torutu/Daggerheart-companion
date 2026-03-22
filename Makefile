# =============================================================================
#  Daggerheart Companion — Makefile
#  Flutter path may contain spaces, so we quote it throughout.
# =============================================================================

FLUTTER := "D:\Flutter SDK\flutter\bin\flutter.bat"

# Default target
.DEFAULT_GOAL := help

# =============================================================================
#  HELP
# =============================================================================
.PHONY: help
help:
	@echo.
	@echo  Daggerheart Companion — available targets:
	@echo.
	@echo  Setup
	@echo    make get          flutter pub get
	@echo    make clean        flutter clean
	@echo    make clean-get    clean then pub get
	@echo.
	@echo  Run
	@echo    make web          run on web-server (localhost:8080)
	@echo    make windows      run as Windows desktop app
	@echo    make edge         run in Microsoft Edge
	@echo.
	@echo  Build
	@echo    make build-web    release build for web
	@echo    make build-win    release build for Windows
	@echo.
	@echo  Quality
	@echo    make analyze      flutter analyze
	@echo    make test         flutter test
	@echo    make format       dart format lib/
	@echo    make check        analyze + test
	@echo.

# =============================================================================
#  SETUP
# =============================================================================
.PHONY: get
get:
	$(FLUTTER) pub get

.PHONY: clean
clean:
	$(FLUTTER) clean

.PHONY: clean-get
clean-get: clean get

# =============================================================================
#  RUN
# =============================================================================
.PHONY: web
web:
	$(FLUTTER) run -d web-server --web-port 8080 --web-hostname localhost

.PHONY: windows
windows:
	$(FLUTTER) run -d windows

.PHONY: edge
edge:
	$(FLUTTER) run -d edge

# =============================================================================
#  BUILD
# =============================================================================
.PHONY: build-web
build-web:
	$(FLUTTER) build web --release

.PHONY: build-win
build-win:
	$(FLUTTER) build windows --release

# =============================================================================
#  QUALITY
# =============================================================================
.PHONY: analyze
analyze:
	$(FLUTTER) analyze

.PHONY: test
test:
	$(FLUTTER) test

.PHONY: format
format:
	$(FLUTTER) dart format lib/

.PHONY: check
check: analyze test
