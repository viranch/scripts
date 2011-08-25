# Super user
alias _='sudo'

# Show history
alias history='fc -l 1'

# List direcory contents
alias lsa='ls -lah'
alias l='ls -l'
alias ll='ls -la'
alias sl=ls # often screw this up

alias afind='ack-grep -il'

alias x=extract

# My useful aliases
alias sysmon='echo "USER       PID %CPU %MEM  COMMAND" && "ps" aux | tail | cut -c1-25,65- | sort -n -k3'
alias mnt=pmount
alias umnt=pumount
alias shutdown='sudo shutdown -hP now'
alias wget='wget --read-timeout=10'
alias swget='swget --read-timeout=10'
kmv() { kde-mv "$1" "$2" & }
alias mencoder='mencoder -quiet -oac copy -ovc copy'
alias slp='qdbus org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement org.kde.Solid.PowerManagement.suspendToRam'
alias fdisk='sudo fdisk -l'
alias utube='youtube-dl -ct'
alias killkde="kill -TERM `\ps aux|grep startkde$|awk '{print $2}'`"
alias killdr='killall drkonqi'

# Pacman aliases
alias p=pacman
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
plist() { pacman -Qei|awk ' BEGIN {FS=":"}/^Name/{printf("\033[1;36m%s\033[1;37m", $2)}/^Description/{print $2}' }
