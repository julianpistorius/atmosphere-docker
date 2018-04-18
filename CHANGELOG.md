# Changelog
All notable changes to this project will be documented in this file.

## [PR #1: Postgres database container](https://github.com/cyverse/atmosphere-docker/pull/1) - 2018-04-18
---
### Added
- Postgres container

### Changed
- Some build tasks in the Atmosphere and Troposphere containers required the database to be active, so I had to move these tasks into the entrypoint. This causes startup to take a little longer than before.
- Using postgres container allows us to create Docker images for different Atmosphere versions **without** a database so that nothing is leaked, but then users can add a database file at startup, or use an existing database container.
- Database dump documentation

### Removed
None.
