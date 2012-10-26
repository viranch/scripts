# get the name of the branch we are on
function git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

parse_git_dirty () {
  if [[ -n $(git status -s 2> /dev/null) ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

# get the status of the working tree
git_prompt_status() {
  INDEX=$(git status --porcelain 2> /dev/null)
  STATUS=""
  if $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$STATUS"
  fi
  echo $STATUS
}

# Git aliases
function git_work() {
  git config user.email "viranch.m@directi.com"
}
alias gw='git_work'

function gwc() {
    against="$2"
    if [[ $against == "" ]]; then 
        let against="1"
    fi
    this_commit_hash=`echo $1 | cut -c1-7`
    against_commit_hash=`git log --oneline | grep $this_commit_hash -A $against | tail -n1 | cut -d" " -f1`
    echo git diff $against_commit_hash..$this_commit_hash
    git diff $against_commit_hash $1
    echo -e "\033[32m"
    git log $1 | head -n5
    tput sgr0
}

function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

alias g='git'
compdef _git g=git

alias gi='git init'
compdef _git gi=git-init

alias ga='git add'
compdef _git ga=git-add

alias gcl='git clone'
compdef _git gcl=git-clone

alias gco='git checkout'
compdef _git gco=git-checkout

alias gst='git status'
compdef _git gst=git-status

alias gl='git pull'
compdef _git gll=git-pull

alias gd='git diff'
compdef _git gd=git-diff

# Commit all unstaged files
alias gc='git commit -am'
compdef _git gc=git-commit

# Pull before committing for busy repos
alias glc='git pull && git commit -am'
compdef _git gc=git-commit

# Commit only specifically staged files
alias gcm='git commit -m'
compdef _git gcm=git-commit

# Commit all unstaged files but write
# commit message in vim
alias gca='git commit -a'
compdef _git gca=git-commit

alias gp='git push'
compdef _git gp=git-push

alias glg='git log --max-count=5'
compdef _git glg=git-log

# Show no. of commits by each author
alias ginf='git shortlog -sn'
compdef _git ginf=git-shortlog

alias gss='git status -s'
compdef _git gss=git-status

alias grh='git reset --hard'
compdef _git grh=git-reset
