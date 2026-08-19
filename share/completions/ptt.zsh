#compdef ptt ptt-install

local state
local -a commands spec

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

spec=(
    '(-h --help)'{-h,--help}'[show this help]'
    '(-s --step)'{-s,--step}'[show each command and confirm it before it runs]'
    '1: :->command'
)
# --model belongs to install alone.
if (( ${words[(I)install]} )); then
    spec+=('--model[change the speech model]')
fi

_arguments -s "${spec[@]}"

case $state in
    command) _describe -t commands 'command' commands ;;
esac
