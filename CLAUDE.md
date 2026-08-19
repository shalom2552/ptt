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

## Code

Strict YAGNI. Only what was asked, no unsolicited features or boilerplate.

`ptt` and `ptt-install` share one `log_info` / `log_warn` / `log_error` block.
Copy it, do not invent a second style. Every terminal line carries a level.

## Testing

Anything needing a microphone is the user's to run. Never start a dictation
session to test it: `WTYPE` types into whatever window has focus.

## Git

Read only by default. Staging, committing, or rewriting history needs asking
first. `~/.config/hypr` is a separate repo: edit, `hyprctl reload`, never stage.
