# HaLOS Imported Containers - Technical Specification

## Project Overview

The HaLOS Imported Containers repository provides automated systems for converting and packaging applications from multiple upstream container app stores for use in the HaLOS (Hat Labs Operating System) ecosystem. This project enables HaLOS users to access a wide catalog of containerized applications from various sources while maintaining quality, consistency, and seamless integration with HaLOS infrastructure.

### Supported Sources

**Current:**
1. **CasaOS** - IceWhaleTech CasaOS App Store (144 applications)
   - Package prefix: `casaos-*-container`
   - Store package: `casaos-container-store`

2. **Future Sources** - Extensible architecture supports additional sources as needed
   - Each third-party source has its own specific name (e.g., casaos-xyz, casaos-abc)
   - No generic "community" store - each maintains its own identity

The multi-source architecture allows each source to maintain its own identity, versioning, and quality standards while sharing common infrastructure and tooling.

## Goals

### Primary Goals

1. **Multi-Source Architecture**: Support multiple upstream app stores (CasaOS, Runtipi, etc.) within a single repository while maintaining clear source attribution and independent versioning

2. **Automated Conversion Pipeline**: Establish fully automated CI/CD pipelines that monitor upstream app stores and convert applications to HaLOS-compatible Debian packages

3. **High Conversion Success Rate**: Maintain high conversion success rates for each source (currently 144/144 for CasaOS = 97.9% of upstream apps)

4. **Continuous Synchronization**: Keep HaLOS stores synchronized with upstream changes through daily monitoring and automatic conversion

5. **Quality Assurance**: Ensure all converted packages meet HaLOS standards through automated testing and validation

6. **Clear Source Attribution**: Use source-specific prefixes (casaos-, runtipi-, etc.) to clearly identify package origins and prevent naming conflicts

### Secondary Goals

1. **Minimal Manual Intervention**: Reduce manual curation effort while maintaining quality through intelligent defaults and validation

2. **User Choice**: Allow users to choose between different sources and manually curated apps when multiple versions exist

3. **Scalability**: Support growth across multiple app store catalogs without manual scaling effort

4. **Easy Source Addition**: Provide templates and tooling to make adding new upstream sources straightforward

## Core Features

### 1. Upstream Synchronization

**Feature**: Daily monitoring of multiple upstream app store repositories for changes

**Behavior**:
- Automated GitHub workflows run daily to check for upstream changes across all configured sources
- Each source maintains its own sync configuration and schedule
- Compares current apps directory with latest upstream content per source
- Detects new apps, updated apps, and removed apps
- Creates pull requests when changes are detected in any source

**Success Criteria**:
- New apps appear in HaLOS within 24 hours of upstream publication
- Updated apps reflect upstream changes within 24 hours
- No manual intervention required for standard updates
- Each source can be synced independently

### 2. Batch Conversion

**Feature**: Convert applications from multiple upstream sources to HaLOS package format

**Behavior**:
- Use container-packaging-tools with source-specific converters (casaos, runtipi, etc.)
- Apply intelligent fallbacks for missing data (empty descriptions, null screenshots, invalid variable names)
- Generate proper Debian package metadata following HaLOS conventions
- Preserve full content while meeting Debian synopsis length requirements
- Each source maintains its own conversion configuration

**Success Criteria**:
- All valid apps from each source convert successfully (currently 144/144 for CasaOS)
- Generated packages pass validation
- Metadata follows Debian packaging standards
- Configuration schemas are valid
- Source prefix correctly applied to all packages

### 3. Package Building

**Feature**: Build Debian packages for all converted applications from all sources

**Behavior**:
- Generate individual .deb packages for each app with source-specific naming pattern (`{source}-{appname}-container`)
- Build per-source store metapackages that define each store
- Use HaLOS unified versioning (VERSION file + auto-incrementing revisions)
- Include all necessary metadata, configuration, and compose files
- Support building all sources or individual sources independently

**Success Criteria**:
- Each app produces a valid .deb package with correct source prefix
- Packages install correctly on HaLOS systems
- Each source's store package enables discovery of its apps
- Version numbers follow HaLOS conventions
- Build process scales to multiple sources

### 4. Repository Publication

**Feature**: Publish packages to apt.hatlabs.fi APT repository

**Behavior**:
- Push to unstable channel on merge to main
- Create draft releases for stable channel
- Support both pre-release and stable distribution
- Integrate with existing APT repository infrastructure

**Success Criteria**:
- Packages available via `apt install casaos-{appname}-container`
- Store package enables Cockpit UI discovery
- Updates propagate through normal APT mechanisms

### 5. Store Configuration

**Feature**: Per-source store packages providing individual store definitions

**Behavior**:
- Each source defines its own store metadata (name, description, icon, banner)
- Configure source-specific package filters (casaos-*-container, runtipi-*-container, etc.)
- Enable Cockpit container management UI integration
- Support multi-store architecture (all sources coexist with marine store)
- Users can install only the stores they want

**Success Criteria**:
- Each source's store appears separately in Cockpit UI
- Filters correctly include all source-prefixed packages
- Stores do not conflict with each other
- Clear source attribution in UI

### 6. Pull Request Validation

**Feature**: Automated validation of conversion changes in PRs

**Behavior**:
- Run converter tests (281 tests in container-packaging-tools repository)
- Validate all generated package metadata
- Build test packages
- Check for schema compliance

**Success Criteria**:
- PRs show pass/fail status clearly
- All validation must pass before merge
- Failed validations provide actionable error messages

## Technical Requirements

### Conversion Requirements

