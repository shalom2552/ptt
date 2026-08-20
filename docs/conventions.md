# Conventions

How the tools behave. Beats any ticket that says otherwise.

## Voice

Man page style: imperative, impersonal, terse.
Name the thing, not the person: "unlink ptt from PATH", not "unlink your ptt".

## Output

Every printed line carries a level, so output never reads as pacman's:

```
[ptt] INFO ==> text
[ptt] WARN ==> text
[ptt] ERR  ==> text
```

Headings are the exception: the tag, no level, dim rules around it.

```
────────────────────────────────────────────────────────
[ptt] ptt install
────────────────────────────────────────────────────────
```

A result block under a heading is the other exception: label column, green
value, a dim tail for what the value means. Notes follow the block, dim, after
a blank line.

Colors: cyan tag and step numbers, green values, bold green commands, dim `$`,
`#`, and asides, yellow warnings, red errors. Plain text off a tty.
Two short lines beat one long one. Wrap past ~70 columns.
Print only what applies. Nothing about a thing that is not there.

## Confirmation

1. Numbered plain English plan, no commands, then one `Proceed? [n/Y]`.
2. Each command announced on one line as it runs.

Mechanics go quiet. A mechanic is a step the plan covered: a package install,
a symlink.

`-s` / `--step` confirms the mechanics too, so nothing runs unseen:

```
    # install wtype from pacman, types the text
    $ sudo pacman -S --needed wtype

Execute? [n/Y]
```

Declining stops an install. During uninstall it skips one command and
continues, since the removals are independent. A completion link is the same
exception: it skips and the install goes on, since completion is a convenience.
Prompts default to yes (`[n/Y]`). Menus name their default in the hint
(`Choice [1-2, default 2]`) and default to the harmless option.

## Help

`-h` / `--help` lists commands, flags, examples.
Bare `ptt` prints the same help, exit 0. Unknown argument prints it to stderr,
exit 1.
Help text lives in `share/help/`, plain text, no absolute paths.

## Packages

`pacman` for the official repos, `yay` only for the AUR. Never repo packages
through yay.
Both ask for their own password, so a prompt under `yay -S` or `yay -Rns` is
not ours.
`--needed` on install, so a re-run changes nothing.
`--noconfirm` on install, the plan already asked. Removals still confirm.

## Shell scripts

```bash
set -Eeuo pipefail
trap 'log_error "failed on line $LINENO: $BASH_COMMAND"' ERR
```

`-E` so the trap reaches inside functions. Nothing fails silently.

## Models

Menu lists models smallest first, defaults to the smallest,
`vosk-model-small-en-us` 0.15 at ~40 MB. A 1.8 GB download is a poor thing to
hand someone by pressing enter.
