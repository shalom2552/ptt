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

1. Clone it and run the installer:

```
git clone git@github.com:shalom2552/ptt.git ~/.local/share/ptt
~/.local/share/ptt/ptt install
```

2. Log out and back in, for the `input` group.

> If the project dir moves, the links break. Run install again to fix them.

## Bind a key

Hyprland, press only. ptt reads the release off the input devices.

```lua
hl.bind("Pause", hl.dsp.exec_cmd("ptt begin"))
```

Then `hyprctl reload`.

Other compositors work too. Bind `ptt begin` to a key.

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

Uninstall leaves the clone in place.

## License

MIT, see LICENSE.
