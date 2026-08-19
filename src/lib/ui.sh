# ui.sh - headings, prompts, and plan output. Uses the colors and log
# functions from log.sh, which has to be sourced first.

rule() { printf '%s%s%s\n' "$C_DIM" "────────────────────────────────────────────────────────" "$C_RESET"; }

heading() {
    printf '\n'
    rule
    printf '%s[ptt]%s %s%s%s\n' "$C_PTT" "$C_RESET" "$C_BOLD" "$1" "$C_RESET"
    rule
}

confirm() {
    local reply
    printf '\n'
    read -rp "$1 [n/Y] " reply || return 1
    case "${reply,,}" in
        n | no) return 1 ;;
        *) return 0 ;;
    esac
}

# Shows the exact command and what it is for, then runs it only if confirmed.
run_cmd() {
    local note="$1"
    shift
    printf '\n    %s# %s%s\n' "$C_DIM" "$note" "$C_RESET"
    printf '    %s$%s %s%s%s\n' "$C_DIM" "$C_RESET" "$C_CMD" "$*" "$C_RESET"
    if ! confirm "Execute?"; then
        log_warn "skipped: $*"
        return 1
    fi
    "$@"
}

# Same, but a declined command means the rest of the run is pointless.
step() {
    run_cmd "$@" || {
        log_warn "Stopped. Nothing further was done."
        exit 1
    }
}

# Menu picker. Writes the prompt to stderr, sets PICK to a 0-based index.
PICK=0
prompt_index() {
    local count="$1" label="$2" default="${3:-}" reply hint
    hint="1-$count"
    [[ -n $default ]] && hint="$hint, default $((default + 1))"
    while true; do
        read -rp "$label [$hint]: " reply || reply=''
        [[ -z $reply && -n $default ]] && reply=$((default + 1))
        if [[ $reply =~ ^[0-9]+$ ]] && ((reply >= 1 && reply <= count)); then
            PICK=$((reply - 1))
            return 0
        fi
        log_error "pick a number between 1 and $count"
    done
}

arg() { printf '%s%s%s' "$C_ARG" "$1" "$C_RESET"; }

plan_title() { printf '\n%s%s%s\n\n' "$C_BOLD" "$1" "$C_RESET"; }

plan_line() { printf '  %s%d.%s %s\n' "$C_NUM" "$1" "$C_RESET" "$2"; }

plan_note() { printf '%s%s%s\n' "$C_DIM" "$1" "$C_RESET"; }
