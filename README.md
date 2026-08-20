# ptt

Push to talk voice typing on Wayland. Hold a key and speak, and the words are
typed into whatever window has focus as they are recognized.

Needs Arch, a Wayland compositor, and `yay`.

## How it works

ptt is a wrapper. [nerd-dictation](https://github.com/ideasman42/nerd-dictation)
with [vosk](https://alphacephei.com/vosk/) does the speech,
[wtype](https://github.com/atx/wtype) does the typing.

- Key press runs `ptt begin`, key release runs `ptt end`.
- nerd-dictation records the mic, vosk turns the sound into words, offline.
- `src/ptt-config.py` sticks spoken punctuation onto the word before it, and
  puts a capital after a sentence ends.
- wtype types the words into the focused window while you talk.

## Features

- No daemon, nothing runs between presses.
- Three model sizes, swap any time.
- Punctuation marks support.
- Tab completion in zsh and bash.

## Install

```
git clone git@github.com:shalom2552/ptt.git ~/.local/share/ptt
~/.local/share/ptt/ptt install
```

Moving the project dir breaks the links. Run install again to fix them.

The `input` group is optional. It lets ptt end a session when the compositor
drops the key release.

## Bind a key

Hyprland, press and release:

```lua
hl.bind("Pause", hl.dsp.exec_cmd("ptt begin"))
hl.bind("Pause", hl.dsp.exec_cmd("ptt end"), { release = true })
```

Then `hyprctl reload`.

Other compositors work too. Bind press to `ptt begin`, release to `ptt end`.

## Usage

```
ptt begin        start dictating
ptt end          stop dictating
ptt install      install the stack, or reconfigure it
ptt uninstall    remove the engine, the models, and the symlinks

-s, --step       show each command and confirm it, install and uninstall
-m, --model      change the speech model, install only
-h, --help       show this help
```

A bare `ptt` prints the help.

Uninstall leaves the clone in place.

## License

MIT, see LICENSE.
