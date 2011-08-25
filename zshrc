# Path to your oh-my-zsh configuration.
export ZSH=$HOME/.oh-my-zsh

# Set to this to use case-sensitive completion
#export CASE_SENSITIVE="true"

# Uncomment following line if you want to disable colors in ls
#export DISABLE_LS_COLORS="true"

# add a function path
#fpath=($ZSH/functions $fpath)

# Load all of the config files in ~/oh-my-zsh that end in .zsh
for config_file ($ZSH/*.zsh) source $config_file

# Load the theme
PROMPT='%{$fg_bold[green]%}%n@%m%{$reset_color%} %{$fg_bold[cyan]%}%c%{$reset_color%} %{$fg_bold[green]%}$(git_prompt_info)%{$reset_color%}% » '
ZSH_THEME_GIT_PROMPT_PREFIX="<%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%} %{$fg[yellow]%}✗%{$fg[green]%}> %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}> "

# Key fixes
bindkey "^[[3~" delete-char
bindkey "5D" backward-word
bindkey "5C" forward-word

# Customize to your needs...
#export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin/core_perl
export EDITOR=vim

# My useful aliases
alias sysmon='echo "USER       PID %CPU %MEM  COMMAND" && "ps" aux | tail | cut -c1-25,65- | sort -n -k3'
alias mnt='pmount'
alias umnt='pumount'
alias shutdown='sudo shutdown -hP now'
alias cyberoam='curl -s http://10.100.56.55:8090/httpclient.html -d "mode=191&username=200801001&password=200801001" | grep "<message>.*</message>" -o'
alias wget='wget --read-timeout=10'
alias swget='swget --read-timeout=10'
kmv() { kde-mv "$1" "$2" & }
alias mencoder='mencoder -quiet -oac copy -ovc copy'
alias bb="curl -s http://192.168.1.1/webconfig/wan/wan.html -u admin:4129 | grep \"connect\|disconnect\" -iwo | head -n1 | sed 's/Disconnect/✔ Up/g' | sed 's/Connect$/✘ Down/g'"
alias ksr='source /home/viranch/kde/bashrc; cs'
alias slp='qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement org.kde.Solid.PowerManagement.suspendToRam'
alias fdisk='sudo fdisk -l'
alias utube='youtube-dl -ct'
alias killkde="kill -TERM `\ps aux|grep startkde$|awk '{print $2}'`"
alias killdr='killall drkonqi'

# Pacman aliases
alias p='pacman'
alias P='sudo pacman --noconfirm'
alias pi='P -S'
alias pq='p -Q'
alias up='P -Syu'
alias psc='P -Sc'
alias pss='p -Ss'
alias psi='p -Si'
alias pqs='pq -s'
alias pql='pq -l'
alias pqo='pq -o'
alias pqi='pq -i'
alias remove='P -Rs'
whose () { pqo $(which $1) }
compdef _which whose=which

# Git aliases
function gcl() {
    if [ "$1" = "-me" ]; then
        git clone https://viranch@github.com/$2
    else
        git clone git://github.com/$1.git
    fi
}

function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

alias g='git'
compdef _git g=git
alias gi='git init'
compdef _git gi=git-init
alias ga='git remote add origin'
compdef _git ga=git-remote
alias gco='git checkout'
compdef _git gco=git-checkout
alias gst='git status'
compdef _git gst=git-status
alias gll='git pull origin $(current_branch)'
compdef _git gll=git-pull
alias gd='git diff'
compdef _git gd=git-diff
alias gc='git commit -am'
compdef _git gc=git-commit
alias gp='git push origin $(current_branch)'
compdef _git gp=git-push
alias glg='git log --max-count=5'
compdef _git glg=git-log

