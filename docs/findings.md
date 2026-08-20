# Findings

Things learned against the real engine that a ticket got wrong or left open.

## `--delay-exit` and `--timeout` cannot both apply

Ticket 02 asks for `--delay-exit=0.2` and `--timeout 30` together. Upstream
gates one behind the other, `/usr/bin/nerd-dictation:1340`:

```python
use_overtime = delay_exit > 0.0 and timeout == 0.0
```

`use_overtime` is the only thing that reads `delay_exit`. With `--timeout 30`
set, `--delay-exit` is never applied, so passing it says something the run does
not do.

Kept `--timeout 30`, dropped `--delay-exit`. The hang backstop protects against
a lost key release leaving the microphone open, which is worse than a clipped
last word.

Whether 0.2 actually clips the last word on the linked `small-en-us` model is
still untested. It needs someone at the microphone. If clipping shows up, the
trade reverses: drop `--timeout` and put `--delay-exit=0.2` back.

## `--timeout 30` may not be the backstop ticket 02 assumes

A session left in silence ran past 120s without exiting on its own. The timeout
check sits inside `if data:` in the recording loop, so it only advances while
the microphone delivers audio. A session that stalls because audio stopped is
the case the backstop is meant to cover, and that is the case it may miss.

Unverified. Confirm by running `begin` with a short `--timeout` and timing it.

## The AUR pin moved

Ticket 01 records the package as pinned to `aceb2bf` (r156). What installs today
is `nerd-dictation-git 0.0.r161.41f3727-1`. Both flags above were re-checked
against the installed file, not against r156.

## The cookie file is the whole session state

Four things ride on a session's `--cookie`, none of them documented.
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

## The compositor release survives live typing

The dropped `ptt` watcher block claimed typing during the hold can eat the key
release. It has not. `KEYCODE=88` was `KEY_F12`
(`/usr/include/linux/input-event-codes.h:164`), the bind is `Pause`,
`KEY_PAUSE` 119 (`:195`), so the watcher never fired and the release bind ended
every live session on its own.

## `--defer-output` switches the typing path

It sets `progressive` off (1850). On, the engine types deltas (1050). Off, one
call at exit (1264). ptt never passes it, so output is always progressive.

## The input tools differ in how long their device lives

- `WTYPE`, a process per call (279). New keymap each time, `-d` defaults to 0.
  A window that binds asynchronously loses the delta's leading space.
- `DOTOOL`, one process setup to teardown (223), `typedelay 12`. Command written
  unescaped into a newline delimited stream (255), so `new line` breaks.
- `YDOTOOL`, a process per call (199), raw keycodes.

## `/dev/uinput` is `root:input 0660`

`DOTOOL`, `DOTOOLC`, and `YDOTOOL` all need the `input` group. Only `WTYPE`
types without it. Engine tool list at `/usr/bin/nerd-dictation:1802`.
