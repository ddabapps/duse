# unit2ns

A little tool for Delphi programmers to find the namespace(s) that a unit belongs to.

## Introduction

Since the introduction of namespaces to Delphi I've been struggling to remember which namespaces some units belong to. OK, sometimes the code editor pops up a list of unit names in a namespace, but what I want is to type in a unit name and be told what namespace(s) the unit may belong to. Hence _Unit2NS_.

## Installation, Updating & Removal

### Installing

_Unit2NS_ is available is either a 32 bit or 64 bit Windows application. Download the appropriate version from the _Releases_ tab on [GitHub](https://github.com/delphidabbler/unit2ns). The program comes in a zip file which you should unzip.

There is no installer for this simple program. Simply copy the `.exe` file to a folder on your computer or on a USB drive. If you have the 32 bit version the executable file is named `Unit2NS32.exe` while the 64 bit version is `Unit2NS64.exe`. You can copy this `README` file to the same location if you wish.

When it is first run, _Unit2NS_ will write data to a `config` sub-directory of whichever folder you put it in. For that reason you may prefer to place the program in its own folder.

**DO NOT** place _Unit2NS_ in your system's program files folder since the system will probably prevent it from writing the necessary data files.

### Updating

To update the program simply download a newer version and overwrite the `.exe` file in whichever location you installed it. Be careful not to delete the `config` subdirectory otherwise you will loose your data.

### Uninstalling

To uninstall the program simply delete the `.exe` file from wherever you installed it. If you have no further use for the program's data then delete the `config` sub-directory and all its contents too.

## Mini-help

_Unit2NS_ is in very early beta, and there's no proper help system as yet. So this is all you get right now!

### Getting started

_Unit2NS_ uses what it calls "mappings" to look up up namespaces for a given unit. The idea is you can have different mappings for different versions of Delphi. So, before you can start using it you need to provide a at least one mapping.

To do this, start the program and click the _New Mapping_ button. In the resulting dialogue box first give the mapping a sensible name.

Now you need to provide it with a list of namespaces and units. There are two ways to do this at present. The first is to enter a fully specified unit name in the edit box above the _Add_ button, e.g. `System.SysUtils` and then click _Add_. Keep doing this until you've entered all the units you need. Tedious huh?

Secondly you can choose the _Read Units From Source Folder_ button. This opens a dialogue box where you choose a directory containing some Pascal source code. Selecting a folder causes every Pascal unit in that folder, and all it's sub-folders, to be read into the mapping. So, if you choose your version of Delphi's `source` folder you'll load every unit Delphi provides into your new mapping. You'll also get quite a few you probably don't want, but that's not really a problem. You can delete any units you don't want by selecting them in the list and clicking the _Delete_ button.

Once you're done click the _Save And Close_ button to save the mapping.

The new mapping will appear in the _Mappings_ drop down at the top of the main window, along with any others you've created. All mappings are saved in a `config` folder alongside the executable program and are loaded automatically the next time you start _Unit2NS_.

### General use

When you need to know what namespace a unit is in, enter it's name in the _Name Of Unit_ edit box of the main window. Click _Find Namespace(s)_ and any namespaces containing a unit of that name will appear in the list box below. Selecting the namespace you want then clicking _Copy Full Name_ puts the fully specified namespace and unit name on the clipboard ready for pasting into your code.

You will sometimes see a namespace called `<no namespace>`. That's just a dummy that indicates that the unit exists outside any namespace. When the dummy namespace is selected clicking _Copy Full Name_ simply puts the unqualified unit name on the clipboard.

There's another little feature you might find useful if Delphi's code editor doesn't feel like showing you all the unit names in a namespace. In the _Lookup units in namespace_ box you can select any namespace from the _Choose namespace_ drop down to reveal all its units in the list below. This time selecting `<no namespace>` reveals all the units that exist outside a namespace.

You can create new mappings, edit them or delete them whenever you wish. The buttons to do that are pretty self-explanatory!

At present you can't rename a namespace.

## License

_Unit2NS_ is copyright © 2021, Peter Johnson (delphidabbler.com) and is released under the MIT license. See the [`LICENSE`](https://github.com/delphidabbler/unit2ns/blob/master/LICENSE) file included in the root of the GitHub repository for details.

## Changelog

See the file [CHANGELOG.md](https://github.com/delphidabbler/unit2ns/blob/master/CHANGELOG.md) in the root of the GitHub repository for details of releases and changes.

## Contributing

Contributions are welcome. The source code is on GitHub at https://github.com/delphidabbler/unit2ns.

Please make a fork from the `develop` branch (**not** `master`) and create an new feature branch for your code. When ready please submit a pull request.

### Compiling From Source

_Unit2NS_ is written in Delphi Object Pascal and developed using Delphi 10.4.1 Sydney. The program can be compiled from within the IDE.

## Bugs and Feature Requests

It's early days yet, so bugs are likely. Bug reports are welcomed. Please use the GitHub project's [_Issues_](https://github.com/delphidabbler/unit2ns/issues) feature to do that. Bug **fixes** are even more welcome!

You can also request new features. I want to keep this little app simple, but I can see several ways in which it can be improved, so don't hesitate to suggest something.
