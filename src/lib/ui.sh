# ui.sh - headings, prompts, plan output, running commands, and help. Uses
# the colors and log functions from log.sh, which has to be sourced first.

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

# Menu picker. Writes the prompt to stderr, sets PICK to a 0-based index.
PICK=0
prompt_index() {
    local count="$1" label="$2" default="${3:-}" reply hint
    hint="1-$count"
    [[ -n $default ]] && hint="$hint, default $((default + 1))"
    while true; do
        if ! read -rp "$label [$hint]: " reply; then
            [[ -n $default ]] || return 1
            reply=''
        fi
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

plan_step_note() {
    if ((PTT_STEP)); then
        plan_note "Each step is confirmed before it runs."
    else
        plan_note "tip: run with --step to confirm each step."
    fi
}

# Result block. A label column and a value, under a heading, no level prefix.
FIELD_W=10

# The third argument is a dim tail on the value, for what the value means.
field() {
    printf '  %-*s %s%s%s' "$FIELD_W" "$1" "$C_ARG" "$2" "$C_RESET"
    if [[ -n ${3:-} ]]; then
        printf ' %s- %s%s' "$C_DIM" "$3" "$C_RESET"
    fi
    printf '\n'
}

note() { printf '  %s%s%s\n' "$C_DIM" "$1" "$C_RESET"; }

PTT_STEP="${PTT_STEP:-0}"

announce() { log_info "$C_CMD$*$C_RESET"; }

ask_cmd() {
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

# A mechanic, covered by the plan already agreed to. Only --step stops for it.
run_cmd() {
    if ((PTT_STEP)); then
        ask_cmd "$@"
        return
    fi
    shift
    announce "$@"
    "$@"
}

# Same, but a declined command means the rest of the run is pointless.
run_or_stop() {
    run_cmd "$@" || {
        log_warn "Stopped. Nothing further done."
        exit 1
    }
}

usage() { cat "$PTT_ROOT/share/help/$1.txt"; }

bad_arg() {
    log_error "unexpected argument: $2"
    usage "$1" >&2
    exit 1
}
