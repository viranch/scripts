# ls colors
autoload colors; colors;

# Find the option for using colors in ls, depending on the version: Linux or BSD
ls --color -d . &>/dev/null 2>&1 && alias ls='ls --color=tty' || alias ls='ls -G'

#setopt no_beep
setopt auto_cd
setopt multios
setopt cdablevarS

if [[ x$WINDOW != x ]]
then
    SCREEN_NO="%B$WINDOW%b "
else
    SCREEN_NO=""
fi

# Apply theming defaults
#PS1="%n@%m:%~%# "

# Setup the prompt with pretty colors
setopt prompt_subst

# Load the theme
PROMPT='%F{208}%n%f%{$fg[white]%}@%F{039}mac%f%{$reset_color%} %{$fg[green]%}%c%{$reset_color%} %{$fg[cyan]%}$(git_prompt_info)%{$reset_color%}% » '
ZSH_THEME_GIT_PROMPT_PREFIX="<%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%} %{$fg[yellow]%}✗%{$fg[cyan]%}> %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[cyan]%}> "

