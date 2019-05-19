#
# Mercurial (hg) branch
#
# Show current Mercurial branch

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_HG_BRANCH_SHOW="${SPACESHIP_HG_BRANCH_SHOW=true}"
SPACESHIP_HG_BRANCH_DIVIDER="${SPACESHIP_HG_BRANCH_DIVIDER="$SPACESHIP_PROMPT_DEFAULT_DIVIDER"}"
SPACESHIP_HG_BRANCH_COLOR="${SPACESHIP_HG_BRANCH_COLOR="magenta"}"
SPACESHIP_HG_BRANCH_SYMBOL="${SPACESHIP_HG_BRANCH_SYMBOL="on"}"
SPACESHIP_HG_BRANCH_PREFIX="${SPACESHIP_HG_BRANCH_PREFIX="${SPACESHIP_PROMPT_DEFAULT_PREFIX}${SPACESHIP_HG_BRANCH_SYMBOL}${SPACESHIP_PROMPT_DEFAULT_PREFIX}"}"
SPACESHIP_HG_BRANCH_SUFFIX="${SPACESHIP_HG_BRANCH_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

spaceship_hg_branch() {
  [[ $SPACESHIP_HG_BRANCH_SHOW == false ]] && return

  spaceship::is_hg || return

  local hg_info=$(hg log -r . --template '{activebookmark}')

  if [[ -z $hg_info ]]; then
    hg_info=$(hg branch)
  fi

  spaceship::section \
    "$SPACESHIP_HG_BRANCH_COLOR" \
    "$SPACESHIP_HG_BRANCH_DIVIDER" \
    "$SPACESHIP_HG_BRANCH_PREFIX" \
    "$hg_info" \
    "$SPACESHIP_HG_BRANCH_SUFFIX"
}
