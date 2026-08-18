# 05 — Update the system-fixes doc and remove the old prototype

**What to build:** the written record matches the tool, and the 154 MB prototype
tree is gone.

Rewrite `~/Documents/system-fixes/nerd-dictation-wayland-input.md` to describe
the package based setup: no venv, no git clone, no manual download. Cover both
modes and why they exist, the new paths, and the `input` group tradeoff.

The group risk belongs in the doc as written, not softened. Members of `input`
can read and write every `/dev/input/event*` node, which means any process
running as you can log all keystrokes system wide, including passwords typed into
other applications. Wayland normally prevents exactly this. Joining the group
reopens it. That is why the group is optional and why deferred mode exists. The
local note that this account is already in `docker`, and so `input` does not
widen what is already reachable here, is specific to this machine and does not
transfer.

Record that uninstall drops the group membership, so the doc matches what the
tool actually does.

The document points at the tool. The tool does not point back: `ptt` references
no external document.

Then remove `~/.local/share/voice-tools`, which holds a 46 MB venv, 107 MB of
models, and a 368 K shallow clone. Ask before running it.

**Blocked by:** 01 and 03 — the installer and both modes have to be proven before
the old tree goes and the doc is called accurate.

**Status:** ready-for-agent

- [ ] `nerd-dictation-wayland-input.md` describes the package install, both modes, the new paths, and the group tradeoff
- [ ] The `input` group risk is stated plainly, with the docker note marked as machine specific
- [ ] Doc says uninstall removes the group membership
- [ ] Nothing in `ptt`, `ptt-install`, or `ptt-keywatch` points back at the document
- [ ] Confirmed with the user, then `~/.local/share/voice-tools` removed
