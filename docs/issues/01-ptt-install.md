# 01 — `ptt-install`: first run, re-run menu, and uninstall

**What to build:** running the installer on a machine that has nothing leaves it
with a working speech engine, a model, and both symlinks, and you can watch it
happen. Run it again on a machine that already has it and it shows a small menu
instead of reinstalling. Uninstall takes the machine back to how it was.

This is the first slice because nothing else can be tested until the packages are
on the machine, and the installer is what puts them there. Nothing gets installed
by hand.

Create `~/.local/share/ptt/ptt-install`. It runs directly for now
(`~/.local/share/ptt/ptt-install install`). Ticket 02 adds the two line dispatch
from `ptt`.

Colors and `log_info` / `log_warn` / `log_error` live in this file only. `begin`
and `end` run off a keypress and speak through `notify-send`, so a helper block in
that path would be dead weight on every press. No shared lib file: it would be
sourced by exactly one script.

## First run

1. Print the plan. Ask `Proceed? [n/Y]`. One prompt, not one per command.
2. Install `wtype` (extra) and `nerd-dictation-git` (AUR, pulls `python-vosk`,
   `python-srt`, `libpulse`) via yay. pacman and yay ask for the password
   themselves.
3. Prompt for a model, install that package. Menu lists them best first, default
   `en-us` 0.22:

   | Package | Path | Size |
   |---|---|---|
   | `vosk-model-en-us` 0.22 | `/usr/share/vosk-models/en-us` | ~1.8 GB |
   | `vosk-model-en-us-lgraph` 0.22 | `/usr/share/vosk-models/en-us-lgraph` | ~128 MB |
   | `vosk-model-small-en-us` 0.15 | `/usr/share/vosk-models/small-en-us` | ~40 MB |

4. `ln -sfn /usr/share/vosk-models/<choice> ~/.config/nerd-dictation/model`.
   Engine default path, so there is no `--vosk-model-dir` flag, no state dir, and
   `nerd-dictation` typed by hand works too.
5. `ln -sfn ~/.local/share/ptt/ptt ~/.local/bin/ptt` so it is on PATH for
   terminal use. The link target does not exist until ticket 02, which is fine.
6. Offer the `input` group, with the tradeoff in one line: join for live text,
   decline and get deferred mode. If accepted, run `sudo gpasswd -a $USER input`
   and warn that a full graphical logout is required. Group membership is baked
   in at login, so Hyprland and everything it spawns keep the old set until then.
   `newgrp` does not help.

Install is idempotent: `--needed` on packages, `ln -sfn` on links.

The AUR package pins upstream commit `aceb2bf` (r156), which has WTYPE support.

## Re-run, already installed

A menu, not a reinstall. Entries appear only when they apply:

```
ptt is installed.
  current model: en-us (0.22)
  mode:          deferred (not in input group)

  1) change model
  2) join the input group for live text
  3) quit
```

- Change model: same three way prompt, install the package if missing, re-point
  the symlink with `ln -sfn`.
- Join the group: shown only when not already a member, and only when the group
  is actually missing rather than pending a logout. If membership exists but the
  session predates it, say "log out and back in" instead of offering to add it
  again.
- Nothing else is touched. No package reinstall, no repeated prompts.

## What install prints at the end

Only what applies to the situation it found. Silence when there is nothing to do.

- **No binds found.** `grep -rq ptt ~/.config/hypr/` comes up empty, so print the
  two lines ready to paste, and where to paste them:

  ```
  No keybind found. Add to your Hyprland config:

    hl.bind("F12", hl.dsp.exec_cmd("~/.local/share/ptt/ptt begin"))
    hl.bind("F12", hl.dsp.exec_cmd("~/.local/share/ptt/ptt end"), { release = true })

  Then: hyprctl reload
  ```

  If `~/.config/hypr` does not exist at all, say the tool is installed and works
  from a terminal, and that binding it is up to the compositor in use. Do not
  assume Hyprland.

- **Group just added.** Log out and back in, and until then it runs in deferred
  mode.
- **Mode.** One line saying which mode it will run in and why, so the behavior is
  never a surprise.

## Uninstall

Uninstall cleans the machine. Same `[n/Y]` prompt, then:

- `yay -Rns nerd-dictation-git <model package>`
- remove `~/.config/nerd-dictation/`
- remove `~/.local/bin/ptt`
- `sudo gpasswd -d $USER input`, then say a full logout is needed before the
  group actually goes away for the running session

This reverses the PRD, which said uninstall leaves the group and only prints how
to drop it. Decided otherwise: uninstall removes it.

Uninstall does not delete `~/.local/share/ptt/` itself. That directory holds the
script being run, and removing the tool is a copy-a-folder-away decision, not the
installer's.

## Testing the group prompt

This account is already in `input`, so the join path cannot be exercised as is.
Create a throwaway local user that is not in the group, run the installer as that
user, and confirm both the offer and the accept path. Remove the throwaway user
afterwards. Ask before creating or deleting the account.

## Changed while building

Decided against what is written above. `docs/conventions.md` has the detail.

- `wtype` installs with `sudo pacman -S --needed`, not yay. Only the AUR
  packages go through yay, because the official repos are signed and the AUR is
  a maintainer's build script.
- The model menu lists smallest first and defaults to `vosk-model-small-en-us`
  0.15, not `en-us` 0.22. Pressing enter should not start a 1.8 GB download.
- Two confirmation stages, not one. A prose plan gets one `Proceed?`, then every
  command is shown with a one line comment and confirmed with `Execute?` right
  before it runs. The single prompt hid what `yay -S --needed <model>` would
  actually be.
- Log lines carry a level, `[ptt] INFO ==>`, so the output survives a pipe and
  never reads as pacman's.
- Uninstall removes every installed `vosk-model-*` package, not only the linked
  one, and lists only the things that are actually present.
- No throwaway user was needed for the group test. Uninstall drops the
  membership, so the join path can be exercised on the real account.

**Blocked by:** None — can start immediately.

**Status:** ready-for-agent

- [ ] First run on this machine: one `[n/Y]`, then packages, model menu, both symlinks, group offer, watched happening live
- [ ] `nerd-dictation` and `wtype` are on PATH afterwards, `~/.config/nerd-dictation/model` points at the chosen model
- [ ] Model menu lists all three best first and defaults to `en-us` 0.22
- [ ] Re-run shows the status menu, not a reinstall, and reports current model and mode
- [ ] Change model installs the package if missing and re-points the symlink
- [ ] Group entry hidden when already a member; a member with a stale session is told to log out instead of being offered the group again
- [ ] Running install twice in a row changes nothing the second time
- [ ] End of run prints only what applies: bind block when `grep -rq ptt ~/.config/hypr/` is empty, no-Hyprland fallback when the dir is missing, group-just-added line, mode line
- [ ] `ptt-install uninstall` prompts, removes packages, `~/.config/nerd-dictation/`, `~/.local/bin/ptt`, and drops the `input` group with `gpasswd -d`, then says a logout is needed
- [ ] After the uninstall test, install is run again so later tickets have a working machine
- [ ] Group offer and accept path verified as a throwaway user who is not in `input`, and that user removed afterwards
- [ ] Colors and the log helpers exist only in `ptt-install`
