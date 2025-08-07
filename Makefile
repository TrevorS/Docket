# Docket - CLI-driven Swift macOS app development
.PHONY: build run test clean app install format lint xcode help

# Default target
.DEFAULT_GOAL := help

# Core development commands
build: ## Build the application in debug mode
	swift build

run: ## Run the application
	swift run Docket

test: ## Run all tests
	swift test

clean: ## Clean build artifacts
	swift package clean

# Distribution
app: ## Create a macOS .app bundle for distribution
	@echo "Building Docket.app bundle..."
	@swift build --configuration release
	@mkdir -p build/Docket.app/Contents/MacOS
	@mkdir -p build/Docket.app/Contents/Resources
	@cp .build/release/Docket build/Docket.app/Contents/MacOS/
	@cp Sources/DocketApp/Resources/Info.plist build/Docket.app/Contents/
	@cp Sources/DocketApp/Resources/Docket.entitlements build/Docket.app/Contents/Resources/
	@if [ -d Sources/DocketApp/Resources/Assets.xcassets ]; then \
		cp -r Sources/DocketApp/Resources/Assets.xcassets build/Docket.app/Contents/Resources/; \
	fi
	@echo "✅ Docket.app created in build/ directory"

install: app ## Install app to /Applications
	@rm -rf /Applications/Docket.app
	@cp -r build/Docket.app /Applications/
	@echo "✅ Docket installed to /Applications"

# Code quality
format: ## Format Swift code with swift-format
	@if command -v swift-format >/dev/null 2>&1; then \
		find Sources Tests -name "*.swift" -exec swift-format --in-place {} \; ; \
		echo "✅ Code formatted"; \
	else \
		echo "⚠️  swift-format not found. Install with: brew install swift-format"; \
	fi

lint: ## Lint code using Swift compiler warnings
	@echo "🔍 Linting with Swift compiler..."
	@swift build -Xswiftc -warnings-as-errors -Xswiftc -strict-concurrency=complete

# Development tools
xcode: ## Generate Xcode project for GUI development
	swift package generate-xcodeproj
	@echo "✅ Generated Docket.xcodeproj"

# Help
help: ## Show this help message
	@echo "Docket - CLI Development Commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'