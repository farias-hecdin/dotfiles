# 🆘 sos.nvim 🆘 <a href="https://github.com/tmillr/sos.nvim/releases/latest"><img style="padding-left: 4px; padding-top: 20px;" align="right" alt="GitHub release (latest SemVer)" src="https://img.shields.io/github/v/release/tmillr/sos.nvim?label=&logo=semver&sort=semver&color=%2328A745&labelColor=%23384047&logoColor=%23959DA5"/></a><a href="https://github.com/tmillr/sos.nvim/actions/workflows/format.yml"><img style="padding-left: 4px; padding-top: 20px;" align="right" alt="Format" src="https://github.com/tmillr/sos.nvim/actions/workflows/format.yml/badge.svg"/></a><a href="https://github.com/tmillr/sos.nvim/actions/workflows/ci.yml"><img style="padding-left: 0px; padding-top: 20px;" align="right" alt="CI" src="https://github.com/tmillr/sos.nvim/actions/workflows/ci.yml/badge.svg"/></a>

Never manually save/write a buffer again!

This plugin is an autosaver for Neovim that automatically saves all of your changed buffers according to a predefined timeout value. Its main goals are:

- To handle conditions/situations that `'autowriteall'` does not
- To offer a complete, set-and-forget autosave/autowrite solution that saves your buffers for you when you want/need them saved
- To offer at least some customization via options, as well as the ability to easily enable/disable
- To be better or more correct than `CursorHold` autosavers and not depend on `CursorHold` if feasible

### Additional Features

- Has its own independent timer, distinct from `'updatetime'`, which may be set to any value in ms
- Timer is only started/reset on buffer changes, not cursor movements or other irrelevant events
- Keeps buffers in sync with the filesystem by frequently running `:checktime` in the background for you (e.g. on `CTRL-Z` or suspend, resume, command, etc.)
- Intelligently ignores `'readonly'` and other such unwritable buffers/files (i.e. the writing of files with insufficient permissions must be attempted manually with `:w`)

For any questions, help with setup, or general help, you can try [discussions][q&a]. For issues, bugs, apparent bugs, or feature requests, feel free to [open an issue][issues] or [create a pull request][prs].

## Installation

Simply use your preferred method of installing Vim/Neovim plugins.

### Example using `Plug`

To install this plugin via Plug, add the following line to your vimrc/init file, plug file, or any other file that gets sourced during Neovim's initialization:

```vim
Plug 'tmillr/sos.nvim'
```

After doing this, you will need to then either restart Neovim or execute `:Plug 'tmillr/sos.nvim'` on the cmdline. That registers the plugin with Plug and updates Neovim's `'runtimepath'` option (which allows you to use `require("sos")` in lua). Next, execute `:PlugInstall` on the cmdline. `PlugInstall` will download/install any registered plugins missing from the filesystem. At this point you will have the plugin/repo, but it is not enabled/running yet. To enable the plugin on-the-fly, use `:lua=require("sos").setup()` or `:SosEnable` on the cmdline, although it is best and standard-practice to simply add the `setup()` call to one of your init files (e.g. add `require("sos").setup()` to your init.lua) so that the plugin is started/enabled automatically during Neovim startup.

## Setup/Options

Listed below are all of the possible options that can be configured along with their default values. Missing options will retain their current value (which will be their default value if never previously set, or if this is the first time calling `setup()` in this Neovim session). This means that `setup()` can be used later on to change just a single option while not touching/changing/resetting to default any of the other options. You can also pass `true` as a 2nd argument to `setup()` (i.e. `setup(opts, true)`) to reset all options to their default values before applying `opts`. If the plugin is started during Neovim's startup/init phase, the plugin will wait until Neovim has finished initializing before setting up its buffer and option observers (autocmds, buffer callbacks, etc.).

