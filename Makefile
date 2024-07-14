# Makefile to setup and run a Python script with virtual environment

.PHONY: all setup venv requirements download_firmware extract_firmware run clean

# Define the base directory for build artifacts
BUILD_DIR := build
VENV_DIR := $(BUILD_DIR)/venv
DOWNLOAD_FW_SCRIPT := scripts/get-dirigera-fw-versions.py

# Firmware image directory
IMAGE_DIR := $(BUILD_DIR)/fw

# Default target
all: setup download_firmware extract_firmware 

# Setup the virtual environment and install dependencies
setup: venv requirements

# Create virtual environment if it does not exist
venv:
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "Creating virtual environment..."; \
		python3 -m venv $(VENV_DIR); \
		echo "Virtual environment created at $(VENV_DIR)"; \
	else \
		echo "Virtual environment already exists at $(VENV_DIR)"; \
	fi

# Install dependencies from requirements.txt
requirements:
	@echo "Installing dependencies..."
	@$(VENV_DIR)/bin/pip install -r requirements.txt
	@echo "Dependencies installed."

# Download firmware using the Python script
download_firmware: setup
	@echo "Running the firmware download script..."
	@mkdir -p $(IMAGE_DIR)
	@$(VENV_DIR)/bin/python $(DOWNLOAD_FW_SCRIPT) --output-dir $(IMAGE_DIR)

# Extract firmware images recursively, including handling .ext4 files by extracting their contents using debugfs
extract_firmware: download_firmware
	@echo "Extracting firmware images..."
	@for image in $(IMAGE_DIR)/*.raucb; do \
		base_name=$$(basename $$image .raucb); \
		extract_dir=$(BUILD_DIR)/fw-extract/$$base_name/images; \
		if [ -d "$$extract_dir" ]; then \
			echo "Directory $$extract_dir already exists, skipping extraction."; \
			continue; \
		fi; \
		mkdir -p $$extract_dir; \
		unsquashfs -f -d $$extract_dir $$image; \
		echo "Extracted $$image to $$extract_dir"; \
		# Handle nested squashfs and .ext4 files \
		find $$extract_dir -type f \( -name '*.squashfs' -o -name '*.squashfs.verity' \) -exec sh -c ' \
			file="{}"; \
			base=$$(basename "$$file" .squashfs); \
			base=$$(basename "$$base" .verity); \
			base=$$(echo "$$base" | sed "s/\.squashfs$$//"); \
			block_dir=$(BUILD_DIR)/fw-extract/'"$$base_name"'/blocks/$$base; \
			mkdir -p "$$block_dir"; \
			unsquashfs -f -d "$$block_dir" "$$file"; \
			echo "Extracted nested $$file to $$block_dir"; \
			rm -f "$$file"; \
		' \; ; \
		# Extract contents of ext4 files into blocks directory using debugfs \
		find $$extract_dir -type f -name '*.ext4' -exec sh -c ' \
			file="{}"; \
			base=$$(basename "$$file" .ext4); \
			ext4_dir=$(BUILD_DIR)/fw-extract/'"$$base_name"'/blocks/$$base; \
			mkdir -p "$$ext4_dir"; \
			debugfs -R "rdump / $$ext4_dir" $$file; \
			echo "Extracted contents of $$file to $$ext4_dir"; \
		' \; ; \
		echo && echo; \
		echo "!!! Please check $(BUILD_DIR)/fw-extract/$$base_name/blocks to inspect the extracted firmware blocks"; \
	done
	@echo "All firmware images processed and organized."

# Clean the build directory
clean:
	@echo "Cleaning up..."
	@rm -rf $(BUILD_DIR)
	@echo "Cleaned."


