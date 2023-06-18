# Changelog

This is the change log for _unit2ns_ by DelphiDabbler.

All notable changes to this project are documented in this file. Releases are listed in reverse version number order. The file format adheres closely to the recommendations of the [keep a changelog](https://keepachangelog.com/) project.

The version numbering attempts to adhere to the principles of [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.1] - 2022-11-03 [HOTFIX]

### Fixed

* Fixed bugs in New Mapping and Edit Mapping dialogue boxes:
  * Group box was shifted out of alignment [issue #22]
  * Tab order was broken [issue #23]
  * Some errors in help text section

## [0.2.0] - 2022-11-02

### Fixed

* Fixed potential access to method of nil object in configuration code [issue #16]
* Fixed memory leak when sorting units in a mapping [issue #17]
* Fixed and updated documentation [issue #14, PR #15]:
  * Overhauled `Deployment.md` re change from compiling with Delphi 10.4 to Delphi 11.
  * Overhauled `README.txt`.

### Added

* New button on mapping editor & associated new dialogue box to choose an installed version of Delphi from whose source code directory to read units into a mapping. [issue #8]

### Changed

* Switched off all automatic version numbering on .dproj file.
* Refactored some code.
* Corrected comments in `Deploy.bat`.

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
  * Memory leak [issue #1].

### Added
  * Debug builds now detect memory leaks.

### Changed
* Change compiler & `.dproj` file format to Delphi 11 Alexandria from Delphi 10.4.1 Sydney.
* Minor edits to `README.md`

## [0.1.0] - 2021-02-08

Initial beta release.

[0.2.1]: https://github.com/ddabapps/duse/compare/v0.2.0-beta...v0.2.1-beta
[0.2.0]: https://github.com/ddabapps/duse/compare/v0.1.2-beta...v0.2.0-beta
[0.1.2]: https://github.com/ddabapps/duse/compare/v0.1.1-beta...v0.1.2-beta
[0.1.1]: https://github.com/ddabapps/duse/compare/v0.1.0-beta...v0.1.1-beta
[0.1.0]: https://github.com/ddabapps/duse/tree/v0.1.0-beta
