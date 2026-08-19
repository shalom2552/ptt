# Conventions

Settled while building ticket 01. Everything user facing in this project follows
these. Where a ticket says otherwise, this file wins and the ticket is stale.

## Output

Every line the tool prints carries a level, so our output is never mistaken for
pacman's and survives being piped where colors are gone:

```
[ptt] INFO ==> text
[ptt] WARN ==> text
[ptt] ERR  ==> text
```

Section headings are the exception. They get the tag with no level, wrapped in
dim rules:

```
────────────────────────────────────────────────────────
[ptt] ptt install
────────────────────────────────────────────────────────
```

Colors: cyan tag, cyan step numbers, green for values inside prose (package
names, paths), bold green for commands, dim for `$`, `#`, and asides. Yellow
warnings, red errors. All of it drops to plain text when stdout is not a tty.

Prefer two short lines over one long one. Wrap anything past roughly 70
columns rather than letting it run.

Print only what applies to the situation found. Silence when there is nothing
to say. No entry for a thing that is not there, no removal offered for a file
that does not exist.

## Confirmation

Two stages, always in this order:

1. A plain English plan of what the run will do, numbered, no commands and no
   placeholders. Then one `Proceed? [n/Y]`.
2. Each command announced on one line as it runs.

Mechanics go quiet, choices always ask. A mechanic is a step the plan already
covered, a package install or a symlink. A choice costs the user something the
run cannot undo, like joining the input group, which takes a logout to apply.
A choice shows its command and asks in both modes.

`-s` / `--step` brings per-command confirmation back for the mechanics too.
Under it nothing runs that the user has not just seen in the form it will run:

```
    # install wtype from pacman, types the text
    $ sudo pacman -S --needed wtype

Execute? [n/Y]
```

Declining a command during install stops the run; declining during uninstall
skips that one command and continues, because the removals are independent.

Prompts default to yes (`[n/Y]`). Menus name their default in the hint
(`Choice [1-2, default 2]`), and a menu's default is the harmless option.

## Help

`-h` / `--help` lists the commands, the flags, and a few examples. A bare `ptt`
prints the same help and exits 0. An unknown argument prints it to stderr and
exits 1. Help text lives in `share/help/`, carries no absolute paths, and is
plain text.

## Packages

`pacman` for anything in the official repos, `yay` only for the AUR. The
official repos are signed; the AUR runs a maintainer's build script. Do not
route repo packages through yay just because yay is already there.

Both ask for a password themselves. `yay -S` and `yay -Rns` shell out to
`sudo pacman`, so a password prompt during those is expected and is not ours.

`--needed` on install, so a re-run changes nothing.

## Shell scripts

```bash
set -Eeuo pipefail
trap 'log_error "failed on line $LINENO: $BASH_COMMAND"' ERR
```

`-E` so the trap reaches inside functions. Nothing fails silently.

## Models

The menu lists models smallest first and defaults to the smallest,
`vosk-model-small-en-us` 0.15 at ~40 MB. Ticket 01 originally said best first
with `en-us` 0.22 as the default; changed because the 1.8 GB download is a poor
thing to hand someone by pressing enter.
