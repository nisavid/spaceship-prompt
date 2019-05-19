#
# Git
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_GIT_SHOW="${SPACESHIP_GIT_SHOW=true}"
SPACESHIP_GIT_DIVIDER="${SPACESHIP_GIT_DIVIDER="$SPACESHIP_PROMPT_DEFAULT_DIVIDER"}"
SPACESHIP_GIT_COLOR="${SPACESHIP_GIT_COLOR="white"}"
SPACESHIP_GIT_SYMBOL="${SPACESHIP_GIT_SYMBOL=""}"
SPACESHIP_GIT_PREFIX="${SPACESHIP_GIT_PREFIX="${SPACESHIP_PROMPT_DEFAULT_PREFIX}${SPACESHIP_GIT_SYMBOL}${SPACESHIP_PROMPT_DEFAULT_PREFIX}"}"
SPACESHIP_GIT_SUFFIX="${SPACESHIP_GIT_SUFFIX=""}"

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

source "$SPACESHIP_ROOT/sections/git_branch.zsh"
source "$SPACESHIP_ROOT/sections/git_status.zsh"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show both git branch and git status:
#   spaceship_git_branch
#   spaceship_git_status
spaceship_git() {
  [[ $SPACESHIP_GIT_SHOW == false ]] && return

  git rev-parse --is-inside-work-tree &>/dev/null || return 0

  spaceship::section \
    "$SPACESHIP_GIT_COLOR" \
    "$SPACESHIP_GIT_DIVIDER" \
    "$SPACESHIP_GIT_PREFIX" \
    '! spaceship_git_prefix2 spaceship_git_branch spaceship_git_status spaceship_git_suffix'
}

spaceship_git_prefix2() {
  [[ -v __spaceship_colors_count_orig ]] && unset __spaceship_colors_count_orig
  typeset -gi __spaceship_colors_count_orig=$#__spaceship_color_stack
}

spaceship_git_suffix() {
  private bg_color_prev=$(spaceship::colors::peek bg)
  private -a suffix_colors=($'\0' "$bg_color_prev")

  while (( $#__spaceship_color_stack > __spaceship_colors_count_orig )); do
    spaceship::colors::pop
  done

  private -a colors_orig=("${(s<,>@)$(spaceship::colors::peek)}")
  suffix_colors[1]=$colors_orig[2]

  spaceship::colors::code : $suffix_colors
  print -nP -- "$SPACESHIP_GIT_SUFFIX"
  spaceship::colors::code : $colors_orig

  unset __spaceship_colors_count_orig
}
