# unit2ns

A little tool for Delphi programmers to find the unit scope(s) that a unit belongs to.

## Introduction

Since the introduction of unit scopes to Delphi I've been struggling to remember the names of the unit scopes that some units belong to. OK, sometimes the code editor pops up a list of units in a unit scope, but what I want is to type in a unit name and be told what unit scopes(s) the unit may belong to. Hence _Unit2NS_.

## Installation, Updating & Removal

### Installing

_Unit2NS_ is available as either a 32 bit or 64 bit Windows application. Download the appropriate version from the _Releases_ tab on [GitHub](https://github.com/delphidabbler/unit2ns). The program comes in a zip file which you should unzip.

There is no installer for this simple program. Simply copy the `.exe` file to a folder on your computer or on a USB drive. If you have the 32 bit version the executable file is named `Unit2NS32.exe` while the 64 bit version is `Unit2NS64.exe`. You can copy this `README.md` file to the same location if you wish.

When it is first run, _Unit2NS_ will write data to a `config` sub-directory of whichever folder you put it in. For that reason you may prefer to place the program in its own folder.

> **DO NOT** place _Unit2NS_ in your system's program files folder since the system will probably prevent it from writing the necessary data files.

### Updating

To update the program simply download a newer version and overwrite the `.exe` file in whichever location you installed it. Be careful not to delete the `config` subdirectory otherwise you will loose your data.

### Uninstalling

To uninstall the program simply delete the `.exe` file from wherever you installed it. If you have no further use for the program's data then delete the `config` sub-directory and all its contents too.

## Mini-help

_Unit2NS_ is in very early beta, and there's no proper help system as yet. So this is all you get right now!

### Getting started

_Unit2NS_ uses what it calls "mappings" to look up the names of unit scopes that a given unit may belong to. The idea is you can have different mappings for different versions of Delphi. So, before you can start using it you need to create at least one mapping.

To do this, start the program and click the _New Mapping_ button. In the resulting dialogue box the first thing to do is to give the mapping a sensible name.

Now you need to provide it with a list of unit scopes and the units that belong to them. There are three ways to do this at present:

1. The long winded way is to enter a fully specified unit name (e.g. `System.SysUtils`) in the edit box above the _Add_ button, then click _Add_. Keep doing this until you've entered all the units you need. Tedious huh?

2. A much easier method is to choose the _Read Units From Source Folder_ button. This opens a dialogue box where you choose a directory containing some Pascal source code. Selecting a folder causes every Pascal unit in that folder, and all it's sub-folders, to be read into the mapping. So, if you choose your version of Delphi's `source` folder you'll load every unit Delphi provides into your new mapping. You'll also get quite a few you probably don't want, but that's not really a problem. You can delete any units you don't want by selecting them in the list and clicking the _Delete_ button.

3. If you have one or more versions of Delphi installed that support unit scopes (i.e. Delphi XE2 & later) you can just click the _Read Units From Delphi Installation_ button. This displays a list of all supported installed versions of Delphi in a dialogue box. Choose an  installation and click OK. The units from that version of Delphi's `source` directory will be loaded into your new mapping without you having to locate them.

Once you're done click the _Save And Close_ button to save the mapping.

The new mapping will appear in the _Mappings_ drop down at the top of the main window, along with any others you've created. All mappings are saved in the `config` folder alongside the executable program and are loaded automatically the next time you start _Unit2NS_.

### General use

When you need to know what unit scope a unit belongs to, enter the unit's name in the _Name of unit_ edit box in the main window. Click _Find unit scope(s)_ and the names of any unit scopes containing a unit of the given name will appear in the list box below. Selecting the unit scope name you want then clicking _Copy Full Name_ puts the fully specified unit name on the clipboard ready for pasting into your code.

You will sometimes see a unit scope named `<no unit scope>`. That's just a dummy that indicates that the unit exists outside any uit scope. When the `<no unit scope>` is selected clicking _Copy Full Name_ simply puts the unqualified unit name on the clipboard.

There's another little feature you might find useful if Delphi's code editor doesn't feel like showing you all the units belonging to a unit scope. In the _Lookup units in unit scope_ box you can select the name of any unit scope from the _Choose unit scope_ drop down to reveal all its units in the list below. This time selecting `<no unit scope>` reveals all the units that exist outside any unit scope.

You can create new mappings, edit them or delete them whenever you wish. The buttons to do that are pretty self-explanatory!

At present you can't rename a mapping.

## License

_Unit2NS_ is copyright © 2021-2022, Peter Johnson (delphidabbler.com) and is released under the MIT license. See the [`LICENSE`](https://github.com/delphidabbler/unit2ns/blob/master/LICENSE) file included in the root of the GitHub repository for details.

## Changelog

See the file [CHANGELOG.md](https://github.com/delphidabbler/unit2ns/blob/master/CHANGELOG.md) in the root of the GitHub repository for details of releases and changes.

## Contributing

Contributions are welcome. The source code is in the [`delphidabbler/unit2ns`](https://github.com/delphidabbler/unit2ns) project on GitHub.

I'm using the [Git Flow](https://nvie.com/posts/a-successful-git-branching-model/) methodology.

Please make a fork from the `develop` branch (**not** `master`) and create a new feature branch† for your code. When ready please submit a pull request.

> † Feature branches should be named in the form `feature/my-feature-name`. If you're fixing/implementing an issue then please prepend the issue number to the branch name like this `feature/#99-abbreviated-issue-name`.

### Compiling From Source

_Unit2NS_ is written in Delphi Object Pascal and developed using Delphi 11 Alexandria (Delphi 10.4.1 Sydney was used for v0.1.0-beta). The program can be compiled from within the IDE.

## Bugs and Feature Requests

It's early days yet, so bugs are likely. Bug reports are welcomed. Please use the GitHub project's [_Issues_](https://github.com/delphidabbler/unit2ns/issues) feature to do that. Bug **fixes** are even more welcome!

You can also request new features. I want to keep this little app simple, but I can see several ways in which it can be improved, so don't hesitate to suggest something.
