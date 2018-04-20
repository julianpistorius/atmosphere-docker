# Changelog
All notable changes to this project will be documented in this file.

## [PR #2: Postgres database container](https://github.com/cyverse/atmosphere-docker/pull/2) - 2018-04-18
---
### Added
- Postgres container

### Changed
- Some build tasks in the Atmosphere and Troposphere containers required the database to be active, so I had to move these tasks into the entrypoint. This causes startup to take a little longer than before.
- Using postgres container allows us to create Docker images for different Atmosphere versions **without** a database so that nothing is leaked, but then users can add a database file at startup, or use an existing database container.
- Database dump documentation

### Removed
None.


## [PR #3: Choose version on run instead of build](https://github.com/cyverse/atmosphere-docker/pull/3) - 2018-04-20
---
### Added
- New environment file `options.env`. This file contains empty environment variables for GitHub repository and branch choices.

### Changed
- Added a lot of stuff to the entrypoints so that new branches/remotes can be chosen and built.

### Removed
None.
