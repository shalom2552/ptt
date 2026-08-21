# log.sh - colors and the levelled log functions. Sourced, never run.

if [[ -t 1 ]]; then
    C_RESET=$'\e[0m'
    C_BOLD=$'\e[1m'
    C_DIM=$'\e[2m'
    C_PTT=$'\e[1;36m'
    C_NUM=$'\e[36m'
    C_CMD=$'\e[1;32m'
    C_ARG=$'\e[32m'
    C_WARN=$'\e[1;33m'
    C_ERROR=$'\e[1;31m'
else
    C_RESET='' C_BOLD='' C_DIM='' C_PTT='' C_NUM=''
    C_CMD='' C_ARG='' C_WARN='' C_ERROR=''
fi

# Tagged [ptt] so output never reads as pacman's. The level survives a pipe.
log_info() { printf '%s[ptt]%s %s\n' "$C_PTT" "$C_RESET" "$*"; }
log_warn() { printf '%s[ptt]%s %s\n' "$C_WARN" "$C_RESET" "$*" >&2; }
log_error() { printf '%s[ptt]%s %s\n' "$C_ERROR" "$C_RESET" "$*" >&2; }
