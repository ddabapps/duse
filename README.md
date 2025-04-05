# duse

A little tool for Delphi programmers to find the unit scope(s) that a unit belongs to.

## Contents

* [Introduction](#introduction)
* [Installation, Updating & Removal](#installation-updating--removal)
* [Mini-help](#mini-help)
* [License](#license)
* [Changelog](#changelog)
* [Contributing](#contributing)
* [Bugs and Feature Requests](#bugs-and-feature-requests)

## Introduction

Since the introduction of unit scopes to Delphi I've been struggling to remember the names of the unit scopes that some units belong to. OK, sometimes the code editor will pop up a list of units in a unit scope, but what I want is to type in a unit name and be told what unit scopes(s) the unit may belong to. Hence _DUSE_.

And the name? **D**elphi **U**nit **S**cope **E**xpander.

## Installation, Updating & Removal

### Installation

_DUSE_ is available as both 64 bit and 32 bit Windows applications. You should _always_ use the 64 bit version if you're running 64 bit Windows and _only_ use the 32 bit version if you're running 32 bit Windows.

The 64 and 32 bit versions are distributed in separate zip files named `duse-64bit-<version>.zip` and `duse-32bit-<version>.zip` respectively, where `<version>` is the release version number. Download the appropriate version from the _Releases_ tab on [GitHub](https://github.com/ddabapps/duse) and unzip the file.

The 64 bit program is named `DUSE.exe` while the 32 bit program is named `DUSE32.exe`. There is no installer. You simply need to copy the appropriate `.exe` file to a folder on your computer or on a USB drive. You can copy this `README.md` file to the same location if you wish.

When it is first run, _DUSE_ will write data to a `config` sub-directory of whichever folder you put it in. For that reason you may prefer to place the program in its own folder.

> **DO NOT** place _DUSE_ in your system's program files folder since the system will probably prevent it from writing the necessary data files.

### Updating

To update the program simply download a newer version and overwrite the appropriate `.exe` file in whichever location you installed it. Be careful not to delete the `config` subdirectory otherwise you will loose your data.

> 🗒️ If you are updating from v0.2.1-beta or earlier then the existing file name will be either `Unit2NS64.exe` (64 bit) or `Unit2NS32.exe` (32 bit). Delete that file and copy in either `DUSE.exe` or `DUSE32.exe` in its place. It remains important to preserve the `config` sub-directory and its content.

### Removing

To uninstall the program simply delete the `.exe` file from wherever you installed it. If you have no further use for the program's data then delete the `config` sub-directory and all its contents too.

## Mini-help

_DUSE_ is in very early beta, and there's no proper help system as yet. So this is all you get right now!

### Getting started

_DUSE_ uses what it calls "mappings" to look up the names of unit scopes that a given unit may belong to. The idea is you can have different mappings for different versions of Delphi. So, before you can start using it you need to create at least one mapping.

To do this, start the program and click the _New Mapping_ button. In the resulting dialogue box the first thing to do is to give the mapping a sensible name.

Now you need to provide it with a list of unit scopes and the units that belong to them. There are four ways to do this at present:

1. The long winded way is to enter a fully specified unit name (e.g. `System.SysUtils`) in the edit box above the _Add_ button, then click _Add_. Keep doing this until you've entered all the units you need. Tedious huh?

2. A much easier method is to choose the _Read Units From Source Folder_ button. This opens a dialogue box where you choose a directory containing some Pascal source code. Selecting a folder causes every Pascal unit in that folder, and all it's sub-folders, to be read into the mapping. So, if you choose your version of Delphi's `source` folder you'll load every unit Delphi provides into your new mapping. You'll get quite a few units you probably don't want, but that's not really a problem. You can delete any units you don't want by selecting them in the list and clicking the _Delete_ button.

3. Closely related to the previous option is to choose the _Read Units From DCU Folder_ button. This allows you to choose a directory containing `.dcu` files instead of `.pas` files.

4. If you have one or more versions of Delphi installed that support unit scopes (i.e. Delphi XE2 & later) you can just click the _Read Units From Delphi Installation_ button. This displays a list of all supported installed versions of Delphi in a dialogue box. Choose an  installation and click OK. The units from that version of Delphi's `source` directory will be loaded into your new mapping without you having to locate them.

Once you're done click the _Save And Close_ button to save the mapping.

The new mapping will appear in the _Mappings_ drop down at the top of the main window, along with any others you've created. All mappings are saved in the `config` folder alongside the executable program and are loaded automatically the next time you start _DUSE_.

### General use

When you need to know what unit scope a unit belongs to, enter the unit's name in the _Name of unit_ edit box in the main window. Click _Find unit scope(s)_ (or press _Ctrl+U_) and the names of any unit scopes containing a unit of that name will appear in the list box below. Selecting the unit scope name you want then clicking _Copy Full Name_ (or pressing _Ctrl+C_) puts the fully specified unit name on the clipboard ready for pasting into your code.

You will sometimes see a unit scope named `<no unit scope>`. That's just a dummy that indicates that the unit exists outside any unit scope. When the `<no unit scope>` is selected clicking _Copy Full Name_ simply puts the unqualified unit name on the clipboard.

There's another little feature you might find useful if Delphi's code editor doesn't feel like showing you all the units belonging to a unit scope. In the _Lookup units in unit scope_ box you can select the name of any unit scope from the _Choose unit scope_ drop down to reveal all its units in the list below. Selecting `<no unit scope>` reveals all the units that exist outside any unit scope.

You can create new mappings, edit them or delete them whenever you wish. The buttons to do that are pretty self-explanatory!

You can't rename a mapping.

## License

_DUSE_ is copyright © 2021-2025, Peter Johnson (delphidabbler.com) and is released under the MIT license. See the [`LICENSE`](https://github.com/ddabapps/duse/blob/master/LICENSE) file included in the root of the GitHub repository for details.

## Changelog

See the file [CHANGELOG.md](https://github.com/ddabapps/duse/blob/master/CHANGELOG.md) in the root of the GitHub repository for details of releases and changes.

## Contributing

Contributions are welcome. The source code is in the [`ddabapps/duse`](https://github.com/ddabapps/duse) project on GitHub.

I'm using the [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/) methodology.

Please make a fork from the `develop` branch (**not** `master`) and create a new feature branch† for your code. When ready please submit a pull request.

> † Feature branches should be named in the form `feature/my-feature-name`. If you're fixing/implementing an issue then please prepend the issue number to the branch name like this `feature/#99-abbreviated-issue-name`.

### Compiling From Source

_DUSE_ is written in Delphi Object Pascal and developed using Delphi 11 Alexandria (Delphi 10.4.1 Sydney was used for v0.1.0-beta). The program can be compiled from within the IDE.

## Bugs and Feature Requests

It's early days yet, so bugs are likely. Bug reports are welcomed. Please use the GitHub project's [_Issues_](https://github.com/ddabapps/duse/issues) feature to do that. Bug **fixes** are even more welcome!

You can also request new features. I want to keep this little app simple, but I can see several ways in which it can be improved, so don't hesitate to suggest something.
