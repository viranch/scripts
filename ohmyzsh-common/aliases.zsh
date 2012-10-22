# Show history
alias history='fc -l 1'

# List direcory contents
alias lsa='ls -lah'
alias l='ls -lh'
alias ll='ls -la'
alias sl=ls # often screw this up

alias afind='ack-grep -il'

alias x=extract

# My useful aliases
alias wget='wget --read-timeout=10'
alias swget='swget --read-timeout=10'
alias wv='sudo wvdial'
alias utube='youtube-dl -ct'
alias d='DISPLAY=:0'
alias v='vim'
alias sp="curl -s -F 'sprunge=<-' http://sprunge.us/"
alias int='killall -INT'
alias kint='kill -INT'
alias cont='kill -CONT'
alias term='kill -TERM'
alias kll='kill -KILL'
alias sv='SUDO_EDITOR=vim sudoedit' #sudo vim
alias pg='ps aux | grep'

# Dev aliases
alias h='vim `echo $_|sed "s/\.cpp/.h/g"`'
alias c='vim `echo $_|sed "s/\.h/.cpp/g"`'
alias lc='l *.cpp|awk "{ print \$9 }"|sed "s/\.cpp//g"'
alias m='make -j$((x+1))'
alias mi='sudo make install'
