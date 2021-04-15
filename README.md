# double-triple-click.kak

This is a [kakoune](http://kakoune.org) plugin that recreates the familiar double- and triple-click functionality of your favourite graphical editor.

I've created this plugin with people new to kakoune (and modal editors in general) in mind. Many veterans prefer to do everything by keyboard—and I definitely encourage you to explore this philosophy!—but with this small extension, you can quickly add familiar mouse operations to a new installation of kakoune, and start selecting words and lines with mouse clicks, just as you would in your favourite graphical editor or IDE. 

For advanced users, there is the option to turn off the default functionality completely, and create your own using a new set of hooks.

## Installation

You can just pop double-triple-click.kak into your autoload folder—on Linux, it's at: `~/.config/kak/autoload/`.

It's worth using [plug.kak](https://github.com/andreyorst/plug.kak) to manage your plugins. Add the following to your kakrc (after the line where you load plug itself, of course):
```
plug 'sawdust-and-diamonds/double-triple-click.kak'
```

## Usage (Default)

Simply install, and start double- or triple-clicking—it should work just as it does in most IDEs. Double-click a word to select it, or triple-click to select a whole line.

The plugin is not yet correctly configured to handle multiple selections, but please expect this in the next update.

## Customizing

The plugin adds eight new interfaces to the User hook for custom double- and triple-click behaviour:

```
NormalDoubleClickPress
NormalTripleClickPress
InsertDoubleClickPress
InsertTripleClickPress
NormalDoubleClickRelease
NormalTripleClickRelease
InsertDoubleClickRelease
InsertTripleClickRelease
```

It seems like a lot, but these hooks only contain three bits of information: User mode, click count and press/release status.

Each of these act in a similar way—they're simply sent as parameters to the User hook when the required event happens. To alter the default behaviour, first disable the default hooks by setting `disable_doubleclick_defaults` to **true**, which you must do in your kakrc. Then, you can re-bind them (anywhere after the line where you've put `plug 'sawdust-and-diamonds/double-triple-click.kak'` in your kakrc, if you're using plug). To read more about how hooks work, just type `:doc hooks` while in kakoune.

It's important to consider whether you want your functionality to trigger on the instant the mouse button is pressed, or later when it's released. Kakoune seems to process a mouse click twice, first on the press and secondly on the release. You probably want things to happen on the initial "press", but kakoune's behaviour may interfere with that (as it will reset the selection and cursor position on mouse release).

Much of the time, e.g. to select areas of text, you'll want to repeat the hook action in both cases, in which case, you'll only need to define four hooks using wildcards, like this:
```
hook window User NormalDoubleClick* %{...}
hook window User NormalTripleClick* %{...}
hook window User InsertDoubleClick* %{...}
hook window User InsertTripleClick* %{...}
```

I'm sure this is confusing, but if you play around with it, you'll soon see how strangely kak processes mouse clicks.

Hopefully it will help to have some concrete examples of how to implement new hooks:

##### Triple-click to select a paragraph
```
# Turn off the defaults
set-option window disable_doubleclick_defaults true

hook window User NormalTripleClick* %{ exec '<a-a>p' }
hook window User InsertTripleClick* %{ exec '<a-;><a-a>p' }

# Don't forget to re-implement other default hooks
hook window User NormalDoubleClick* %{ exec '<a-a>w' }
hook window User InsertDoubleClick* %{ exec '<a-;><a-a>w' }
```

##### Double-click to go to definition in LSP, select word otherwise (requires LSP plugin)
These are rather complicated, but should at least help you open up the possibility of doing cool new things:
```
set-option window disable_doubleclick_defaults true

hook global User NormalDoubleClickPress %sh{
    cur_sel=$kak_val_selection
    echo "try %{lsp-definition} catch %{nop}"
    echo "eval %sh{[ \$kak_val_selection = $cur_sel ] && echo \"exec '<a-a>w'\"}"
}
hook global User InsertDoubleClickPress %sh{
    cur_sel=$kak_val_selection
    echo "try %{lsp-definition} catch %{nop}"
    echo "eval %sh{[ \$kak_val_selection = $cur_sel ] && echo \"exec '<a-;><a-a>w'\"}"
}
```

### User options

Two options are defined:

`disable_doubleclick_defaults` lets you turn off (or on) the IDE-like behaviour.

`doubleclick_wait` sets the maximum time, in seconds, that kak will wait for you to complete a series of clicks.

## Other cool plugins recommended for beginners
[kak-lsp](https://github.com/kak-lsp/kak-lsp) — Turn kak into a modern IDE, with LSP support for any language that has one

[kakoune.cr](https://github.com/alexherbo2/kakoune.cr) — The main way to access kak from outside of kak

[kakoune-mirror](https://github.com/Delapouite/kakoune-mirror) — Great example of a cool & useful new user mode

[kakoune-themes](https://github.com/anhsirk0/kakoune-themes/) — Best repository of lovely new themes

## License

I leave this little scrap of code, for you, in the public domain under the UNLICENSE—because I would like you to consider how to use the multi-click functionality in your own user modes and in your own kakoune projects! Alternatively, if the public domain law does not apply in your country, please refer to the MIT license.

Perhaps one day, however, there might even be a native NormalDoubleClick hook in the compiled kakoune binaries 😁.
