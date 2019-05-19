#
# Git status
#

zmodload zsh/param/private

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_GIT_STATUS_SHOW="${SPACESHIP_GIT_STATUS_SHOW=true}"
SPACESHIP_GIT_STATUS_DIVIDER="${SPACESHIP_GIT_STATUS_DIVIDER="$SPACESHIP_PROMPT_DEFAULT_DIVIDER"}"
SPACESHIP_GIT_STATUS_COLOR="${SPACESHIP_GIT_STATUS_COLOR="red"}"
SPACESHIP_GIT_STATUS_PREFIX="${SPACESHIP_GIT_STATUS_PREFIX="${SPACESHIP_PROMPT_DEFAULT_PREFIX}["}"
SPACESHIP_GIT_STATUS_SEPARATOR="${SPACESHIP_GIT_STATUS_SEPARATOR="${SPACESHIP_PROMPT_DEFAULT_PREFIX}"}"
SPACESHIP_GIT_STATUS_UNTRACKED="${SPACESHIP_GIT_STATUS_UNTRACKED="?"}"
SPACESHIP_GIT_STATUS_ADDED="${SPACESHIP_GIT_STATUS_ADDED="+"}"
SPACESHIP_GIT_STATUS_MODIFIED="${SPACESHIP_GIT_STATUS_MODIFIED="!"}"
SPACESHIP_GIT_STATUS_RENAMED="${SPACESHIP_GIT_STATUS_RENAMED="»"}"
SPACESHIP_GIT_STATUS_DELETED="${SPACESHIP_GIT_STATUS_DELETED="✘"}"
SPACESHIP_GIT_STATUS_STASHED="${SPACESHIP_GIT_STATUS_STASHED="$"}"
SPACESHIP_GIT_STATUS_UNMERGED="${SPACESHIP_GIT_STATUS_UNMERGED="="}"
SPACESHIP_GIT_STATUS_AHEAD="${SPACESHIP_GIT_STATUS_AHEAD="⇡"}"
SPACESHIP_GIT_STATUS_BEHIND="${SPACESHIP_GIT_STATUS_BEHIND="⇣"}"
SPACESHIP_GIT_STATUS_DIVERGED="${SPACESHIP_GIT_STATUS_DIVERGED="⇕"}"
SPACESHIP_GIT_STATUS_SUFFIX="${SPACESHIP_GIT_STATUS_SUFFIX="]${SPACESHIP_PROMPT_DEFAULT_SUFFIX}"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# We used to depend on OMZ git library,
# But it doesn't handle many of the status indicator combinations.
# Also, It's hard to maintain external dependency.
# See PR #147 at https://git.io/vQkkB
# See git help status to know more about status formats
spaceship_git_status() {
  [[ $SPACESHIP_GIT_STATUS_SHOW == true ]] || return

  spaceship::is_git || return

  local content

  content::append() {
    [[ $content ]] && typeset -g content="${content}${SPACESHIP_GIT_STATUS_SEPARATOR}"
    typeset -g content="${content}${1}"
  }

  private git_status=$(git status --porcelain --branch 2>/dev/null)

  private pattern is_ahead is_behind
  private -a match mbegin mend; private MATCH; private -i MBEGIN MEND

  pattern='(^|\n)## [^ ]+ .*ahead'
  [[ $git_status =~ $pattern ]] && is_ahead=true
  pattern='(^|\n)## [^ ]+ .*behind'
  [[ $git_status =~ $pattern ]] && is_behind=true
  if [[ $is_ahead ]]; then
    if [[ $is_behind ]]; then
      content::append "$SPACESHIP_GIT_STATUS_DIVERGED"
    else
      content::append "$SPACESHIP_GIT_STATUS_AHEAD"
    fi
  elif [[ $is_behind ]]; then
    content::append "$SPACESHIP_GIT_STATUS_BEHIND"
  fi

  pattern='(^|\n)(U[UDA]|AA|DD|[DA]U) '
  if [[ $git_status =~ $pattern ]]; then
    content::append "$SPACESHIP_GIT_STATUS_UNMERGED"
  fi

  if git rev-parse --verify refs/stash &>/dev/null; then
    content::append "$SPACESHIP_GIT_STATUS_STASHED"
  fi

  pattern='(^|\n)([MARCDU ]D|D[ UM]) '
  if [[ $git_status =~ $pattern ]]; then
    content::append "$SPACESHIP_GIT_STATUS_DELETED"
  fi

  pattern='(^|\n)R[ MD] '
  if [[ $git_status =~ $pattern ]]; then
    content::append "$SPACESHIP_GIT_STATUS_RENAMED"
  fi

  pattern='(^|\n)[ MARC]M '
  if [[ $git_status =~ $pattern ]]; then
    content::append "$SPACESHIP_GIT_STATUS_MODIFIED"
  fi

  pattern='(^|\n)UA|(A[ MDAU]|M[ MD] )'
  if [[ $git_status =~ $pattern ]]; then
    content::append "$SPACESHIP_GIT_STATUS_ADDED"
  fi

  pattern='(^|\n)\?\?'
  if [[ $git_status =~ $pattern ]]; then
    content::append "$SPACESHIP_GIT_STATUS_UNTRACKED"
  fi

  if [[ $content ]]; then
    spaceship::section \
      "$SPACESHIP_GIT_STATUS_COLOR" \
      "$SPACESHIP_GIT_STATUS_DIVIDER" \
      "$SPACESHIP_GIT_STATUS_PREFIX" \
      "$content" \
      "$SPACESHIP_GIT_STATUS_SUFFIX"
  fi
}
