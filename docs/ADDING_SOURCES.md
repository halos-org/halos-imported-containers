# Adding New Container Sources

**Last Updated**: 2025-11-29

This guide provides step-by-step instructions for adding new upstream container app stores to the halos-imported-containers repository.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Step-by-Step Process](#step-by-step-process)
- [Configuration Details](#configuration-details)
- [Testing Your Source](#testing-your-source)
- [Troubleshooting](#troubleshooting)
- [Examples](#examples)

## Overview

Each source in this repository represents an upstream container app store (like CasaOS, Runtipi, etc.). Adding a new source involves:

1. Creating the source directory structure
2. Configuring upstream sync settings
3. Creating the store definition
4. Setting up Debian packaging
5. Creating CI/CD workflows
6. Running the converter to populate apps
7. Testing and validation

**Time Estimate**: 2-4 hours for a new source with existing converter support

**Note**: This guide uses generic examples (like `newsource`, `runtipi`) as placeholders. For actual working implementations, refer to `sources/casaos/` as the reference.

## Prerequisites

### Required Knowledge

- Basic understanding of Debian packaging
- Familiarity with YAML configuration files
- Understanding of GitHub Actions workflows
- Knowledge of the upstream source format you're converting

### Required Tools

- Git and GitHub CLI (`gh`)
- Docker and Docker Compose (for builds)
- Text editor
- Access to the halos-imported-containers repository

### Converter Availability

Before adding a source, verify that `container-packaging-tools` supports the upstream format:

**Currently Supported:**
- **CasaOS**: CasaOS App Store v2.0 format

**Custom Converters:**
If your upstream format isn't supported, you'll need to implement a converter in the [container-packaging-tools](https://github.com/halos-org/container-packaging-tools) repository first. See the CasaOS converter as a reference implementation.

## Step-by-Step Process

### Step 1: Copy Template Directory

Start by copying the template to create your new source:

```bash
# Navigate to repository root
cd halos-imported-containers

# Copy template (replace 'newsource' with your source name)
# Use lowercase, hyphens only (e.g., 'runtipi', 'casaos-community')
cp -r sources/_template sources/newsource

# Example: Adding Runtipi
cp -r sources/_template sources/runtipi
```

**Naming Convention:**
- Use lowercase letters only
- Use hyphens for word separation (not underscores)
- Make it descriptive but concise
- Examples: `casaos`, `runtipi`, `casaos-community`

### Step 2: Configure Upstream Source

Edit `sources/newsource/upstream/source.yaml`:

```bash
# Remove the .example extension
mv sources/newsource/upstream/source.yaml.example sources/newsource/upstream/source.yaml

# Edit the configuration
vim sources/newsource/upstream/source.yaml
```

**Key fields to configure** (example values - replace with your actual source):

```yaml
# Source identification (must match directory name)
source_id: newsource  # MUST match your directory name
source_name: "New Source"  # Display name
source_description: "Description of your source"

# Upstream repository (configure based on your upstream)
upstream:
  type: github  # github, gitlab, http, or git
  repository: "owner/repo"  # For GitHub: owner/repo format
  branch: "main"  # Branch to track
  path: "apps"  # Path to apps within repo (blank if root)

# Converter settings (must use implemented converter)
converter:
  type: casaos  # Currently only 'casaos' is implemented
  version: "2.0"  # CasaOS manifest version
  options:
    package_prefix: newsource  # Used in package names
    use_fallbacks: true
    validation_mode: "warn"

# Package defaults (standard for all sources)
defaults:
  origin: "Hat Labs"
  maintainer: "Hat Labs <info@hatlabs.fi>"
  section: "admin"
  priority: "optional"
```

**Important**: Currently only the `casaos` converter is implemented. You must either use CasaOS-compatible upstream data or implement a custom converter first.

See the [template file](../sources/_template/upstream/source.yaml.example) for detailed field descriptions.

### Step 3: Create Store Definition

Edit `sources/newsource/store/newsource.yaml`:

```bash
# Copy template and rename
cp sources/newsource/store/template.yaml sources/newsource/store/runtipi.yaml

# Edit store configuration
vim sources/newsource/store/runtipi.yaml
```

**Key configuration:**

```yaml
# Store identification (must match directory name)
id: runtipi

# Display name in Cockpit UI
name: Runtipi

# Markdown description
description: |
  Applications from the Runtipi community app store.

  Runtipi provides a curated collection of self-hosted applications
  with easy installation and management.

# Icon path (will be installed to this location)
icon: /usr/share/container-stores/runtipi/icon.svg

# Package filters
filters:
  include_origins:
    - "Hat Labs"
  include_patterns:
    - "runtipi-*-container"  # Must match your package_prefix

# Category definitions
category_metadata:
  - id: media
    label: Media & Entertainment
    icon: PlayCircleIcon
    description: Media servers and streaming applications

  # Add more categories based on your source's app types
```

**Important:** The `include_patterns` must match the `package_prefix` you set in `upstream/source.yaml`.

### Step 4: Add Store Branding (Optional)

Add an icon for your store:

```bash
# Add SVG icon (256x256 recommended)
cp /path/to/icon.svg sources/newsource/store/icon.svg

# Optional: Add banner image
cp /path/to/banner.svg sources/newsource/store/banner.svg
```

### Step 5: Configure Debian Packaging

Create Debian packaging files for the store package:

```bash
# Create debian directory
mkdir -p sources/newsource/store/debian
```

#### 5.1: Create `control` file

Create `sources/newsource/store/debian/control`:

```debian
Source: runtipi-container-store
Section: admin
Priority: optional
Maintainer: Hat Labs <info@hatlabs.fi>
Build-Depends: debhelper-compat (= 13)
Standards-Version: 4.6.2

Package: runtipi-container-store
Architecture: all
Depends: ${misc:Depends}
Description: Runtipi container application store
 Container application store definition for Runtipi apps.
 .
 This package provides the store configuration that enables
 Runtipi applications to appear in the HaLOS Cockpit container
 management interface.
```

#### 5.2: Create `rules` file

Create `sources/newsource/store/debian/rules`:

```makefile
#!/usr/bin/make -f

%:
	dh $@

override_dh_auto_install:
	# Install store definition
	install -D -m 0644 runtipi.yaml debian/runtipi-container-store/usr/share/container-stores/runtipi.yaml

	# Install icon
	install -D -m 0644 icon.svg debian/runtipi-container-store/usr/share/container-stores/runtipi/icon.svg

# Skip these steps for store packages (no binaries)
override_dh_auto_build:
override_dh_auto_test:
override_dh_strip:
override_dh_shlibdeps:
```

Make it executable:
```bash
chmod +x sources/newsource/store/debian/rules
```

#### 5.3: Create `changelog` file

Create `sources/newsource/store/debian/changelog`:

```
runtipi-container-store (0.1.0) trixie; urgency=medium

  * Initial release
  * Add Runtipi store definition
  * Configure package filters for runtipi-*-container packages

 -- Hat Labs <info@hatlabs.fi>  Fri, 29 Nov 2024 12:00:00 +0000
```

#### 5.4: Create `copyright` file

Create `sources/newsource/store/debian/copyright`:

```
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: runtipi-container-store
Source: https://github.com/halos-org/halos-imported-containers

Files: *
Copyright: 2024 Hat Labs
License: MIT

License: MIT
 Permission is hereby granted, free of charge, to any person obtaining a
 copy of this software and associated documentation files (the "Software"),
 to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:
 .
 The above copyright notice and this permission notice shall be included
 in all copies or substantial portions of the Software.
 .
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
```

### Step 6: Create GitHub Workflows

Create three workflow files in `.github/workflows/`:

#### 6.1: PR Workflow

Create `.github/workflows/pr-runtipi.yml`:

```yaml
name: PR - Runtipi

on:
  pull_request:
    paths:
      - 'sources/runtipi/**'
      - 'tools/**'
      - '.github/actions/**'
      - '.github/workflows/**runtipi.yml'

permissions:
  contents: read
  pull-requests: write

jobs:
  validate:
    name: Validate Runtipi
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Validate source structure
        uses: ./.github/actions/validate-source
        with:
          source: runtipi

  build:
    name: Build Runtipi Packages
    runs-on: ubuntu-latest
    needs: validate
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Build packages
        id: build
        uses: ./.github/actions/build-deb
        with:
          source: runtipi

      - name: Comment on PR with build results
        uses: actions/github-script@v7
        if: always()
        with:
          script: |
            const buildOutcome = '${{ steps.build.outcome }}';
            const packageCount = '${{ steps.build.outputs.package-count }}' || '0';

            let body;
            if (buildOutcome === 'success') {
              body = `✅ **Build successful** for runtipi\n\n📦 Built ${packageCount} packages\n\nPackages are available as workflow artifacts for inspection.`;
            } else {
              body = `❌ **Build failed** for runtipi\n\nPlease check the workflow logs for details.`;
            }

            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: body
            });
```

#### 6.2: Main Branch Workflow

Create `.github/workflows/main-runtipi.yml`:

```yaml
name: Main - Runtipi

on:
  push:
    branches:
      - main
    paths:
      - 'sources/runtipi/**'
      - 'tools/**'
      - '.github/actions/**'
      - '.github/workflows/main-runtipi.yml'

permissions:
  contents: read

jobs:
  build:
    name: Build Runtipi Packages
    runs-on: ubuntu-latest
    outputs:
      has-packages: ${{ steps.check-packages.outputs.has-packages }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Build packages
        id: build
        uses: ./.github/actions/build-deb
        with:
          source: runtipi

      - name: Check if packages were built
        id: check-packages
        run: |
          if compgen -G "build/*.deb" > /dev/null; then
            echo "has-packages=true" >> $GITHUB_OUTPUT
            echo "::notice::Found packages to upload"
          else
            echo "has-packages=false" >> $GITHUB_OUTPUT
            echo "::notice::No packages built (source not yet implemented)"
          fi

      - name: Upload build artifacts
        if: steps.check-packages.outputs.has-packages == 'true'
        uses: actions/upload-artifact@v4
        with:
          name: packages-runtipi-unstable
          path: |
            build/*.deb
            build/*.buildinfo
            build/*.changes
          retention-days: 30

  publish-unstable:
    name: Publish to Unstable Channel
    runs-on: ubuntu-latest
    needs: build
    if: needs.build.outputs.has-packages == 'true'
    steps:
      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: packages-runtipi-unstable
          path: build

      - name: List packages to publish
        run: |
          echo "::notice::Publishing to unstable channel"
          echo "::notice::Packages to publish:"
          ls -lh build/*.deb

      - name: Dispatch to APT repository
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.APT_REPO_PAT }}
          repository: hatlabs/apt.hatlabs.fi
          event-type: package-updated
          client-payload: |
            {
              "repository": "${{ github.repository }}",
              "distro": "trixie",
              "channel": "unstable",
              "component": "main"
            }

      - name: Report success
        run: |
          echo "=== Unstable Channel Publish Complete ==="
          echo "Repository: ${{ github.repository }}"
          echo "Distro: trixie"
          echo "Channel: unstable"
          echo "Component: main"
```

#### 6.3: Release Workflow

Create `.github/workflows/release-runtipi.yml`:

```yaml
name: Release - Runtipi

on:
  release:
    types: [published]

permissions:
  contents: read

jobs:
  build:
    name: Build Runtipi Packages
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Build packages
        uses: ./.github/actions/build-deb
        with:
          source: runtipi

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: packages-runtipi-stable
          path: |
            build/*.deb
            build/*.buildinfo
            build/*.changes

  publish-stable:
    name: Publish to Stable Channel
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: packages-runtipi-stable
          path: build

      - name: Dispatch to APT repository
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.APT_REPO_PAT }}
          repository: hatlabs/apt.hatlabs.fi
          event-type: package-updated
          client-payload: |
            {
              "repository": "${{ github.repository }}",
              "distro": "trixie",
              "channel": "stable",
              "component": "main"
            }
```

### Step 7: Create Source README

Edit `sources/newsource/README.md`:

```bash
# Copy and customize template
cp sources/_template/README.md.template sources/newsource/README.md

# Edit and replace all {PLACEHOLDERS}
vim sources/newsource/README.md
```

Replace placeholders like `{DISPLAY_NAME}`, `{SOURCE_ID}`, `{PREFIX}`, etc. with your actual values.

### Step 8: Run the Converter

Now populate the `apps/` directory by running the converter.

**Important**: The conversion workflow is currently manual. Automated source-based conversion is planned but not yet implemented.

For CasaOS sources, you would:
1. Clone the upstream repository
2. Run `generate-container-packages` on each app directory
3. Copy converted apps to your `sources/newsource/apps/` directory

See the existing `sources/casaos/apps/` directory structure as a reference for the expected output format.

**Note:** Automated sync workflows (planned) will handle this conversion automatically in the future.

### Step 9: Validate Structure

Validate your new source:

```bash
# Validate structure
./tools/validate-structure.sh runtipi

# Expected output:
# INFO: Validating source: runtipi
# INFO: ✓ Source runtipi validated successfully
# INFO: All validations passed successfully
```

If validation fails, review the error messages and fix the issues.

### Step 10: Test Build

Build packages to verify everything works:

```bash
# Build your source
./run build-source runtipi

# Check output
ls -lh build/

# Expected:
# runtipi-container-store_*.deb  (store package)
# runtipi-app1-container_*.deb   (app packages)
# runtipi-app2-container_*.deb
# ... (all converted apps)
```

## Configuration Details

### Package Naming Pattern

All packages follow this pattern:
```
{package_prefix}-{appname}-container
```

Examples:
- `casaos-uptimekuma-container`
- `runtipi-jellyfin-container`
- `custom-myapp-container`

The `package_prefix` is set in `upstream/source.yaml` and must match the `include_patterns` in `store/{source}.yaml`.

### Store ID Requirements

The store ID must:
- Match the source directory name exactly
- Use lowercase letters only
- Use hyphens (not underscores)
- Be unique across all sources

### Icon Requirements

Store icons should be:
- SVG format (preferred) or PNG
- 256x256 pixels minimum
- Clear and recognizable at small sizes
- Represent the upstream source brand (with permission)

### Workflow Path Filters

Each workflow only triggers on changes to:
- `sources/{your-source}/**` - Your source directory
- `tools/**` - Shared tooling
- `.github/actions/**` - Shared actions
- `.github/workflows/**{your-source}.yml` - Your workflows

This prevents unnecessary builds when other sources change.

## Testing Your Source

### Local Testing Checklist

- [ ] Structure validation passes
- [ ] Store package builds successfully
- [ ] App packages build successfully
- [ ] Package names follow convention
- [ ] Package metadata is correct
- [ ] Store definition is valid YAML

### Integration Testing

Test on a HaLOS system:

```bash
# 1. Build packages locally
./run build-source runtipi

# 2. Copy to test system
scp build/runtipi-container-store_*.deb pi@halos.local:/tmp/
scp build/runtipi-jellyfin-container_*.deb pi@halos.local:/tmp/

# 3. Install on test system
ssh pi@halos.local
sudo dpkg -i /tmp/runtipi-container-store_*.deb
sudo dpkg -i /tmp/runtipi-jellyfin-container_*.deb

# 4. Verify in Cockpit
# - Navigate to https://halos.local:9090
# - Go to Applications → Container Apps
# - Verify "Runtipi" store appears
# - Verify apps appear under the correct store
# - Test installing and running an app
```

### CI/CD Testing

Create a PR to test workflows:

```bash
# Create branch
git checkout -b feat/add-runtipi-source

# Stage all changes
git add sources/runtipi/
git add .github/workflows/*runtipi.yml

# Commit
git commit -m "feat(runtipi): add Runtipi source"

# Push
git push origin feat/add-runtipi-source

# Create PR
gh pr create --title "feat(runtipi): add Runtipi source" \
  --body "Adds Runtipi as a new container source"

# Watch CI checks
gh pr checks --watch
```

The PR workflow should:
1. Validate source structure ✓
2. Build all packages ✓
3. Comment on PR with results ✓

## Troubleshooting

### Validation Fails

**Problem:** `validate-structure.sh` reports errors

**Solutions:**
```bash
# Check required directories exist
ls sources/runtipi/apps
ls sources/runtipi/store
ls sources/runtipi/upstream

# Check store YAML exists
ls sources/runtipi/store/*.yaml

# Check upstream config exists
ls sources/runtipi/upstream/source.yaml

# Validate YAML syntax
yq eval . sources/runtipi/store/runtipi.yaml
yq eval . sources/runtipi/upstream/source.yaml
```

### Build Fails

**Problem:** `build-source.sh` fails

**Common issues:**

1. **Missing debian/ directory:**
   ```bash
   # Ensure debian packaging exists
   ls -la sources/runtipi/store/debian/
   # Should contain: control, rules, changelog, copyright
   ```

2. **Invalid package prefix:**
   ```bash
   # Check prefix matches in both configs
   grep package_prefix sources/runtipi/upstream/source.yaml
   grep include_patterns sources/runtipi/store/runtipi.yaml
   # They must match: runtipi-*-container
   ```

3. **Missing converter:**
   ```bash
   # Verify converter exists in container-packaging-tools
   ./run shell
   generate-container-packages --help | grep runtipi
   ```

### Apps Don't Appear in Cockpit

**Problem:** Store installed but apps not visible

**Solutions:**
```bash
# 1. Verify store package installed
dpkg -l | grep runtipi-container-store

# 2. Check store definition installed
ls /usr/share/container-stores/runtipi.yaml

# 3. Verify package filters correct
cat /usr/share/container-stores/runtipi.yaml | grep include_patterns

# 4. Restart Cockpit
sudo systemctl restart cockpit

# 5. Check Cockpit logs
journalctl -u cockpit -n 50
```

### Workflow Doesn't Trigger

**Problem:** PR created but CI checks don't run

**Solutions:**
```bash
# 1. Verify path filters in workflow
cat .github/workflows/pr-runtipi.yml | grep -A 5 paths:

# 2. Ensure PR modifies watched paths
# Workflow triggers on:
#   - sources/runtipi/**
#   - tools/**
#   - .github/workflows/**runtipi.yml

# 3. Force trigger by modifying watched path
touch sources/runtipi/README.md
git commit -am "chore: trigger CI"
git push
```

## Examples

### Reference Implementation: CasaOS

The only complete, working implementation currently in the repository:
- Source: `sources/casaos/`
- Workflows: `.github/workflows/*casaos.yml`
- Store: `sources/casaos/store/`
- Upstream config: `sources/casaos/upstream/source.yaml`

Use this as your template when adding new sources.

### Minimal Example Structure

```
sources/newsource/
├── apps/
│   ├── app1/
│   │   ├── metadata.yaml
│   │   ├── config.yml
│   │   └── docker-compose.yml
│   └── ... (more apps)
├── store/
│   ├── newsource.yaml
│   ├── icon.svg
│   └── debian/
│       ├── control
│       ├── rules
│       ├── changelog
│       └── copyright
├── upstream/
│   └── source.yaml
└── README.md
```

**See `sources/casaos/` for the actual working implementation.**

## Best Practices

1. **Start with casaos as reference:** Copy workflow patterns and structure
2. **Test locally first:** Validate and build before creating PR
3. **Use descriptive names:** Make source IDs and package prefixes clear
4. **Document categories:** Match categories to actual app types in your source
5. **Keep prefix short:** Package names will be `{prefix}-{app}-container`
6. **Version correctly:** Follow Debian changelog conventions
7. **Test integration:** Verify apps appear correctly in Cockpit UI

## Related Documentation

- **[SPEC.md](./SPEC.md)**: Technical specification
- **[ARCHITECTURE.md](./ARCHITECTURE.md)**: Architecture overview
- **[IMPLEMENTATION_CHECKLIST.md](./IMPLEMENTATION_CHECKLIST.md)**: Implementation guidelines
- **[container-packaging-tools](https://github.com/halos-org/container-packaging-tools)**: Converter documentation

## Getting Help

- **Issues:** [GitHub Issues](https://github.com/halos-org/halos-imported-containers/issues)
- **Template Files:** Check `sources/_template/` for examples
- **Reference:** Use `sources/casaos/` as a complete example
