# unit2ns

A little tool for Delphi programmers to find the namespace(s) that a unit belongs to.

## Introduction

Since the introduction of namespaces to Delphi I've been struggling to remember which namespaces some units belong to. OK, sometimes the code editor pops up a list of unit names in a namespace, but what I want is to type in a unit name and be told what namespace(s) the unit may belong to. Hence _unit2ns_.

## Download & Installation

_unit2ns_ is available is either a 32 bit or 64 bit Windows application. Download the appropriate version from the releases tab on GitHub.

At present _unit2ns_ is strictly a portable app and comes with no installer. Simply copy `Unit2NS.exe` to a suitable folder on your system. This must be a folder where the program has write access because the program stores data in a sub-folder of the directory where you place it. For this reason **do not install in your system's `%ProgramFiles%` folder.**

## Mini-help

_unit2ns_ is in very early beta, and there's no proper help system as yet. So this is all you get right now!

### Getting started

_unit2ns_ uses what it calls "mappings" to look up up namespaces for a given unit. The idea is you can have different mappings for different versions of Delphi. So, before you can start using it you need to provide a at least one mapping.

To do this, start the program and click the _New Mapping_ button. In the resulting dialogue box first give the mapping a sensible name.

Now you need to provide it with a list of namespaces and units. There are two ways to do this at present. The first is to enter a fully specified unit name in the edit box above the _Add_ button, e.g. `System.SysUtils` and then click _Add_. Keep doing this until you've entered all the units you need. Tedious huh?

Secondly you can choose the _Read Units From Source Folder_ button. This opens a dialogue box where you choose a directory containing some Pascal source code. Selecting a folder causes every Pascal unit in that folder, and all it's sub-folders, to be read into the mapping. So, if you choose your version of Delphi's `source` folder you'll load every unit Delphi provides into your new mapping. You'll also get quite a few you probably don't want, but that's not really a problem. If you want to be fussy, get busy select the units you don't want in the mapping list and click the _Delete_ button.

Once you're done click the _Save And Close_ button to save the mapping.

The new mapping will appear in the _Mappings_ drop down at the top of the main window, along with any others you've created. All mappings are saved in a folder alongside the executable program and are loaded automatically the next time you start _unit2ns_.

### General use

When you need to know what namespace a unit is in enter it's name in the _Name Of Unit_ edit box of the main window. Click _Find Namespace(s)_ and any namespaces containing a unit of that name will appear in the list box below. Selecting the namespace you want then clicking _Copy Full Name_ puts the fully specified namespace and unit name on the clipboard ready for pasting into your code.

You will sometimes see a namespace called `<no namespace>`. That's just to confirm that the unit exists outside any namespace. When that is selected clicking _Copy Full Name_ simply puts the unit name on the clipboard.

There's another little feature you might find useful if Delphi's code editor doesn't feel like telling you all the unit names in a namespace. In the _Lookup units in namespace_ box you can select any namespace from the _Choose namespace_ drop down to reveal all its units in the list below. This time selecting `<no namespace>` reveals all the units that exist outside a namespace.

You can create new mappings, edit them or delete them whenever you wish. The buttons to do that are pretty self-explanatory!

## License

_unit2ns_ is copyright (c) 2021, Peter Johnson (delphidabbler.com) and is released under the MIT license. See the `LICENSE` file included in the root of the GitHub repository for details.

## Changelog

See the file CHANGELOG.md in the root of the GitHub repository for details of releases and changes.

## Contributing

Contributions are welcome. The source code is on GitHub at https://github.com/delphidabbler/unit2ns.

Please make a fork from the `develop` branch (**not** `master`) and create an new feature branch for your code. When ready please submit a pull request.

## Bugs and Feature Requests

It's early days so the program likely has bugs, so bug reports are welcomed. Please use the GitHub project's _Issues_ feature to do that. Bug **fixes** are even more welcome!

You can also request new features - I want to keep this little app simple, but I can see several ways in which it can be improved, so don't hesitate to suggest something.

## Web page

In due course the app will have its own little web page on delphidabbler.com, but it's not available just yet.
