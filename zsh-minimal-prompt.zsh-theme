#!/usr/bin/env zsh

# ------------------------------------------------------------
# Basics
# ------------------------------------------------------------
autoload -Uz colors
colors
setopt prompt_subst

# ------------------------------------------------------------
# Git prompt info
# ------------------------------------------------------------
git_prompt_info() {
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local branch git_status states=() ahead behind

  # Branch name (clean fallback for detached HEAD)
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "detached")

  git_status=$(git status --porcelain=v1 --branch 2>/dev/null)

  # Working tree states
  echo "$git_status" | grep -q '^[MADRC]' && states+=("staged")
  echo "$git_status" | grep -q '^.[MADRC]' && states+=("unstaged")
  echo "$git_status" | grep -q '^??' && states+=("untracked")

  # Sync states
  ahead=$(echo "$git_status" | sed -n 's/.*ahead \([0-9]\+\).*/\1/p')
  behind=$(echo "$git_status" | sed -n 's/.*behind \([0-9]\+\).*/\1/p')

  [[ -n $ahead ]] && states+=("ahead:$ahead")
  [[ -n $behind ]] && states+=("behind:$behind")

  # Hide clean state completely
  [[ ${#states[@]} -eq 0 ]] && {
    print "%{$fg[cyan]%}on%{$reset_color%} %{$fg[magenta]%}$branch%{$reset_color%}"
    return
  }

  # Join states with +
  local state_string
  state_string=$(IFS=+; echo "${states[*]}")

  print "%{$fg[cyan]%}on%{$reset_color%} \
%{$fg[magenta]%}$branch%{$reset_color%} \
%{$fg[yellow]%}[%{$fg[red]%}$state_string%{$fg[yellow]%}]%{$reset_color%}"
}

# ------------------------------------------------------------
# Prompt (two-line, left-only)
# ------------------------------------------------------------
PROMPT='%{$fg[blue]%}%~%{$reset_color%} $(git_prompt_info)
%b%F{244}$ %f'
