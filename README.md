# double-triple-click.kak

This is a [kakoune](http://kakoune.org) plugin that recreates the double- / triple-click functionality of your favourite graphical editor.

I've created this plugin with people new to kakoune (and modal editors in general) in mind. Many veterans prefer to do everything by keyboard-and I encourage you to explore this philosophy!-but with this small extension, you can quickly add familiar mouse operations to a new installation of kakoune, and use them just as you would do in your favourite graphical editor or IDE. 

For advanced users, there is the option to turn off the default functionality completely, and create your own using a new set of hooks.

## Installation

You can just pop double-triple-click.kak into your autoload folder, on Linux: `~/.config/kak/autoload/`.

It's worth using [plug.kak](https://github.com/andreyorst/plug.kak) to manage your plugins. Add the following to your kakrc:
```
plug 'sawdust-and-diamonds/double-triple-click.kak'
```

## Usage (Default)

Simply install, and double- or triple- clicking should work as in most IDEs. Double-click a word to select it, or triple-click to select a whole line.

## Usage (Customized behaviour)

The plugin adds four new hooks to help manage your own custom behaviour for double- and triple-clicks:

```
NormalDoubleClick
NormalTripleClick
InsertDoubleClick
InsertTripleClick
```

Each of these act in a similar way. They are simply called when the required event happens. To alter the default behaviour, re-bind them after the line where you've put `plug 'sawdust-and-diamonds/double-triple-click.kak'` in your kakrc. Below are some examples of how to do this:

##### Triple-click to select a paragraph

```
hook global NormalTripleClick %{ exec '<a-a>p' }
hook global InsertTripleClick %{ exec '<a-;><a-a>p' }
```

##### Double-click to go to defintion in LSP, select word otherwise (requires LSP plugin)
```
hook global NormalDoubleClick %sh{
    # ... do some stuff here
}
hook global InsertDoubleClick %sh{
    # ... do some stuff here
}
```

## Other cool plugins recommended for beginners


## License

I'm distributing this under the UNLICENSE because I want you to use the double-click functionality.

Perhaps one day, however, there might even be a native NormalDoubleClick hook in the compiled kakoune binaries :).
