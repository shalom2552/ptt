_ptt() {
    local cur word cmd='' opts='-h --help'
    local cmds='begin end install uninstall'
    cur="${COMP_WORDS[COMP_CWORD]}"
    # One command per run, so it drops off the list once given.
    for word in "${COMP_WORDS[@]:1:COMP_CWORD-1}"; do
        if [[ " $cmds " == *" $word "* ]]; then
            cmd="$word"
            cmds=''
            break
        fi
    done
    # --model belongs to install alone, --step to install and uninstall.
    if [[ $cmd == install ]]; then
        opts="$opts -m --model -s --step"
    elif [[ $cmd == uninstall ]]; then
        opts="$opts -s --step"
    fi
    mapfile -t COMPREPLY < <(compgen -W "$cmds $opts" -- "$cur")
}
complete -F _ptt ptt
