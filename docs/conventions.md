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
2. Immediately before each command runs, the exact command and a one line
   comment saying what it is for. Then `Execute? [n/Y]`.

```
    $ sudo pacman -S --needed wtype
    # install wtype from pacman, types the text

Execute? [n/Y]
```

Nothing runs that the user has not just seen in the form it will run. Declining
a command during install stops the run; declining during uninstall skips that
one command and continues, because the removals are independent.

Prompts default to yes (`[n/Y]`). Menus name their default in the hint
(`Choice [1-2, default 2]`), and a menu's default is the harmless option.

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
