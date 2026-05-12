PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%c%{$reset_color%}"
PROMPT+=' $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

# Get the current branch from origin/HEAD
function git_origin_head() {
  local ref
  ref=$(command git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null) || return 0
  echo "${ref#refs/remotes/origin/}"
}

# Override the default git_prompt_info function to include origin/HEAD information
function git_prompt_info() {
  local ref
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
  local current_branch="${ref#refs/heads/}"
  local origin_head=$(git_origin_head)

  if [[ -n "$origin_head" && "$origin_head" != "$current_branch" ]]; then
    echo "%{$fg_bold[blue]%}git:(%{$fg[green]%}${origin_head}%{$fg_bold[blue]%}:%{$fg[red]%}${current_branch}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  else
    echo "%{$fg_bold[blue]%}git:(%{$fg[green]%}${current_branch}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}

# Complete the current branch name when Tab is pressed after `git push|pull|fetch <remote> `
function _dongri_complete_current_branch() {
  if [[ "$LBUFFER" =~ '^git (push|pull|fetch) [^ ]+ $' ]]; then
    local current_branch
    current_branch=$(command git symbolic-ref --short HEAD 2>/dev/null)
    if [[ -n "$current_branch" ]]; then
      LBUFFER="${LBUFFER}${current_branch}"
      return
    fi
  fi
  zle expand-or-complete
}
zle -N _dongri_complete_current_branch
bindkey '^I' _dongri_complete_current_branch
