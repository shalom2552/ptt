#compdef ptt ptt-install

local state
local -a commands global

if [[ $service == ptt ]]; then
    commands=(
        'begin:start dictating'
        'end:stop dictating and type the text'
        'install:install the stack, or reconfigure it'
        'uninstall:remove the packages, model, and symlinks'
    )
else
    commands=(
        'install:install the stack, or reconfigure it'
        'uninstall:remove the packages, model, and symlinks'
    )
fi

global=(
    '(-h --help)'{-h,--help}'[show this help]'
    '(-s --step)'{-s,--step}'[show each command and confirm it before it runs]'
)

_arguments -s \
    "${global[@]}" \
    '1: :->command' \
    '*:: :->option'

case $state in
    command) _describe -t commands 'command' commands ;;
    # --model belongs to install alone.
    option)
        if [[ $words[1] == install ]]; then
            _arguments -s "${global[@]}" '--model[change the speech model]'
        else
            _arguments -s "${global[@]}"
        fi
        ;;
esac
