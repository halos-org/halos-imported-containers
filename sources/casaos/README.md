# CasaOS Source

Auto-imported container applications from the [CasaOS App Store](https://github.com/IceWhaleTech/CasaOS-AppStore).

## Overview

This source provides automatic conversion and packaging of applications from the upstream CasaOS App Store repository. Applications are automatically converted to HaLOS-compatible Debian packages using the CasaOS converter from container-packaging-tools.

**Statistics**: 144 applications available

## Structure

```
casaos/
├── apps/                # Converted application definitions (144 apps)
│   ├── app-name-1/     # Individual app directories
│   ├── app-name-2/     # Each contains metadata.yaml, config.yml, docker-compose.yml
│   └── ...
├── store/               # Store definition and packaging
│   ├── casaos.yaml  # Store configuration for Cockpit
│   ├── icon.svg              # Store branding (256x256)
│   └── debian/               # Debian packaging for store package
│       ├── control
│       ├── rules
│       ├── changelog
│       └── copyright
├── upstream/            # Upstream sync configuration
│   └── source.yaml     # Sync settings and metadata
└── README.md           # This file
```

## Upstream Source

- **Repository**: https://github.com/IceWhaleTech/CasaOS-AppStore
- **Branch**: `main`
- **Path**: `Apps/`
- **Format**: CasaOS App Manifest v2.0
- **Maintainer**: IceWhale Tech

## Package Naming

All packages from this source use the `casaos-{appname}-container` naming pattern:

- **casaos-jellyfin-container**: Jellyfin media server from CasaOS
- **casaos-uptimekuma-container**: Uptime Kuma monitoring from CasaOS
- **casaos-portainer-container**: Portainer container management from CasaOS

The `casaos-` prefix clearly identifies packages from this source and prevents conflicts with packages from other sources (runtipi, manually curated, etc.).

## Store Package

The store package `casaos-container-store` provides:

- **Store definition**: Configuration for Cockpit UI integration
- **Package filtering**: Includes all `casaos-*-container` packages
- **Categories**: Media, Utilities, Automation, Networking, Storage, Development, Monitoring
- **Branding**: Icon and optional banner for store display

## Sync Process (Planned)

The automated sync workflow will:

1. **Daily Check**: Monitor upstream repository for changes
2. **Change Detection**: Identify new, updated, or removed apps
3. **Automatic Conversion**: Run CasaOS converter on modified apps
4. **PR Creation**: Create pull request with converted apps
5. **Validation**: CI validates all converted app definitions
6. **Merge**: After approval, merge triggers package builds
7. **Publication**: Packages published to apt.hatlabs.fi

## Conversion Details

Apps are converted using the `casaos` converter from container-packaging-tools:

- **Input Format**: CasaOS App Manifest (JSON)
- **Output Format**: HaLOS container package format (metadata.yaml, config.yml, docker-compose.yml)
- **Intelligent Fallbacks**: Handles missing descriptions, invalid variable names, null screenshots
- **Metadata Enhancement**: Adds Debian packaging metadata, dependencies, maintainer info
- **High Success Rate**: Currently 144/144 valid apps convert successfully

## Installation

```bash
# Install the store package
sudo apt install casaos-container-store

# Install individual apps
sudo apt install casaos-jellyfin-container
sudo apt install casaos-uptimekuma-container
sudo apt install casaos-portainer-container
```

The store package is required for apps to appear in the Cockpit UI, but individual apps can be installed independently via APT.

## Building

Build all CasaOS packages (store + apps):

```bash
# From repository root
./tools/build-source.sh casaos

# Output: build/*.deb
```

## Application Categories

Apps span multiple categories:

- **Media & Entertainment**: Jellyfin, Plex, Emby, Navidrome, etc.
- **Utilities & Tools**: File browsers, download managers, productivity tools
- **Home Automation**: Home Assistant, Node-RED, MQTT brokers
- **Networking & Security**: VPNs, DNS servers, ad blockers, proxies
- **Storage & Backup**: File sync, backup solutions, cloud storage
- **Development & Code**: Git servers, CI/CD platforms, code editors
- **Monitoring & Analytics**: Uptime monitors, dashboards, log aggregators

## Source Attribution

All packages clearly indicate their source:

- **Package prefix**: `casaos-` identifies CasaOS origin
- **Metadata**: Includes upstream URL and original CasaOS repository link
- **Maintainer**: Hat Labs (as package maintainer)
- **Upstream License**: Preserved from original app definition

## Related

- **Upstream**: [CasaOS-AppStore](https://github.com/IceWhaleTech/CasaOS-AppStore)
- **Converter**: [container-packaging-tools](https://github.com/halos-org/container-packaging-tools)
- **Repository**: [halos-imported-containers](https://github.com/halos-org/halos-imported-containers)
- **APT Repository**: [apt.hatlabs.fi](https://apt.hatlabs.fi)

## License

Package definitions and metadata: MIT License

Individual applications retain their upstream licenses as specified in their original CasaOS app manifests.