```lua
require("sos").setup {
    -- Whether to enable the plugin
    enabled = true,

    -- Time in ms after which `on_timer()` will be called. By default, `on_timer()`
    -- is called 10 seconds after the last buffer change. Whenever an observed
    -- buffer changes, the global timer is started (or reset, if it was already
    -- started), and a countdown of `timeout` milliseconds begins. Further buffer
    -- changes will then debounce the timer. After firing, the timer is not
    -- started again until the next buffer change.
    timeout = 10000,

    -- Set, and manage, Vim's 'autowrite' option (see :h 'autowrite'). Allowing
    -- sos to "manage" the option makes it so that all autosaving functionality
    -- can be enabled or disabled altogether in a synchronized fashion as
    -- otherwise it is possible for autosaving to still occur even after sos has
    -- been explicitly disabled (via :SosDisable for example). There are 3
    -- possible values:
    --
    --     "all": set and manage 'autowriteall'
    --
    --     true: set and manage 'autowrite'
    --
    --     false: don't set, touch, or manage any of Vim's 'autowwrite' options
    autowrite = true,

    -- Automatically write all modified buffers before executing a command on
    -- the cmdline. Aborting the cmdline (e.g. via `<Esc>`) also aborts the
    -- write. The point of this is so that you don't have to manually write a
    -- buffer before running commands such as `:luafile`, `:soruce`, or a `:!`
    -- shell command which reads files (such as git or a code formatter).
    -- Autocmds will be executed as a result of the writing (i.e. `nested = true`).
    --
    --     false: don't write changed buffers prior to executing a command
    --
    --     "all": write on any `:` command that gets executed (but not `<Cmd>`
    --            mappings)
    --
    --     "some": write only if certain commands (source/luafile etc.) appear
    --             in the cmdline (not perfect, but may lead to fewer unneeded
    --             file writes; implementation still needs some work, see
    --             lua/sos/impl.lua)
    --
    --     table<string, true>: table that specifies which commands should trigger
    --                          a write
    --                          keys: the full/long names of commands that should
    --                                trigger write
    --                          values: true
    save_on_cmd = "some",

    -- Save/write a changed buffer before leaving it (i.e. on the `BufLeave`
    -- autocmd event). This will lead to fewer buffers having to be written
    -- at once when the global/shared timer fires. Another reason for this is
    -- the fact that neither `'autowrite'` nor `'autowriteall'` cover this case,
    -- so it combines well with those options too.
    save_on_bufleave = true,

    -- Save all buffers when Neovim loses focus. This is provided because
    -- 'autowriteall' does not cover this case. It is particularly useful when
    -- swapfiles have been disabled and you (knowingly or unknowingly) start
    -- editing the same file in another Neovim instance while having unsaved
    -- changes. It helps keep the file/version on the filesystem synchronized
    -- with your latest changes when switching applications so that another
    -- application won't accidentally open old versions of files that you are
    -- still currently editing. Con: it could be that you actually intended to
    -- open an older version of a file in another application/Neovim instance,
    -- although in that case you're probably better off disabling autosaving
    -- altogether (or keep it enabled but utilize a VCS to get the version you
    -- need - that is, if you commit frequently enough). This option also enables
    -- saving on suspend.
    save_on_focuslost = true,

    -- Predicate fn which receives a buf number and should return true if it
    -- should be observed for changes (i.e. whether the buffer should debounce
    -- the shared/global timer). You probably don't want to change this unless
    -- you absolutely need to and know what you're doing. Setting this option
    -- will replace the default fn/behavior which is to observe buffers which
    -- have: a normal 'buftype', 'ma', 'noro'. See lua/sos/impl.lua for the
    -- default behavior/fn.
    ---@type fun(bufnr: integer): boolean
    -- should_observe_buf = require("sos.impl").should_observe_buf,

    -- The function that is called when the shared/global timer fires. You
    -- probably don't want to change this unless you absolutely need to and know
    -- what you're doing. Setting this option will replace the default
    -- fn/behavior, which is simply to write all modified (i.e. 'mod' option is
    -- set) buffers. See lua/sos/impl.lua for the default behavior/fn. Any value
    -- returned by this function is ignored. `vim.api.*` can be used inside this
    -- fn (this fn will be called with `vim.schedule()`).
    -- on_timer = require("sos.impl").on_timer,
}
```

## Commands

All of the available commands are defined [here](/lua/sos/commands.lua).

## Tips

- Decrease the `timeout` value if you'd like more frequent/responsive autosaving behavior (e.g. `10000` for 10 seconds, or `5000` for 5 seconds). It's probably best not to go below 5 seconds however.

## FAQ

### How do I discard all changes that I have made in a buffer? Before, I could just use or `:e!` or `:q!`.

If you have just finished working on a buffer and the (original) version of the file you need is not staged/committed/stored in your vcs/git (in which case you could also just checkout the file at the version you need, restore the working tree file, etc.), you cannot just use `e!` or `:q!` to discard your changes; instead, use vim's builtin undo (see `:help undo.txt`) ***before*** reloading or discarding the buffer. If you didn't make many changes, you can just use `u` repeatedly (you can even hold it) in normal mode until you get back to the state you are looking for (likewise use `CTRL-R` to redo). To get back the buffer as it was when it was first opened, in one go, you can use the command `:ea 999d`. To make things even easier, you can create your own command or mapping for the following command:

```vim
execute 'earlier' .. v:numbermax
```

> **Note** these `:earlier` commands to get back to the original state of the buffer will not work as expected if you are using `'undofile'` or persisting undo history

> **Note** undo history is lost when the buffer is unloaded

If you feel the need to persist your undo history to the filesystem, checkout `:help persistent-undo` and `:help 'undofile'`. For more precise undo history introspection and traversal, you can install an undo history plugin, such as [undotree].

A custom recovery solution could be devised and added to the plugin (e.g. automatically caching files in RAM, vim buffers, or fs/git), but such a thing seems overkill and unnecessary at the moment. I haven't had any major issues myself utilizing only git and vim's undo history.

## Interaction with format on save

I believe that there are generally 2 main reasons/pros for using format on save:

1. only having to manually save the file instead of manually format and then manually save
2. not having to worry about a file on the filesystem ever being in an unformatted state

If you have Neovim setup to format on save/write via autocmds, you may experience issues as sos will trigger autocmds when saving changed buffers. The issue when using sos is, that now saving occurs at random times, and may occur while you are in insert mode (you likely don't want formatting to occur while you're in insert mode).

TODO: provide (better) fix or suggestions, finish this section

In the meantime, if you are having issues due to a format-on-save setup, and until a better solution is discovered, you can try:

- changing which autocmd/event triggers autoformatting (e.g. use `InsertLeave` instead)
- disabling format-on-save altogether

## License

[MIT](/LICENSE.txt)

[issues]: /../../issues
[prs]: /../../pulls
[q&a]: /../../discussions/categories/q-a
[undotree]: ../../../../mbbill/undotree
