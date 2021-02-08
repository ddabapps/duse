# Release Builds & Deployment

_Unit2NS_ is written in Delphi Pascal and was developed using Delphi 10.4.1 Sydney. Debug builds and draft releases can be built entirely from within the Delphi IDE.

Releases for deployment are created using the `Deploy.bat` script that can be found in the Git repository root.

The script depends on both _MSBuild_ and _InfoZip_'s version of `zip.exe`.

The required environment is set up by starting the Delphi Sydney RAD Studio Command Prompt from the Windows start menu and then:

1. Create an environment variable named `ZipRoot` that must be set to the directory containing `zip.exe`.

2. `cd` into the project folder where the Git repository was cloned.

3. Run `Deploy.bat` passing a suitable version number on the command line. Version numbers should be in the form `9.9.9` or `9.9.9-beta`.

The script will now build both the Windows 32 and 64 bit release versions of the program. The resulting `.exe` files are renamed `Unit2NS32.exe` and `Unit2NS64.exe` respectively.

The `.exe` files are then compressed into separate `.zip` files, one each for the 32 bit and 64 bit release. A read-me file then added to the `.zip` files.

The `.zip` files are named `unit2ns-64bit-<version>.zip` and `unit2ns-64bit-<version>.zip` where `<version>` is the version number passed on the command line. The zip files will be placed in the `_build\release` subdirectory of the project folder.

The `.zip` files are then deployed.

Finally the whole `_build` directory can be deleted.
