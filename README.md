# ptt

Push to talk voice typing on Wayland, with Whisper on an NVIDIA GPU. Hold a
key and speak, and the words are typed live at the cursor, in whatever window
has focus. Fully offline.

## How it works

- `ptt` is a small Python daemon run by a systemd user service. It keeps
  Whisper `large-v3-turbo` on the GPU, so a press starts recording at once.
- It reads the key straight from `/dev/input`, so any window works.
- While the key is held it transcribes about every 0.5 s and types with
  `wtype`. On release it runs one last, more accurate pass.
- Two typing modes:
  - `correct`: types the current guess right away, fixes it with backspaces.
  - `commit`: types a word once passes agree, never deletes, 1 to 2 s behind.
- While held: a popup, a red window border, start and stop sounds.

## Requirements

| Needs | For |
| :--- | :--- |
| NVIDIA GPU and driver | Whisper. GTX 10xx (Pascal): `nvidia-580xx`, the last series that supports it. |
| Wayland compositor with virtual keyboard: Hyprland, sway | Typing. GNOME does not work. |
| `wtype` | Typing. |
| `pipewire` | Recording and sounds. |
| `uv`, `gcc` | The Python env. |
| `swayosd` | Popup. Optional. |
| Hyprland 0.55+ with the Lua config | Border. Optional. |
| `sound-theme-freedesktop` | Default sounds. Optional. |

Anything optional that is missing turns itself off, and the log says so.

## Install

```bash
git clone -b whisper https://github.com/shalom2552/ptt.git ~/Projects/ptt
~/Projects/ptt/install
```

The install links to the clone, so keep it where it is. It:

1. Installs the packages with pacman. Elsewhere, install them first.
2. Adds the account to the `input` group. Log out and back in after.
3. Creates the Python env in `~/.local/share/ptt/venv`.
4. Copies `config.toml` and `words.txt` to `~/.config/ptt/`, unless there.
5. Downloads the model, about 1.6 GB, once.
6. Links `ptt` and its service, and starts it.

## Bind a key

ptt reads Pause itself. Bind it to nothing so apps don't get it. Hyprland:

```lua
hl.bind("Pause", hl.dsp.exec_cmd("true"))
```

## Usage

Hold Pause and talk. Release to finish.

- Settings: `~/.config/ptt/config.toml`, every option explained inside.
- Words to expect, like names and jargon: `~/.config/ptt/words.txt`.
- After a change: `systemctl --user restart ptt`.
- Log, with the time each pass takes: `journalctl --user -u ptt -f`.

No period at the end means Whisper heard an unfinished sentence. Finish it
before the release.

## Update

```bash
git -C ~/Projects/ptt pull
systemctl --user restart ptt
```

## Troubleshooting

| Symptom | Fix |
| :--- | :--- |
| `libcublas.so.12 is not found` | Run `./install` again. |
| Error mentions `libcudnn` | `uv pip install --python ~/.local/share/ptt/venv/bin/python nvidia-cudnn-cu12` |
| Key does nothing | `id` must list `input`. Log out and back in. |
| Wrong mic | `wpctl set-default <id>` |
| Slow passes, or out of GPU memory | Set `model = "small.en"` and restart. It downloads on start. |

## Uninstall

```bash
~/Projects/ptt/install --uninstall
```

Removes the service, links, Python env, config and models. Packages and the
`input` group stay, since other things may use them.

## License

MIT, see [LICENSE](LICENSE).
