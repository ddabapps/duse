# Changelog

This is the change log for DelphiDabbler _DUSE_.

All notable changes to this project are documented in this file. Releases are listed in reverse version number order. The file format adheres closely to the recommendations of the [keep a changelog](https://keepachangelog.com/) project.

## [0.3.0] - 2023-06-23

> Program renamed from _Unit2NS_ to _DUSE_ at this release.

### Fixed

* Unreported bug where reading empty map files would cause an exception.

### Added

* New option to read a unit mapping by reading the names of `.dcu` files from a given directory. Added new _Read Units From DCU Folder_ button to _New Mapping_ and _Edit Mapping_ dialogue boxes [issue #13].
* Added key board shorcuts [issue #28]:
  * Ctrl+C to copy a selected fullly qualified unit name to clipboard.
  * Ctrl+U to find unit scopes for a given unit.
* Added version number entry to `config.data` file, beginning with v1 [issue #26].
* New "Contents" section added to `README.md`.

### Changed

* Renamed program to _DUSE_ [issue #20]:
  * Changed names of 64 and 32 bit executable files to `DUSE.exe` and `DUSE32.exe` respectively.
  * Updated program name that appears in GUI.
  * Updated version information to use new program name.
  * Changed header line of unit map files to use new name and bumped version number to v2.
  * Updated all affected documentation.
  * Updated deployment script re changed executable file names and to use new program name in generated zip file names.
* Updated UI and documentation with new repository name and URL following transfer to GitHub repository from `delphidabbler/unit2ns` to `ddabapps/duse`.
* Corrected UI, documentation and version information to refer to "unit scope names" instead of "namespaces" [issue #19]. Also revised program icon so it no longer contains the text "ns".
* Further minor corrections to GUI.
* "Mini-help" section of `README.md` updated:
  * Re new features added in this release.
  * Re new feature added in v0.2.0 [issue #21].

## [0.2.1] - 2022-11-03 [HOTFIX]

Released as _Unit2NS_.

### Fixed

* Fixed bugs in New Mapping and Edit Mapping dialogue boxes:
  * Group box was shifted out of alignment [issue #22]
  * Tab order was broken [issue #23]
  * Some errors in help text section

## [0.2.0] - 2022-11-02

Released as _Unit2NS_.

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

Released as _Unit2NS_.

### Fixed

* Memory leak caused by deleting mappings [issue #11].
* Malformed error messages [issue #10].
* Removed some redundant code [issues #5, #9 & #12].

### Changed

* Removed Android build targets from `.dproj` file.
* Updates, corrections and clarifications in `README.md`.

## [0.1.1] - 2021-10-01 [HOTFIX]

Released as _Unit2NS_.

### Fixed

* Memory leak [issue #1].

### Added

* Debug builds now detect memory leaks.

### Changed

* Change compiler & `.dproj` file format to Delphi 11 Alexandria from Delphi 10.4.1 Sydney.
* Minor edits to `README.md`

## [0.1.0] - 2021-02-08

Released as _Unit2NS_.

**Initial beta release.**

[0.3.0]: https://github.com/ddabapps/duse/compare/v0.2.1-beta...v0.3.0
[0.2.1]: https://github.com/ddabapps/duse/compare/v0.2.0-beta...v0.2.1-beta
[0.2.0]: https://github.com/ddabapps/duse/compare/v0.1.2-beta...v0.2.0-beta
[0.1.2]: https://github.com/ddabapps/duse/compare/v0.1.1-beta...v0.1.2-beta
[0.1.1]: https://github.com/ddabapps/duse/compare/v0.1.0-beta...v0.1.1-beta
[0.1.0]: https://github.com/ddabapps/duse/tree/v0.1.0-beta
