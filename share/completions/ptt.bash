_ptt() {
    local cur words
    cur="${COMP_WORDS[COMP_CWORD]}"
    if [[ ${COMP_WORDS[0]} == ptt-install ]]; then
        words='install uninstall'
    else
        words='begin end install uninstall'
    fi
    mapfile -t COMPREPLY < <(compgen -W "$words -s --step -h --help" -- "$cur")
}
complete -F _ptt ptt ptt-install
