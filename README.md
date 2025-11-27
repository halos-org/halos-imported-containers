# HaLOS CasaOS Container Store

Auto-converted CasaOS App Store mirror for HaLOS.

## Overview

This repository contains automatically converted container applications from the [CasaOS App Store](https://github.com/IceWhaleTech/CasaOS-AppStore) for use with HaLOS (Hat Labs Operating System).

**Package Naming Convention**: `casaos-{appname}-container`

This prefix:
- Clearly identifies the package source (auto-converted from CasaOS)
- Prevents naming conflicts with manually curated packages
- Enables multiple app sources to coexist in the HaLOS ecosystem

## Structure

```
halos-casaos-containers/
├── apps/                 # Converted CasaOS applications
│   ├── uptimekuma/      # Each app has metadata.yaml, config.yml, docker-compose.yml
│   └── ...              # 147 apps total
├── store/               # CasaOS container store definition
│   └── casaos.yaml      # Store configuration and filters
└── tools/               # Build and sync automation
```

## Conversion Process

Apps are automatically converted using the [`container-packaging-tools`](https://github.com/hatlabs/container-packaging-tools) converter:

1. **Upstream Sync**: Monitor CasaOS-AppStore for changes
2. **Automatic Conversion**: Run converter on all apps (100% success rate - 147/147 apps)
3. **Package Generation**: Build Debian packages with proper metadata
4. **Repository Publishing**: Publish to apt.hatlabs.fi

## Package Format

Each converted app includes:
- **metadata.yaml**: Package metadata, description, maintainer info
- **config.yml**: User-configurable parameters (environment variables, volumes)
- **docker-compose.yml**: Container service definition

## Store Configuration

The CasaOS store is configured to include:
- All packages matching pattern: `casaos-*-container`
- Origin: Hat Labs
- Categories: Web, utilities, media, networking, etc. (non-marine apps)

## Installation

Apps from this store can be installed via:

```bash
# Install the store package
sudo apt install casaos-container-store

# Install individual apps
sudo apt install casaos-uptimekuma-container
sudo apt install casaos-jellyfin-container
```

## Automation

This repository uses fully automated CI/CD:
- **Daily sync**: Check for upstream changes in CasaOS-AppStore
- **Auto-conversion**: Re-convert modified apps
- **PR creation**: Automated PRs for review
- **Release**: Auto-publish to APT repository

## Version Management

- **VERSION file**: Contains upstream version (e.g., `0.1.0`)
- **Git tags**: Auto-generated with format `v{version}+{N}_pre` (unstable) and `v{version}+{N}` (stable)
- **Debian packages**: Use version format `{version}-{N}`

## Development

See the [HaLOS development docs](https://github.com/hatlabs/halos-distro) for information on:
- Building packages locally
- Testing converted apps
- Contributing improvements

## Related Repositories

- **[container-packaging-tools](https://github.com/hatlabs/container-packaging-tools)**: Converter and packaging tools
- **[halos-marine-containers](https://github.com/hatlabs/halos-marine-containers)**: Manually curated marine navigation apps
- **[CasaOS-AppStore](https://github.com/IceWhaleTech/CasaOS-AppStore)**: Upstream source for app definitions

## License

Package definitions and metadata: MIT License

Individual applications retain their upstream licenses as specified in their metadata.
