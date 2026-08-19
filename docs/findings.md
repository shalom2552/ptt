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

Three things `ptt` reads off a session's `--cookie`, none of them documented.
Lines are `/usr/bin/nerd-dictation`.

- mtime 0 means listening, anything else means over (1329).
- Removing a live cookie cancels the session and drops its text (1347), so
  cookies pile up in `$XDG_RUNTIME_DIR` until logout.
- Its age at `begin` is the `--punctuate-from-previous-timeout` window (1317),
  so `begin` carries the previous cookie's mtime forward.
