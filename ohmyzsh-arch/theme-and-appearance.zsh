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
PROMPT='%{$fg_bold[green]%}%n@%M%{$reset_color%} %{$fg_bold[cyan]%}%c%{$reset_color%} %{$fg_bold[green]%}$(git_prompt_info)%{$reset_color%}% » '
ZSH_THEME_GIT_PROMPT_PREFIX="<%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%} %{$fg[yellow]%}✗%{$fg[green]%}> %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%}> "

