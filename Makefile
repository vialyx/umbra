.PHONY: build clean run install test release

# Build configuration
PRODUCT_NAME = Umbra
BUILD_DIR = build
RELEASE_DIR = release
SWIFT_BUILD_FLAGS = -c release --arch arm64 --arch x86_64

# Build the application
build:
	@echo "Building $(PRODUCT_NAME)..."
	@swift build $(SWIFT_BUILD_FLAGS)
	@echo "✓ Build complete"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf .build
	@rm -rf $(BUILD_DIR)
	@rm -rf $(RELEASE_DIR)
	@echo "✓ Clean complete"

# Run the application in debug mode
run:
	@echo "Running $(PRODUCT_NAME)..."
	@swift run

# Build and run
dev: build run

# Run tests
test:
	@echo "Running tests..."
	@swift test

# Build installer
installer: build
	@echo "Building installer..."
	@chmod +x Installer/build-installer.sh
	@./Installer/build-installer.sh
	@echo "✓ Installer created in $(RELEASE_DIR)/"

# Install locally
install: build
	@echo "Installing $(PRODUCT_NAME) locally..."
	@mkdir -p $(BUILD_DIR)/$(PRODUCT_NAME).app/Contents/MacOS
	@mkdir -p $(BUILD_DIR)/$(PRODUCT_NAME).app/Contents/Resources
	@cp .build/release/$(PRODUCT_NAME) $(BUILD_DIR)/$(PRODUCT_NAME).app/Contents/MacOS/
	@cp Info.plist $(BUILD_DIR)/$(PRODUCT_NAME).app/Contents/
	@cp -r $(BUILD_DIR)/$(PRODUCT_NAME).app /Applications/
	@echo "✓ Installed to /Applications/$(PRODUCT_NAME).app"

# Format code
format:
	@echo "Formatting code..."
	@swift-format format -i -r Sources/
	@echo "✓ Format complete"

# Lint code
lint:
	@echo "Linting code..."
	@swift-format lint -r Sources/
	@echo "✓ Lint complete"

# Create Xcode project
xcode:
	@echo "Generating Xcode project..."
	@swift package generate-xcodeproj
	@echo "✓ Xcode project created"

# Full release build
release: clean build installer
	@echo "✓ Release build complete!"
	@echo "Installer: $(RELEASE_DIR)/$(PRODUCT_NAME)-*.pkg"

# Help
help:
	@echo "Umbra Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  build      - Build the application"
	@echo "  clean      - Remove build artifacts"
	@echo "  run        - Run in debug mode"
	@echo "  dev        - Build and run"
	@echo "  test       - Run tests"
	@echo "  installer  - Build PKG installer"
	@echo "  install    - Install locally to /Applications"
	@echo "  format     - Format code with swift-format"
	@echo "  lint       - Lint code"
	@echo "  xcode      - Generate Xcode project"
	@echo "  release    - Full release build"
	@echo "  help       - Show this help"
