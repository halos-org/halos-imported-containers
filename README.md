# HaLOS Imported Containers

Auto-imported container applications from multiple app stores for HaLOS.

## Overview

This repository contains automatically converted container applications from multiple upstream app stores for use with HaLOS (Hat Labs Operating System). Currently supported sources:

- **[CasaOS](https://github.com/IceWhaleTech/CasaOS-AppStore)**: 144 applications
- **CasaOS Community**: Third-party CasaOS stores (planned)
- **Runtipi**: Runtipi app store (planned)

**Package Naming Convention**: `{source}-{appname}-container`

Source-specific prefixes:
- Clearly identify the package source (casaos-, runtipi-, etc.)
- Prevent naming conflicts between sources and manually curated packages
- Enable multiple app sources to coexist in the HaLOS ecosystem

## Structure

```
halos-imported-containers/
├── sources/
│   ├── casaos/     # CasaOS official apps (current)
│   │   ├── apps/            # Converted applications (144 apps)
│   │   ├── store/           # Store definition and packaging
│   │   └── upstream/        # Sync metadata
│   ├── casaos-community/    # CasaOS community apps (planned)
│   ├── runtipi/             # Runtipi apps (planned)
│   └── _template/           # Template for adding new sources
├── tools/                   # Build and sync automation
└── docs/                    # Specifications and architecture
```

## Conversion Process

Apps are automatically converted using the [`container-packaging-tools`](https://github.com/halos-org/container-packaging-tools) converter:

1. **Upstream Sync**: Monitor multiple upstream app stores for changes
2. **Automatic Conversion**: Run source-specific converters on all apps (currently 144/144 for CasaOS)
3. **Package Generation**: Build Debian packages with proper metadata and source prefixes
4. **Repository Publishing**: Publish to apt.hatlabs.fi

## Package Format

Each converted app includes:
- **metadata.yaml**: Package metadata, description, maintainer info
- **config.yml**: User-configurable parameters (environment variables, volumes)
- **docker-compose.yml**: Container service definition

## Store Configuration

Each source has its own container store package:
- **casaos-container-store**: Includes packages matching `casaos-*-container`
- **casaos-community-container-store** (planned): Includes packages matching `casaos-community-*-container`
- **runtipi-container-store** (planned): Includes packages matching `runtipi-*-container`

All stores:
- Origin: Hat Labs
- Categories: Web, utilities, media, networking, etc. (non-marine apps)
- Appear separately in Cockpit UI for clear source attribution

## Installation

Apps from these stores can be installed via:

```bash
# Install a store package
sudo apt install casaos-container-store

# Install individual apps (with source prefix)
sudo apt install casaos-uptimekuma-container
sudo apt install casaos-jellyfin-container

# Future: Runtipi apps
sudo apt install runtipi-container-store
sudo apt install runtipi-jellyfin-container
```

## Automation

This repository uses fully automated CI/CD:
- **Daily sync**: Check for upstream changes across all configured sources
- **Auto-conversion**: Re-convert modified apps per source
- **PR creation**: Automated PRs for review
- **Release**: Auto-publish to APT repository
- **Per-source builds**: Each source can be built and deployed independently

## Version Management

- **VERSION file**: Contains repository infrastructure version (e.g., `0.1.0`)
- **Git tags**: Auto-generated with format `v{version}+{N}_pre` (unstable) and `v{version}+{N}` (stable)
- **Store packages**: Each source's store package has independent versioning
- **App packages**: Individual app versions track upstream versions

## Development

See the [HaLOS development docs](https://github.com/halos-org/halos-distro) for information on:
- Building packages locally
- Testing converted apps
- Contributing improvements

## Related Repositories

- **[container-packaging-tools](https://github.com/halos-org/container-packaging-tools)**: Converter and packaging tools
- **[halos-marine-containers](https://github.com/halos-org/halos-marine-containers)**: Manually curated marine navigation apps
- **[CasaOS-AppStore](https://github.com/IceWhaleTech/CasaOS-AppStore)**: Upstream source for app definitions

## License

Package definitions and metadata: MIT License

Individual applications retain their upstream licenses as specified in their metadata.
