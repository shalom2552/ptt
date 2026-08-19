# CLAUDE.md

`docs/conventions.md` is how the tools behave. This is how to work on them.

## Writing

Commits, PRs, and docs: short, plain, human. No em dashes, emojis, or AI
buzzwords.

Commits are one line, `type(scope): 3-8 words`. No body, no trailers.
Rationale goes in `docs/`, not history.

## Comments

Comments say what the code does, never what changed or why a choice was made.
No `see docs/X.md` pointers. Load bearing behaviour only. Strip comments from
any block copied out of another file.

## Layout

```
ptt                 shim, execs src/ptt
src/                dictation, installer, key watcher, nerd-dictation config
src/lib/            log.sh and ui.sh, sourced by the scripts
share/help/         help text
share/completions/  shell completions
```

Every script sets `PTT_ROOT` from its own location and builds its paths from
there, so a clone works at any path. Nothing hardcodes a repo path.

## Code

Strict YAGNI. Only what was asked, no unsolicited features or boilerplate.

Colors and `log_info` / `log_warn` / `log_error` live in `src/lib/log.sh`.
Headings, prompts, and plan output live in `src/lib/ui.sh`. Source them, do not
copy them and do not invent a second style. Every terminal line carries a level.

## Testing

Anything needing a microphone is the user's to run. Never start a dictation
session to test it: `WTYPE` types into whatever window has focus.

## Git

Read only by default. Staging, committing, or rewriting history needs asking
first. `~/.config/hypr` is a separate repo: edit, `hyprctl reload`, never stage.
