#compdef ptt

local state
local -a commands spec
local step='[show each command and confirm it before it runs]'

commands=(
    'begin:start dictating'
    'end:stop dictating'
    'install:install the stack, or reconfigure it'
    'uninstall:remove the engine, the models, and the symlinks'
)

spec=(
    '(-h --help)'{-h,--help}'[show this help]'
    '1: :->command'
)
# --model is not for uninstall, --step is for install and uninstall.
if (( ! ${words[(I)uninstall]} )); then
    spec+=('(-m --model)'{-m,--model}'[change the speech model]')
fi
if (( ${words[(I)install]} || ${words[(I)uninstall]} )); then
    spec+=('(-s --step)'{-s,--step}"$step")
fi

_arguments -s "${spec[@]}"

case $state in
    command) _describe -t commands 'command' commands ;;
esac
