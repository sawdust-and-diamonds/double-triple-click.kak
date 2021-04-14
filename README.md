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

The plugin adds four new interfaces to the User hook for custom double- and triple-click behaviour:

```
NormalDoubleClick
NormalTripleClick
InsertDoubleClick
InsertTripleClick
```

Each of these act in a similar way--they're simply called when the required event happens. To alter the default behaviour, re-bind them after the line where you've put `plug 'sawdust-and-diamonds/double-triple-click.kak'` in your kakrc. Below are some examples of how to do this:

##### Triple-click to select a paragraph
```
hook global User NormalTripleClick %{ exec '<a-a>p' }
hook global User InsertTripleClick %{ exec '<a-;><a-a>p' }
```

##### Double-click to go to definition in LSP, select word otherwise (requires LSP plugin)
```
hook global User NormalDoubleClick %sh{
    cur_sel=$kak_val_selection
    echo "try %{lsp-definition} catch %{nop}"
    echo "eval %sh{[ \$kak_val_selection = $cur_sel ] && echo \"exec '<a-a>w'\"}"
}
hook global User InsertDoubleClick %sh{
    cur_sel=$kak_val_selection
    echo "try %{lsp-definition} catch %{nop}"
    echo "eval %sh{[ \$kak_val_selection = $cur_sel ] && echo \"exec '<a-;><a-a>w'\"}"
}
```

## Other cool plugins recommended for beginners
[kak-lsp](https://github.com/kak-lsp/kak-lsp)
[kakoune.cr](https://github.com/alexherbo2/kakoune.cr) -- The main way to access kak from outside of kak
[kakoune-mirror](https://github.com/Delapouite/kakoune-mirror) -- Great example of a cool & useful new user mode
[kakoune-themes](https://github.com/anhsirk0/kakoune-themes/) -- Best repository of lovely new themes

## License

I want to distribute this under the UNLICENSE because I would like you to consider how to use the double-click functionality in your own user modes in your own projects. Alternatively, if this does not apply, please refer to the MIT license.

Perhaps one day, however, there might even be a native NormalDoubleClick hook in the compiled kakoune binaries :).
