# Building & Deploying Releases

_DUSE_ is written in Delphi Pascal and was developed using Delphi 12 Athens.

While debug builds and draft releases can be built entirely from within the Delphi IDE, releases for deployment are created using the `Deploy.bat` script that can be found in the Git repository root. The script uses _MSBuild_ and requires _InfoZip_'s version of [`zip.exe`](https://delphidabbler.com/extras/info-zip) to be installed.

To create a release build using `Deploy.bat` proceed as follows:

1. Start the Delphi 12 Athens RAD Studio Command Prompt from the Windows start menu.

2. Create an environment variable named `ZipRoot` whose value is the fully specified name of the directory containing `zip.exe`, without a trailing backslash. E.g.:

    ```shell
    set ZipRoot=C:\Utils
    ```

3. If you have not already done so, `cd` into some suitable directory then `git clone` the source code from [GitHub](https://github.com/ddabapps/duse). E.g.:
    
    ```shell
    cd D:\Projects
    git clone https://github.com/ddabapps/duse.git duse
    ```

4. `cd` into the `duse` directory.

5. Run `Deploy.bat` passing the release's version number as a parameter. Version numbers should be in the form `9.9.9` or `9.9.9-beta`. E.g.:

    ```shell
    Deploy 0.3.4-beta
    ```

The script will now build both the Windows 64 and 32 bit release versions of the program. The resulting `.exe` files will be named `DUSE.exe` and `DUSE32.exe` respectively.

Each `.exe` file is then compressed into a separate `.zip` file. A read-me file is included in each `.zip` file. The files are named `duse-32bit-<version>.zip` and `duse-64bit-<version>.zip` where `<version>` is the version number that was passed to `Deploy.bat`. The zip files will be created in the `_build\release` subdirectory.

The `.zip` files can then be deployed.

Finally the whole `_build` subdirectory can be deleted.
