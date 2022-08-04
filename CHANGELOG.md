# Changelog

This is the change log for _unit2ns_ by DelphiDabbler.

All notable changes to this project are documented in this file. Releases are listed in reverse version number order. The file format adheres closely to the recommendations of the [keep a changelog](https://keepachangelog.com/) project.

The version numbering attempts to adhere to the principles of [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2022-08-04

### Fixed

* Memory leak caused by deleting mappings [issue #11].
* Malformed error messages [issue #10].
* Removed some redundant code [issues #5, #9 & #12].

### Changed

* Removed Android build targets from `.dproj` file.
* Updates, corrections and clarifications in `README.md`.

## [0.1.1] - 2021-10-01 [HOTFIX]

### Fixed
  * Memory leek [issue #1].

### Added
  * Debug builds now detect memory leeks.

### Changed
* Change compiler & `.dproj` file format to Delphi 11 Alexandria from Delphi 10.4.1 Sydney.
* Minor edits to `README.md`

## [0.1.0] - 2021-02-08

Initial beta release.

[0.1.2]: https://github.com/delphidabbler/unit2ns/compare/v0.1.1-beta...v0.1.2-beta
[0.1.1]: https://github.com/delphidabbler/unit2ns/compare/v0.1.0-beta...v0.1.1-beta
[0.1.0]: https://github.com/delphidabbler/unit2ns/tree/v0.1.0-beta