1. **Converter Tool**: Use container-packaging-tools v0.2.0+ with CasaOS converter
2. **Success Rate**: Maintain high conversion success (144/144 valid apps = 97.9%)
3. **Data Integrity**: Preserve all upstream metadata while adapting format
4. **Debian Compliance**: Generate packages that meet Debian packaging standards

### Package Requirements

1. **Naming**: All packages must use `{source}-{appname}-container` format, in lowercase (e.g., casaos-uptimekuma-container, runtipi-jellyfin-container)
2. **Versioning**: Follow HaLOS unified versioning (VERSION + git tags)
3. **Metadata**: Include valid metadata.yaml, config.yml, docker-compose.yml
4. **Dependencies**: Declare docker.io as package dependency
5. **Source Attribution**: Package metadata must clearly indicate upstream source

### CI/CD Requirements

1. **Daily Sync**: Automated check for upstream changes every 24 hours
2. **PR Creation**: Automatic PR generation when changes detected
3. **Validation**: All PRs must pass tests before merge eligible
4. **Release**: Automatic package building and publishing on merge

### Infrastructure Requirements

1. **Git Repository**: Private repository in hatlabs organization
2. **GitHub Actions**: Standard CI/CD workflows for PR, main, release
3. **APT Repository**: Integration with apt.hatlabs.fi
4. **Docker**: Build environment requires Docker support

## Key Constraints and Assumptions

### Constraints

1. **Upstream Formats**: Limited to formats supported by container-packaging-tools converters (CasaOS v2.0, Runtipi, etc.)
2. **Architecture**: Currently supports all/amd64/arm64 as specified by upstream sources
3. **HaLOS Integration**: Packages must work with Cockpit container management
4. **Naming Convention**: Must maintain source-specific prefixes for source clarity
5. **Repository Permissions**: Requires write access to hatlabs organization repos
6. **Source Independence**: Each source must be buildable and deployable independently

### Assumptions

1. **Converter Stability**: container-packaging-tools converters maintain high success rates for supported formats
2. **Upstream Quality**: Upstream app stores maintain reasonable quality standards
3. **Format Stability**: Upstream formats remain stable or provide migration paths
4. **Network Access**: Build environment can access GitHub and container registries
5. **Maintenance**: Initial deployment assumes active maintenance for first 6 months
6. **Source Compatibility**: Different sources can coexist without package conflicts

## Non-Functional Requirements

### Performance

1. **Sync Latency**: Changes appear in HaLOS within 24 hours of upstream publication
2. **Build Time**: Full batch conversion and build completes within 30 minutes
3. **PR Validation**: Validation tests complete within 5 minutes

### Reliability

1. **Conversion Success**: All valid CasaOS apps must convert successfully
2. **Build Success**: Package builds must succeed for all converted apps
3. **Idempotency**: Re-running conversion produces identical output for unchanged input

### Maintainability

1. **Automated Updates**: No manual intervention needed for standard app updates
2. **Clear Errors**: Validation failures provide actionable error messages
3. **Audit Trail**: All changes tracked in git history with clear commit messages

### Security

1. **Source Tracking**: Every package includes metadata about upstream source
2. **Validation**: All packages validated against schemas before publication
3. **Upstream Hashes**: Track upstream file hashes for change detection

### Scalability

1. **App Growth**: Support growth from 147 to 500+ apps without process changes
2. **Parallel Builds**: Support concurrent package building
3. **Resource Efficiency**: Build process uses reasonable CI/CD minutes

## Out of Scope

### Explicitly Out of Scope

1. **Manual Curation**: No manual review or modification of individual app definitions (use marine-containers for curated apps)

2. **Custom App Development**: No creation of HaLOS-specific apps in this repository (use marine-containers)

3. **Cross-Source Deduplication**: If the same app exists in multiple sources, both versions are provided (users choose)

4. **Source Ranking**: No automatic preference for one source over another

5. **App Testing**: No functional testing of individual applications (rely on upstream testing)

6. **Icon/Screenshot Hosting**: Assets remain hosted at upstream CDNs (no local hosting)

7. **Multi-Container Apps**: Complex multi-service apps may require manual intervention (edge case)

8. **App Store UI**: Custom app store interface beyond Cockpit integration

9. **Usage Analytics**: No tracking of which apps are popular or installed

10. **User Support**: No support for individual app usage questions (direct to upstream)

11. **License Compliance**: No automated license checking beyond recording upstream license

### Future Considerations

1. **Additional Sources**: Add more upstream app stores as they become relevant
2. **App Ratings**: User rating/review system integration with Cockpit
3. **Update Notifications**: Notify users of app updates
4. **Selective Sync**: Allow excluding specific problematic apps per source
5. **Local Asset Caching**: Host icons/screenshots locally for offline capability
6. **Cross-Source Search**: Enable searching apps across all sources simultaneously

## Success Metrics

### Launch Success (First Release)

- [ ] All 144 CasaOS apps converted and packaged
- [ ] casaos-container-store package published
- [ ] Automated daily sync operational for CasaOS source
- [ ] At least 3 successful automated sync cycles
- [ ] Documentation complete (README, SPEC, ARCHITECTURE docs)
- [ ] Template system for adding new sources established

### Ongoing Success

- Daily sync success rate > 95% per source
- Conversion success rate > 95% for valid apps per source
- Average time from upstream change to HaLOS availability < 24 hours
- Zero manual interventions needed per month for standard updates
- New sources can be added with < 4 hours of effort

## Approval and Sign-off

This specification defines the scope and requirements for the halos-imported-containers project. Implementation should follow this specification and the companion ARCHITECTURE.md document.

**Version**: 1.0
**Status**: Active
**Last Updated**: 2024-11-30
