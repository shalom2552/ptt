# 03 — `ptt-keywatch` and live mode, with runtime mode selection

**What to build:** hold F12 and text appears while you are still speaking, not
after you let go. The tool picks live or deferred at runtime with no config
change, so the same two scripts keep working on a machine that is not in the
`input` group.

Create `~/.local/share/ptt/ptt-keywatch`. It opens every readable
`/dev/input/event*`, blocks until the key is released, then exits. The keycode
comes in as an argument rather than being hardcoded, so the value lives only in
`ptt`'s variable block.

The watcher must not hang when it has nothing to watch. If no device is readable
the fd list is empty and `select` blocks forever, which means dictation starts
and never stops with no error anywhere. An empty fd list exits non zero. Mode
selection makes this nearly unreachable, but the guard stays as a backstop.

`begin` decides the mode. Nothing else in the system knows which mode is active:

```bash
can_watch() { for d in /dev/input/event*; do [ -r "$d" ] && return 0; done; return 1; }
```

Readability, not `id -nG`. The group database says `input` the moment `gpasswd`
runs, but the already running session still lacks it until a full logout, so
`id -nG` would pick live mode and then hang. Testing a real device covers that.

Live mode spawns the watcher in the background and drops `--defer-output`. When
the watcher exits it calls `ptt end`. Deferred mode keeps `--defer-output` and
spawns nothing. Same flags otherwise. Never set `--defer-output` in live mode: it
would delay all text to the release for no reason, since the watcher does not
care what wtype does.

The release bind stays armed in live mode. That is harmless. It either fires or
gets lost, and `end` is idempotent because of the `running` guard.

Fix the quick tap race in this slice, because it only exists in live mode. The
watcher is backgrounded before `exec ... begin`, so a fast enough release runs
`end` while `running` is still false, hits the guard, and the session keeps
going. `end` polls up to 2 seconds for the process to appear before giving up.

Deferred mode has to be re-verified here, and this machine is already in the
`input` group, so it will pick live. Force `can_watch` to fail on purpose and
confirm deferred still works. Both modes must work before this is called done.

**Blocked by:** 02 — extends the same `ptt` script and the binds it installed.

**Status:** ready-for-agent

- [ ] `~/.local/share/ptt/ptt-keywatch` exists, is executable, and takes the keycode as an argument
- [ ] Watcher exits non zero when no input device is readable, instead of blocking
- [ ] `can_watch` in `begin` picks the mode by testing device readability, not group membership
- [ ] Live mode: hold F12 and speak, text streams in during the hold
- [ ] Live mode: release stops dictation via the watcher
- [ ] Quick tap in live mode stops the session, does not leave it running
- [ ] Deferred still works with `can_watch` forced to fail: text lands on release
- [ ] `--defer-output` appears in deferred mode only
- [ ] `--continuous` is absent from both modes
