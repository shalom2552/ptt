# ptt

Push to talk voice typing for Arch on Wayland. Hold a key and speak, and the
words are typed live at the cursor, in whatever window has focus.

## How it works

ptt is a wrapper. [nerd-dictation](https://github.com/ideasman42/nerd-dictation)
with [vosk](https://alphacephei.com/vosk/) does the speech,
[wtype](https://github.com/atx/wtype) does the typing.

- Key press runs `ptt begin`, and `src/ptt-keywatch` ends it on the release.
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

Needs python and `yay`.

```bash
curl -fsSL shalom2552.github.io/ptt/install.sh | bash
```

Clones into `~/.local/share/ptt`, then runs the install.

> If ever moved, links break, just run install again.

## Bind a key

Set under Hyprland config:

```lua
hl.bind("Pause", hl.dsp.exec_cmd("ptt begin"))
```

Then `hyprctl reload`.

> Other compositors work too. Just bind `ptt begin` to a key.

## Usage

Hold the bounded key and talk.

To use in a terminal run with the --toggle flag: `ptt begin --toggle`, talk, then `ptt end`.

```
ptt begin        start dictating
ptt end          stop dictating
ptt install      install the stack, or reconfigure it
ptt uninstall    remove the engine, the models, and the symlinks

-t, --toggle     keep listening until ptt end, begin only
-s, --step       show each command and confirm it, install and uninstall
-m, --model      change the speech model, install only
-h, --help       show this help
```

## Uninstall

Uninstall removes the engine, model and all symlinks.

```bash
ptt uninstall
```

> Uninstall leaves the clone in place.

## License

MIT, see LICENSE.
