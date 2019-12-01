# if powerline-shell is available use it.
function _update_ps1() {
    if hash powerline-rs 2>/dev/null; then
        PS1="$(powerline-rs --shell bash $?)"
    fi
}

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source ~/.alias
source ~/.custom
source ~/.variables

# Fix .netcore paths if dotnet is installed
if hash dotnet 2>/dev/null; then
    export DOTNET_ROOT=/opt/dotnet
    export MSBuildSDKsPath=$DOTNET_ROOT/sdk/$(${DOTNET_ROOT}/dotnet --version)/Sdks
    export PATH="${PATH}:${DOTNET_ROOT}:~/.dotnet/tools"
fi

#... :P fancy stuffs
#screenfetch -t -A "UBUNTU"
neofetch
PS1='[\u@\h \W]\$ '

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
   PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
