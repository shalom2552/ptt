#compdef ptt ptt-install

local state
local -a commands

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

_arguments -s \
    '(-h --help)'{-h,--help}'[show this help]' \
    '(-s --step)'{-s,--step}'[show each command and confirm it before it runs]' \
    '1: :->command'

case $state in
    command) _describe -t commands 'command' commands ;;
esac
