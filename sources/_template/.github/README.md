# GitHub Actions Workflow Templates

This directory contains GitHub Actions workflow templates for adding new sources to the halos-imported-containers repository.

## Overview

When adding a new source (e.g., Runtipi, Portainer, etc.), you need to create three workflow files in the repository's `.github/workflows/` directory:

1. **pr-{source}.yml** - Validates and builds packages on pull requests
2. **main-{source}.yml** - Builds and publishes packages to unstable channel on merge to main
3. **release-{source}.yml** - Builds and publishes packages to stable channel on release

These templates provide the complete workflow structure with placeholders that you need to replace.

## Quick Start

### Step 1: Copy Templates to Main Workflows Directory

```bash
# From repository root, for a new source called "runtipi":
cp sources/_template/.github/workflows/pr-{source}.yml.template .github/workflows/pr-runtipi.yml
cp sources/_template/.github/workflows/main-{source}.yml.template .github/workflows/main-runtipi.yml
cp sources/_template/.github/workflows/release-{source}.yml.template .github/workflows/release-runtipi.yml
```

### Step 2: Replace Placeholders

Each template file contains placeholders that need to be replaced:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{SOURCE_DISPLAY_NAME}` | Human-readable source name | `Runtipi`, `Portainer Community` |
| `{source}` | Source directory name (lowercase) | `runtipi`, `portainer` |

**Find and replace in each file:**

```bash
# For a source called "runtipi" with display name "Runtipi":
# Use platform-agnostic sed with backup extension
sed -i.bak 's/{SOURCE_DISPLAY_NAME}/Runtipi/g' .github/workflows/pr-runtipi.yml
sed -i.bak 's/{source}/runtipi/g' .github/workflows/pr-runtipi.yml

sed -i.bak 's/{SOURCE_DISPLAY_NAME}/Runtipi/g' .github/workflows/main-runtipi.yml
sed -i.bak 's/{source}/runtipi/g' .github/workflows/main-runtipi.yml

sed -i.bak 's/{SOURCE_DISPLAY_NAME}/Runtipi/g' .github/workflows/release-runtipi.yml
sed -i.bak 's/{source}/runtipi/g' .github/workflows/release-runtipi.yml

