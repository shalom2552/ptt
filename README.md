# ptt

Push to talk voice typing on Linux. Hold a key, speak, release, and the text is
typed into whatever window has focus.

## What it is

A wrapper. ptt does no speech recognition and no typing of its own. It glues
together tools that already exist and makes them easy to set up and bind to a
key:

- [nerd-dictation](https://github.com/ideasman42/nerd-dictation) with
  [vosk](https://alphacephei.com/vosk/) for offline speech to text
- [wtype](https://github.com/atx/wtype) to type the result into the focused
  window

What ptt adds is the setup and the glue: an installer that puts the packages,
the model, and the symlinks in place, and a small script your compositor calls
on key press and key release.

## Features

- Punctuation marks support.
- Tab completion in zsh and bash.

## Status

Works on Arch with Hyprland and Wayland. Nothing else yet. Widening it to the
main distros is tracked in
[issue #1](https://github.com/shalom2552/ptt/issues/1).

Text appears as you speak if ptt can read your input devices, which needs the
`input` group and a login since you joined it. Otherwise the whole utterance
appears when you release the key. ptt picks the mode on every press, there is
nothing to configure.

## Install

```
git clone git@github.com:shalom2552/ptt.git ~/.local/share/ptt
~/.local/share/ptt/ptt install
```

The clone path is only a suggestion. Any path works. The installer links from
wherever the clone is, and re-running it after a move offers to point the links
back at the clone.

The installer shows a plan, asks once, then announces each command as it runs.
It lets you pick a speech model, and links the zsh and bash completions if
those shells are installed. Tab completion works in a new shell. Re-running it
gives a small menu instead of reinstalling.

Pass `--step` to see each command and confirm it before it runs:

```
~/.local/share/ptt/ptt install --step
```

## Bind a key

Hyprland, press and release:

```lua
hl.bind("F12", hl.dsp.exec_cmd("~/.local/share/ptt/ptt begin"))
hl.bind("F12", hl.dsp.exec_cmd("~/.local/share/ptt/ptt end"), { release = true })
```

Then `hyprctl reload`.

## Usage

```
ptt begin        start dictating
ptt end          stop dictating and type the text
ptt install      install the stack, or reconfigure it
ptt uninstall    remove the packages, model, and symlinks

-s, --step       show each command and confirm it before it runs
    --model      change the speech model, install only
-h, --help       show this help
```

You normally only run `install` and `uninstall` by hand. `begin` and `end` are
what the keybind calls. A bare `ptt` prints the help.
