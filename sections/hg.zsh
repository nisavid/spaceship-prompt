#
# Mercurial (hg)
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_HG_SHOW="${SPACESHIP_HG_SHOW=true}"
SPACESHIP_HG_DIVIDER="${SPACESHIP_HG_DIVIDER="$SPACESHIP_PROMPT_DEFAULT_DIVIDER"}"
SPACESHIP_HG_COLOR="${SPACESHIP_HG_COLOR="white"}"
SPACESHIP_HG_SYMBOL="${SPACESHIP_HG_SYMBOL="☿"}"
SPACESHIP_HG_PREFIX="${SPACESHIP_HG_PREFIX="${SPACESHIP_PROMPT_DEFAULT_PREFIX}${SPACESHIP_HG_SYMBOL}${SPACESHIP_PROMPT_DEFAULT_PREFIX}"}"
SPACESHIP_HG_SUFFIX="${SPACESHIP_HG_SUFFIX=""}"

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

source "$SPACESHIP_ROOT/sections/hg_branch.zsh"
source "$SPACESHIP_ROOT/sections/hg_status.zsh"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show both hg branch and hg status:
#   spaceship_hg_branch
#   spaceship_hg_status
spaceship_hg() {
  [[ $SPACESHIP_HG_SHOW == false ]] && return

  [[ $(spaceship_hg_branch) ]] || return

  spaceship::section \
    'white' \
    "$SPACESHIP_HG_DIVIDER" \
    "$SPACESHIP_HG_PREFIX" \
    "! spaceship_hg_branch spaceship_hg_status" \
    "$SPACESHIP_HG_SUFFIX"
}
