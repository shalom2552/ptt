# Behavior

## `--delay-exit` and `--timeout` cannot both apply

Upstream gates one behind the other, `/usr/bin/nerd-dictation:1340`:

```python
use_overtime = delay_exit > 0.0 and timeout == 0.0
```

`use_overtime` is the only thing that reads `delay_exit`. ptt passes
`--timeout 30` (`src/ptt:18`), so `--delay-exit` would never apply.

`--timeout 30` is a hang backstop: a lost key release leaving the microphone
open is worse than a clipped last word. Whether the last word is clipped at all
on the linked `small-en-us` model is still untested. If clipping shows up, the
trade reverses: drop `--timeout` and pass `--delay-exit=0.2`.

## `--timeout 30` may not be the backstop it reads as

A session left in silence ran past 120s without exiting on its own. The timeout
check sits inside `if data:` in the recording loop, so it only advances while
the microphone delivers audio. A session that stalls because audio stopped is
the case the backstop is meant to cover, and that is the case it may miss.

Unverified. Confirm by running `begin` with a short `--timeout` and timing it.

## The AUR pin moved

The package was pinned to `aceb2bf` (r156). What installs today is
`nerd-dictation-git 0.0.r161.41f3727-1`. Every line ref here was checked against
the installed file, not against r156.

## The cookie file is the whole session state

Four things ride on a session's `--cookie`.
Lines are `/usr/bin/nerd-dictation`.

- mtime 0 means listening, anything else means over (1329).
- Its content is the engine pid, written at `begin` (1325) and read back at
  `end`, which signals that pid (1477, 1514).
- Removing a live cookie cancels the session and drops its text (1347), so
  cookies pile up in `$XDG_RUNTIME_DIR` until logout.
- Its age at `begin` is the `--punctuate-from-previous-timeout` window (1317),
  so `begin` carries the previous cookie's mtime forward.

## mtime 0 alone is not liveness

A crashed engine never stamps its cookie, so the session reads as live forever.
Liveness is mtime 0 and `kill -0` on the pid in the cookie, anything else is
over.

## The cookie age adds a leading mark, by design

Under `--punctuate-from-previous-timeout` the engine prepends `. ` with
`--full-sentence` (1400). Age is the only input. Lands after the user config
(1398), so `ptt-config.py` cannot strip it.

## The compositor release bind gets dropped

Hyprland loses release binds, so `ptt end` never runs and the engine types on
until the 30s timeout. Open reports, no published cause: hyprwm/Hyprland#3208,
#8800, #9240, #7675. The cause here is unconfirmed.

`src/ptt-keywatch` is the backstop. It snapshots the keys held at `begin` with
`EVIOCGKEY`, then ends the session when one comes up, on the release event or
on a state read, whichever lands first. The state read is what covers a release
the compositor never delivers. Reading `/dev/input/event*` needs the `input`
group, so without it there is no backstop.

## `WTYPE` is a process per call

A new process and a new keymap on every call (279), `-d` defaults to 0. A
window that binds asynchronously loses the delta's leading space. Output is
always progressive, deltas as they are recognized (1050): only `--defer-output`
turns that off (1850) and ptt never passes it.