# Clean up backup files
rm .github/workflows/*.bak
```

### Step 3: Remove Template Comments

Each template has a large comment block at the top explaining template usage. Remove these comment blocks after you've applied all changes.

The comment block starts with:
```yaml
# GitHub Actions Workflow for ...
# TEMPLATE USAGE:
# 1. Copy this file to: ...
```

Remove everything from the first line down to and including "# 5. Remove this comment block and the .template extension"

### Step 4: Validate Syntax

Validate that your workflow files have correct YAML syntax:

```bash
# Using yamllint (install with: pip install yamllint)
yamllint .github/workflows/pr-runtipi.yml
yamllint .github/workflows/main-runtipi.yml
yamllint .github/workflows/release-runtipi.yml

# Or using GitHub Actions extension for VS Code
# Just open the files and check for syntax highlighting errors
```

### Step 5: Test Workflows

1. **Create a test branch** with your new workflows
2. **Create a PR** to test the PR workflow
3. **Merge to main** to test the main workflow (if source is implemented)
4. **Create a release** with appropriate tag to test release workflow

## Workflow Details

### PR Workflow (`pr-{source}.yml`)

**Purpose**: Validates source structure and builds packages on pull requests

**Triggers on**:
- Pull requests affecting `sources/{source}/**`
- Changes to shared infrastructure (`tools/`, `.github/actions/`)

**Jobs**:
1. **validate** - Validates source structure using `.github/actions/validate-source`
2. **build** - Builds packages using `.github/actions/build-deb` and posts results to PR

**Path Filters**: Only runs when relevant files change

### Main Workflow (`main-{source}.yml`)

**Purpose**: Builds and publishes packages to unstable channel on merge to main

**Triggers on**:
- Push to main branch affecting `sources/{source}/**`
- Changes to shared infrastructure

**Jobs**:
1. **build** - Builds packages and uploads artifacts
2. **publish-unstable** - Creates pre-release and dispatches to APT repository

**Publishing**:
- Creates GitHub pre-release with tag format `YYYY-MM-DD+N`
- Dispatches to `halos-org/apt.halos.fi` repository (unstable channel)
- Requires `APT_REPO_PAT` secret

### Release Workflow (`release-{source}.yml`)

**Purpose**: Builds and publishes packages to stable channel on release

**Triggers on**:
- GitHub release published (not draft)
- Tag name contains source identifier

**Tag Format**:
- `{source}/v1.2.3` (recommended: source-prefixed semantic version)
- `v1.2.3-{source}` (alternative: version with source suffix)

**Jobs**:
1. **build** - Builds packages from tagged release and attaches to release
2. **publish-stable** - Dispatches to APT repository (stable channel)

**Publishing**:
- Attaches .deb packages to GitHub release
- Dispatches to `halos-org/apt.halos.fi` repository (stable channel)
- Requires `APT_REPO_PAT` secret

## Placeholders Reference

### {SOURCE_DISPLAY_NAME}

The human-readable name for the source as it appears in:
- Workflow names
- Job names
- Release titles
- Documentation

**Examples**:
- `CasaOS Official`
- `Runtipi`
- `Portainer Community`
- `Awesome-Compose`

**Case**: Use Title Case with proper spacing

### {source}

The technical identifier for the source used in:
- File names
- Directory paths
- Artifact names
- Tag names

**Examples**:
- `casaos`
- `runtipi`
- `portainer`
- `awesome-compose`

**Case**: Always lowercase, use hyphens for spaces

**Must Match**: The directory name in `sources/{source}/`

## Path Filters

Each workflow includes path filters to trigger only on relevant changes:

```yaml
paths:
  - 'sources/{source}/**'          # This source's apps and configuration
  - 'tools/**'                      # Build scripts affect all sources
  - '.github/actions/**'            # Shared actions affect all sources
  - '.github/workflows/**{source}.yml'  # This workflow file itself
```

**Important**: Make sure the `sources/{source}/**` path matches your actual source directory name.

## Secrets Required

The workflows require the following repository secret:

### APT_REPO_PAT

**Purpose**: GitHub Personal Access Token with write access to `halos-org/apt.halos.fi` repository

**Used by**:
- `main-{source}.yml` (publish-unstable job)
- `release-{source}.yml` (publish-stable job)

**Permissions**: Needs write access to dispatch repository events

**Configuration**: Set in repository settings → Secrets and variables → Actions

## Common Customizations

### Different Tag Format

If you want to use a different release tag format, update the conditions in `release-{source}.yml`:

```yaml
# Current format: {source}/v1.2.3 or v1.2.3-{source}
if: |
  github.event.release.draft == false &&
  (startsWith(github.event.release.tag_name, '{source}/') ||
   contains(github.event.release.tag_name, '{source}'))

# Alternative: Only prefix format
if: |
  github.event.release.draft == false &&
  startsWith(github.event.release.tag_name, '{source}/')

# Alternative: Exact match
if: |
  github.event.release.draft == false &&
  github.event.release.tag_name == '{source}/v1.0.0'
```

### Additional Validation Steps

You can add source-specific validation steps to the PR workflow:

```yaml
- name: Custom validation for {source}
  run: |
    # Add your custom validation here
    ./tools/validate-{source}.sh
```

### Custom Build Parameters

If your source needs special build parameters, pass them to the build action:

```yaml
- name: Build packages
  uses: ./.github/actions/build-deb
  with:
    source: {source}
    # Add custom parameters here if build-deb action supports them
    extra-args: "--verbose"
```

## Testing Checklist

Before merging workflows for a new source:

- [ ] All placeholders replaced correctly
- [ ] Template comment blocks removed
- [ ] YAML syntax validates
- [ ] Path filters match source directory
- [ ] PR workflow triggers on test PR
- [ ] PR workflow validates and builds successfully
- [ ] Main workflow triggers on merge to main
- [ ] Release workflow triggers on tagged release
- [ ] Packages appear in GitHub releases
- [ ] APT repository receives dispatch events

## Troubleshooting

### Workflow doesn't trigger

**Check**:
- Path filters match your source directory name exactly
- Workflow file is in `.github/workflows/` (not in sources directory)
- Workflow file has `.yml` extension (not `.yml.template`)

### Build fails with "source not found"

**Check**:
- Source directory exists: `sources/{source}/`
- Source name in workflow matches directory name exactly (case-sensitive)
- Build action parameter `source:` is set correctly

### Publish fails with authentication error

**Check**:
- `APT_REPO_PAT` secret is configured in repository settings
- PAT has write access to `halos-org/apt.halos.fi` repository
- PAT has not expired

### Release workflow doesn't trigger

**Check**:
- Release is published (not draft)
- Tag name matches the expected format
- Conditional expression in workflow includes your source name

## See Also

- **docs/ARCHITECTURE.md** - CI/CD architecture and workflow design
- **docs/SPEC.md** - Requirements and specifications
- **.github/actions/** - Repository-specific reusable actions
- **tools/** - Build scripts used by workflows

## Support

For questions or issues with workflow templates:
1. Check existing workflows in `.github/workflows/pr-casaos.yml` for reference
2. Review ARCHITECTURE.md for workflow design patterns
3. Open an issue in the repository
