#!/bin/sh
# install.sh - fetch ptt and hand off to ptt install.
set -eu

PTT_REPO="${PTT_REPO:-https://github.com/shalom2552/ptt.git}"
PTT_DIR="${PTT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/ptt}"

say() { printf '[ptt] %-4s ==> %s\n' "$1" "$2" >&2; }
die() {
    say ERR "$1"
    exit 1
}

# Everything runs from main, so a truncated download never executes.
main() {
    [ -e /dev/tty ] || die "install needs a terminal"
    command -v git >/dev/null 2>&1 || die "git is not installed"
    command -v pacman >/dev/null 2>&1 || die "ptt is Arch only"

    if [ -d "$PTT_DIR/.git" ]; then
        say INFO "using the clone at $PTT_DIR"
    elif [ -e "$PTT_DIR" ]; then
        die "$PTT_DIR exists and is not a ptt clone"
    else
        say INFO "cloning into $PTT_DIR"
        mkdir -p "${PTT_DIR%/*}"
        git clone --quiet "$PTT_REPO" "$PTT_DIR"
    fi

    # stdin is the pipe, and the install prompts.
    exec "$PTT_DIR/ptt" install "$@" </dev/tty
}

main "$@"
