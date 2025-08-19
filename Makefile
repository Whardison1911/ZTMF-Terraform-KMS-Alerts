# Terraform KMS Alerts - Makefile
# Educational repository for KMS monitoring with Terraform

# === Platform Detection ===
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    ifdef MSYSTEM
        # Git Bash/MinGW environment
        SHELL := /bin/bash
        NULL_DEVICE := /dev/null
        ECHO := echo
        IN_GIT_BASH := true
    else
        # Native Windows environment
        SHELL := cmd.exe
        NULL_DEVICE := NUL
        ECHO := echo
        IN_GIT_BASH := false
    endif
else
    # Unix/Linux/Mac
    DETECTED_OS := $(shell uname -s)
    SHELL := /bin/sh
    NULL_DEVICE := /dev/null
    ECHO := echo
    IN_GIT_BASH := false
endif

# === Tool Variables ===
TF := terraform
TFLINT := tflint
TFSEC := tfsec
CHECKOV := checkov
GITLEAKS := gitleaks

# === Helper Functions ===
define check_tool
	@command -v $(1) >$(NULL_DEVICE) 2>&1 || ($(ECHO) "Error: $(1) is not installed. Run 'make install' for instructions." && exit 1)
endef

.PHONY: help fmt validate lint security test clean

# Default target
help:
	@$(ECHO) "Terraform KMS Alerts - Available Commands"
	@$(ECHO) "Platform: $(DETECTED_OS)"
ifeq ($(IN_GIT_BASH),true)
	@$(ECHO) "Environment: Git Bash/MinGW"
endif
	@$(ECHO) ""
	@$(ECHO) "Format & Validate:"
	@$(ECHO) "  make fmt       - Format all Terraform files"
	@$(ECHO) "  make validate  - Validate Terraform syntax"
	@$(ECHO) "  make lint      - Run TFLint (if installed)"
	@$(ECHO) ""
	@$(ECHO) "Security:"
	@$(ECHO) "  make security  - Run security scans"
	@$(ECHO) "  make secrets   - Scan for hardcoded secrets"
	@$(ECHO) ""
	@$(ECHO) "Testing:"
	@$(ECHO) "  make test      - Run all quality checks"
	@$(ECHO) ""
	@$(ECHO) "Tools:"
	@$(ECHO) "  make tools     - Check installed tools"
	@$(ECHO) "  make install   - Show tool installation guide"
	@$(ECHO) ""
	@$(ECHO) "Other:"
	@$(ECHO) "  make clean     - Clean temporary files"

# Format Terraform files
fmt:
	$(call check_tool,$(TF))
	@$(ECHO) "Formatting Terraform files..."
	@$(TF) fmt -recursive

# Validate Terraform configuration
validate:
	$(call check_tool,$(TF))
	@$(ECHO) "Validating Terraform configuration..."
	@$(TF) init -backend=false
	@$(TF) validate

# Lint with TFLint
lint:
	@if command -v $(TFLINT) >$(NULL_DEVICE) 2>&1; then \
		$(ECHO) "Running TFLint..."; \
		$(TFLINT) --init 2>$(NULL_DEVICE) || true; \
		$(TFLINT); \
	else \
		$(ECHO) "TFLint not installed. Run 'make install' for instructions."; \
	fi

# Security scanning
security:
	@$(ECHO) "Running security scans..."
	@if command -v $(TFSEC) >$(NULL_DEVICE) 2>&1; then \
		$(ECHO) "Running tfsec..."; \
		$(TFSEC) . --no-color; \
	else \
		$(ECHO) "tfsec not installed."; \
	fi
	@if command -v $(CHECKOV) >$(NULL_DEVICE) 2>&1; then \
		$(ECHO) "Running Checkov..."; \
		$(CHECKOV) -d . --quiet --compact; \
	else \
		$(ECHO) "Checkov not installed."; \
	fi

# Scan for secrets
secrets:
	@if command -v $(GITLEAKS) >$(NULL_DEVICE) 2>&1; then \
		$(ECHO) "Scanning for secrets..."; \
		$(GITLEAKS) detect -v; \
	else \
		$(ECHO) "gitleaks not installed. Run 'make install' for instructions."; \
	fi

# Run all tests
test: fmt validate lint security
	@$(ECHO) "All checks completed!"

# Check installed tools
tools:
	@$(ECHO) "Checking installed tools..."
	@$(ECHO) ""
	@command -v $(TF) >$(NULL_DEVICE) 2>&1 && $(ECHO) "✓ terraform" || $(ECHO) "✗ terraform"
	@command -v $(TFLINT) >$(NULL_DEVICE) 2>&1 && $(ECHO) "✓ tflint" || $(ECHO) "✗ tflint"
	@command -v $(TFSEC) >$(NULL_DEVICE) 2>&1 && $(ECHO) "✓ tfsec" || $(ECHO) "✗ tfsec"
	@command -v $(CHECKOV) >$(NULL_DEVICE) 2>&1 && $(ECHO) "✓ checkov" || $(ECHO) "✗ checkov"
	@command -v $(GITLEAKS) >$(NULL_DEVICE) 2>&1 && $(ECHO) "✓ gitleaks" || $(ECHO) "✗ gitleaks"

# Installation guide
install:
	@$(ECHO) "Tool Installation Guide"
	@$(ECHO) "Platform: $(DETECTED_OS)"
	@$(ECHO) ""
	@$(ECHO) "macOS/Linux (Homebrew):"
	@$(ECHO) "  brew install terraform tflint tfsec gitleaks"
	@$(ECHO) "  pip install checkov"
	@$(ECHO) ""
	@$(ECHO) "Windows (Chocolatey):"
	@$(ECHO) "  choco install terraform tflint"
	@$(ECHO) "  pip install checkov"
	@$(ECHO) ""
	@$(ECHO) "Docker alternative:"
	@$(ECHO) "  docker run --rm -v \$$(pwd):/src -w /src hashicorp/terraform:latest"

# Clean temporary files
clean:
	@$(ECHO) "Cleaning temporary files..."
ifeq ($(OS),Windows_NT)
ifeq ($(IN_GIT_BASH),false)
	@if exist .terraform rmdir /S /Q .terraform 2>$(NULL_DEVICE)
	@if exist .terraform.lock.hcl del /F /Q .terraform.lock.hcl 2>$(NULL_DEVICE)
	@del /F /Q *.tfplan 2>$(NULL_DEVICE) || true
else
	@rm -rf .terraform .terraform.lock.hcl *.tfplan 2>$(NULL_DEVICE) || true
endif
else
	@rm -rf .terraform .terraform.lock.hcl *.tfplan 2>$(NULL_DEVICE) || true
endif
	@$(ECHO) "Clean complete!"