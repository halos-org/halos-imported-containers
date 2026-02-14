# HaLOS Imported Containers - Development Guide

**Last Updated**: 2024-11-30

This guide covers setting up your local development environment and common development workflows for the halos-imported-containers repository.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Development Environment Setup](#development-environment-setup)
- [Repository Structure](#repository-structure)
- [Development Workflows](#development-workflows)
- [Building Packages](#building-packages)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools

**MacOS/Linux Development:**
- **Git**: Version control
- **Docker**: For running Debian build environment
- **Docker Compose**: For managing containers
- **gh** (GitHub CLI): For working with PRs and issues

**Inside Docker Container (automatic):**
- **dpkg-buildpackage**: Debian package builder (from dpkg-dev)
- **debhelper**: Debian packaging helpers
- **uv**: Python package manager
- **container-packaging-tools**: HaLOS container conversion tools
- **Python 3.11+**: Runtime for packaging tools

### Optional Tools

- **yq**: YAML validation (required for validation workflows)
- **jq**: JSON processing for GitHub API

### Installation

**MacOS:**
```bash
# Install Docker Desktop
brew install --cask docker

# Install GitHub CLI
brew install gh

# Install optional tools
brew install yq jq
```

**Linux:**
```bash
# Install Docker
# Follow: https://docs.docker.com/engine/install/

# Install GitHub CLI
# Follow: https://github.com/cli/cli/blob/trunk/docs/install_linux.md

# Install optional tools
sudo apt install yq jq  # Debian/Ubuntu
```

## Development Environment Setup

### 1. Clone the Repository

```bash
cd ~/projects  # or your preferred location
gh repo clone halos-org/halos-imported-containers
cd halos-imported-containers
```

### 2. Build Docker Environment

The repository includes a Docker-based Debian build environment that contains all necessary tools:

```bash
# Build the debtools Docker image
./run build-debtools
```

This creates a Debian Trixie (arm64/amd64) container with:
- Debian packaging tools (dpkg-dev, debhelper)
- Python 3.11+ and uv
- Build essentials and dependencies

### 3. Verify Setup

Test that everything works:

```bash
# Open shell in container
./run shell

# Inside container, verify tools are available
which dpkg-buildpackage  # Should show /usr/bin/dpkg-buildpackage
which uv                  # Should show /usr/bin/uv

# Exit container
exit
```

## Repository Structure

```
halos-imported-containers/
├── sources/                      # Source definitions
│   ├── casaos/          # CasaOS official apps
│   │   ├── apps/                 # Converted applications (147+ apps)
│   │   │   ├── uptimekuma/       # Example app
│   │   │   │   ├── metadata.yaml
│   │   │   │   ├── config.yml
│   │   │   │   └── docker-compose.yml
│   │   │   └── ...
│   │   ├── store/                # Store definition
│   │   │   ├── casaos.yaml
│   │   │   └── debian/           # Store package Debian packaging
│   │   └── upstream/
│   │       └── source.yaml       # Upstream sync configuration
│   ├── _template/                # Template for new sources
│   └── ...
│
├── tools/                        # Build and validation scripts
│   ├── build-source.sh           # Build a specific source
│   ├── build-all.sh              # Build all sources
│   └── validate-structure.sh     # Validate source structure
│
├── docker/                       # Docker build environment
│   └── docker-compose.debtools.yml
│
├── .github/
│   ├── workflows/                # Per-source CI/CD workflows
│   │   ├── pr-casaos.yml
│   │   ├── main-casaos.yml
│   │   └── release-casaos.yml
│   └── actions/                  # Reusable GitHub Actions
│       ├── build-deb/
│       └── validate-source/
│
├── docs/                         # Documentation
│   ├── SPEC.md                   # Technical specification
│   ├── ARCHITECTURE.md           # Architecture details
│   ├── IMPLEMENTATION_CHECKLIST.md
│   ├── DEVELOPMENT.md            # This file
│   └── ADDING_SOURCES.md         # Guide for adding sources
│
├── run                           # Development command runner
└── README.md
```

## Development Workflows

### Working on Existing Sources

**Common workflow for modifying existing apps or stores:**

```bash
# 1. Create a feature branch
git checkout -b feat/update-casaos

# 2. Make changes to source files
# Edit sources/casaos/apps/some-app/metadata.yaml
# or
# Edit sources/casaos/store/casaos.yaml

# 3. Validate changes
./run shell
./tools/validate-structure.sh casaos

# 4. Build packages to test
./run build-source casaos

# 5. Inspect build output
ls -lh build/

# 6. Commit and push
git add sources/casaos/
git commit -m "feat(casaos): update app metadata"
git push origin feat/update-casaos

# 7. Create PR
gh pr create --title "feat(casaos): update app metadata" --body "Description..."
```

### Testing Package Installation

**To test packages on a HaLOS system:**

```bash
# 1. Build packages locally
./run build-source casaos

# 2. Copy .deb files to test system
scp build/casaos-uptimekuma-container_*.deb pi@halos.local:/tmp/

# 3. SSH to test system
ssh pi@halos.local

# 4. Install package
sudo dpkg -i /tmp/casaos-uptimekuma-container_*.deb

# 5. Verify installation
dpkg -l | grep casaos-uptimekuma-container

# 6. Check in Cockpit UI
# Navigate to https://halos.local:9090
# Go to Applications → Container Apps
# Verify app appears in correct store
```

### Working with Templates

The `sources/_template/` directory provides a starting point for new sources:

```bash
# View template structure
tree sources/_template/

# Template files:
# - README.md.template          # Documentation template
# - apps/.gitkeep               # Apps directory placeholder
# - store/template.yaml         # Example store configuration
# - store/debian/*.template     # Debian packaging templates
# - upstream/source.yaml.example # Upstream sync config example
```

See [ADDING_SOURCES.md](./ADDING_SOURCES.md) for detailed instructions on adding new sources.

## Building Packages

### Using ./run Commands (Recommended)

The `./run` script provides convenient Docker-based builds:

```bash
# Build a specific source
./run build-source casaos

# Build all sources
./run build-all

# Open interactive shell for debugging
./run shell

# Clean build artifacts
./run clean
```

### Direct Script Usage (Advanced)

For development without Docker:

**Prerequisites on Debian/Ubuntu:**
```bash
# Install Debian packaging tools
sudo apt install dpkg-dev debhelper

# Install container-packaging-tools
uv tool install git+https://github.com/halos-org/container-packaging-tools.git
export PATH="$HOME/.local/bin:$PATH"
```

**Build commands:**
```bash
# Validate structure
./tools/validate-structure.sh casaos

# Build a specific source
./tools/build-source.sh casaos

# Build all sources
./tools/build-all.sh
```

**Note**: On MacOS, `dpkg-buildpackage` is not available, so use the Docker-based `./run` commands instead.

### Build Output

Successful builds create:

```
build/
├── casaos-container-store_0.1.0_all.deb
├── casaos-uptimekuma-container_1.23.0_all.deb
├── casaos-jellyfin-container_10.8.13_all.deb
└── ... (147+ app packages for casaos)
```

## Testing

### Local Validation

```bash
# Validate all sources
./tools/validate-structure.sh

# Validate specific source
./tools/validate-structure.sh casaos

# Check YAML syntax (requires yq)
yq eval . sources/casaos/store/casaos.yaml
yq eval . sources/casaos/upstream/source.yaml
```

### CI/CD Testing

Pull requests automatically trigger:

1. **Validation**: Structure and schema validation
2. **Build**: Package building in Debian environment
3. **Reporting**: PR comment with build results

```bash
# Create PR and watch CI
gh pr create --title "test: validate build" --body "Testing changes"
gh pr checks --watch

# View PR build output
gh pr view --web
```

### Manual Package Testing

```bash
# Build package
./run build-source casaos

# Extract package contents to inspect
dpkg-deb -x build/casaos-uptimekuma-container_*.deb /tmp/test-pkg/
tree /tmp/test-pkg/

# View package metadata
dpkg-deb -I build/casaos-uptimekuma-container_*.deb

# Test package installation in Docker
docker run --rm -v $(pwd)/build:/packages debian:trixie bash -c \
  "apt update && apt install -y /packages/casaos-uptimekuma-container_*.deb"
```

## Troubleshooting

### Docker Issues

**Problem**: `./run build-debtools` fails with "docker: command not found"

**Solution**:
```bash
# Install Docker Desktop (MacOS)
brew install --cask docker

# Start Docker Desktop and verify
docker ps
```

**Problem**: "Cannot connect to Docker daemon"

**Solution**:
```bash
# MacOS: Start Docker Desktop app
# Linux: Start Docker service
sudo systemctl start docker
```

### Build Issues

**Problem**: `generate-container-packages: command not found` in Docker

**Solution**: The tool is installed automatically by `./run build-source`. If manual installation needed:
```bash
./run shell
uv tool install git+https://github.com/halos-org/container-packaging-tools.git
export PATH="$HOME/.local/bin:$PATH"
```

**Problem**: Build succeeds but no .deb files in build/

**Solution**:
```bash
# Check for errors in build output
./run build-source casaos 2>&1 | grep -i error

# Verify source structure
./tools/validate-structure.sh casaos

# Check store debian/ directory exists
ls -la sources/casaos/store/debian/
```

**Problem**: "dpkg-buildpackage: error: fakeroot not found"

**Solution**: Rebuild Docker image:
```bash
./run build-debtools
```

### Package Installation Issues

**Problem**: Package installs but app doesn't appear in Cockpit

**Solution**:
```bash
# Verify store package is installed
dpkg -l | grep container-store

# Check store definition was installed
ls -la /usr/share/container-stores/

# Restart Cockpit
sudo systemctl restart cockpit
```

**Problem**: "dependency problems" when installing package

**Solution**:
```bash
# Install dependencies first
sudo apt install -f

# Or install docker.io explicitly
sudo apt install docker.io

# Then retry package installation
sudo dpkg -i /path/to/package.deb
```

### Git/GitHub Issues

**Problem**: "gh: command not found"

**Solution**:
```bash
# MacOS
brew install gh

# Debian/Ubuntu
# See: https://github.com/cli/cli/blob/trunk/docs/install_linux.md

# Authenticate
gh auth login
```

**Problem**: CI checks not running on PR

**Solution**:
```bash
# Verify path filters - workflows only trigger on relevant changes
# For casaos, modify files in:
#   - sources/casaos/**
#   - tools/**
#   - .github/workflows/*casaos.yml

# Force CI by modifying a watched path
touch sources/casaos/README.md
git add sources/casaos/README.md
git commit -m "chore: trigger CI"
git push
```

## Best Practices

### Code Organization

1. **One source per PR**: Keep changes focused on a single source
2. **Atomic commits**: Each commit should be a complete, logical change
3. **Meaningful messages**: Follow conventional commit format
4. **Validate early**: Run validation before committing

### Testing

1. **Local first**: Test builds locally before pushing
2. **CI validation**: Wait for CI checks before merging
3. **Integration testing**: Test package installation on HaLOS system
4. **Incremental testing**: Test each step of the workflow

### Documentation

1. **Update docs**: Keep documentation synchronized with code
2. **Comment complex logic**: Explain non-obvious decisions
3. **Link to issues**: Reference GitHub issues in commits
4. **Examples**: Provide working examples in docs

## Related Documentation

- **[SPEC.md](./SPEC.md)**: Technical specification and requirements
- **[ARCHITECTURE.md](./ARCHITECTURE.md)**: System architecture and design
- **[ADDING_SOURCES.md](./ADDING_SOURCES.md)**: Guide for adding new sources
- **[IMPLEMENTATION_CHECKLIST.md](./IMPLEMENTATION_CHECKLIST.md)**: Implementation guidelines
- **[README.md](../README.md)**: Project overview

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/halos-org/halos-imported-containers/issues)
- **Discussions**: GitHub Discussions (for questions and ideas)
- **HaLOS Docs**: [HaLOS Development](https://github.com/halos-org/halos-distro)

## Contributing

See the main [README.md](../README.md) for contribution guidelines and the [IMPLEMENTATION_CHECKLIST.md](./IMPLEMENTATION_CHECKLIST.md) for required implementation steps.
