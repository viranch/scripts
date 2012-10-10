# Super user
alias _='sudo'
compdef _sudo _=sudo

# My useful aliases
alias sysmon='echo "USER       PID %CPU %MEM  COMMAND" && "ps" aux | tail | cut -c1-25,65- | sort -n -k3'
function serv() { sudo /sbin/service $1 $2; }
function start() { sudo /sbin/service $1 start; }
function stop() { sudo /sbin/service $1 stop; }
function restart() { sudo /sbin/service $1 restart; }

# Pacman aliases
alias y=yum
compdef _yum y=yum
alias Y='sudo yum -y'
alias yi='Y install'
#alias up='P -Syu'
alias ys='y search'
yqs() { yum list installed "*$1*" }
alias rql='rpm -ql'
alias yif='y info'
alias yr='Y remove'
#alias pqo='pq -o'
#whose () { pqo -q $(which $1) }
#compdef _which whose=which

alias pb='python ~/playground/scripts/pb.py'
