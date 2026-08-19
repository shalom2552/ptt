_ptt() {
    local cur word cmds
    cur="${COMP_WORDS[COMP_CWORD]}"
    if [[ ${COMP_WORDS[0]##*/} == ptt-install ]]; then
        cmds='install uninstall'
    else
        cmds='begin end install uninstall'
    fi
    # One command per run, so it drops off the list once given.
    for word in "${COMP_WORDS[@]:1:COMP_CWORD-1}"; do
        if [[ " $cmds " == *" $word "* ]]; then
            cmds=''
            break
        fi
    done
    mapfile -t COMPREPLY < <(compgen -W "$cmds -s --step -h --help" -- "$cur")
}
complete -F _ptt ptt ptt-install
