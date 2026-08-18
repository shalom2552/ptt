# 02 — `ptt` in deferred mode, key press to text

**What to build:** hold F12, speak, release, and the whole utterance appears at
once. This is the first slice that works from the keyboard rather than from a
terminal, and it works without any `input` group membership.

Create `~/.local/share/ptt/ptt`. It takes one argument: `begin`, `end`,
`install`, or `uninstall`. `install` and `uninstall` are two dispatch lines,
`exec "$DIR/ptt-install" "$1"`, pointing at the script from ticket 01. `begin`
and `end` do the work.

At the top of `ptt` sits a four value variable block: `BIN`, `ARGS`, `PKGS`, and
`KEY`/`KEYCODE`. Swapping the speech engine later should mean rewriting these and
nothing else. `KEY` is F12, `KEYCODE` is 88, with a comment naming the Hyprland
bind that has to match.

`begin` refuses to start a second session if one is already running, and `end`
refuses to stop one that is not. Both guards are load bearing. The one on `end`
especially: without it, a release with nothing running throws a Python traceback
from a stale cookie.

Both guards need a `pgrep -f` pattern that matches the packaged binary. The
prototype's pattern matched a venv python path and will not match what ticket 01
installed. Start the engine, read its real command line, and derive the pattern
from that. Verify it returns nothing when nothing is running.

If `command -v nerd-dictation` finds nothing, both `begin` and `end` send a
notification instead of failing silently:

```
Voice typing not installed
Run: ~/.local/share/ptt/ptt install
```

Normal urgency, `-t 10000`.

Shared flags:

```
nerd-dictation begin \
    --simulate-input-tool=WTYPE \
    --idle-time=0.2 \
    --delay-exit=0.2 \
    --punctuate-from-previous-timeout=2 \
    --full-sentence \
    --timeout 30
```

`--timeout 30` is the hang backstop: the engine exits on its own after 30s with
no speech processed, so a session that loses its watcher dies by itself.
`--delay-exit=0.2` was tuned against the 40 MB model, which ticket 01 ended up
making the installer default, so the value is already matched to the common
case. Check it against whichever model is actually linked and only raise it if
it clips the last word.

This slice runs deferred only, so `begin` also passes `--defer-output` and spawns
nothing. Without it, wtype types during the hold, Hyprland loses the key release,
and dictation never stops. Mode selection and the watcher arrive in ticket 03.

Repoint the Hyprland binds in `~/.config/hypr/modules/machine.lua` at the new
path by full path, and add the release bind that the prototype is missing:

```lua
hl.bind("F12", hl.dsp.exec_cmd("~/.local/share/ptt/ptt begin"))
hl.bind("F12", hl.dsp.exec_cmd("~/.local/share/ptt/ptt end"), { release = true })
```

Full path, not a bare `ptt`, because a bare name needs the PATH symlink to exist
and a missing one fails the bind with no notification.

`~/.config/hypr` is a real repo with a remote and an unrelated dirty file. Do not
stage it and do not commit. Hyprland uses the native Lua config, so
`hyprctl keyword` fails. Use `hyprctl reload`, and `hyprctl eval` for inspection.

Short comments in `ptt` for the load bearing parts. `ptt` references no external
document.

`ptt` prints nothing to a terminal in normal use, so the output and confirmation
conventions in `docs/conventions.md` do not apply to `begin` and `end`. The
shell script conventions do: `set -Eeuo pipefail`, and the notification path
stays helper free, as ticket 01 decided. The `install` and `uninstall` dispatch
lines inherit everything `ptt-install` already does.

**Blocked by:** 01 — the engine and model have to be installed first.

**Status:** built, needs a microphone pass

`--delay-exit=0.2` was dropped. Upstream only applies it when `--timeout` is
zero, so the two flags this ticket asks for together cannot both take effect.
See `docs/findings.md`, which also records a doubt about `--timeout 30` being
the backstop this ticket assumes.

- [x] `~/.local/share/ptt/ptt` exists, is executable, and dispatches begin, end, install, uninstall
- [x] Variable block at the top holds `BIN`, `ARGS`, `PKGS`, `KEY`/`KEYCODE`, with a comment tying `KEYCODE` to the bind
- [x] `pgrep -f` pattern derived from the packaged binary's real cmdline, matches when running and not when stopped
- [ ] Hold F12, speak, release: text appears in one go on release
- [ ] Pressing F12 twice in a row does not start a second session
- [x] Releasing F12 with nothing running exits quietly, no traceback
- [ ] With `nerd-dictation` off PATH, both begin and end fire the not-installed notification
- [x] Checked whether `--delay-exit=0.2` clips the last word on the linked model; recorded the finding either way
- [x] `set -Eeuo pipefail` and an `ERR` trap, per `docs/conventions.md`
- [x] Both binds present in `machine.lua` by full path, `hyprctl reload` applied, nothing staged or committed in the hypr repo
