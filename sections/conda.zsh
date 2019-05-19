#
# Conda
#
# Package, dependency and environment management for any language
# Link: https://conda.io/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_CONDA_SHOW="${SPACESHIP_CONDA_SHOW=true}"
SPACESHIP_CONDA_DIVIDER="${SPACESHIP_CONDA_DIVIDER="$SPACESHIP_PROMPT_DEFAULT_DIVIDER"}"
SPACESHIP_CONDA_COLOR="${SPACESHIP_CONDA_COLOR="blue"}"
SPACESHIP_CONDA_SYMBOL="${SPACESHIP_CONDA_SYMBOL="🅒"}"
SPACESHIP_CONDA_PREFIX="${SPACESHIP_CONDA_PREFIX="${SPACESHIP_PROMPT_DEFAULT_PREFIX}${SPACESHIP_CONDA_SYMBOL}${SPACESHIP_PROMPT_DEFAULT_PREFIX}"}"
SPACESHIP_CONDA_VERBOSE="${SPACESHIP_CONDA_VERBOSE=true}"
SPACESHIP_CONDA_SUFFIX="${SPACESHIP_CONDA_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current conda virtual environment
spaceship_conda() {
  [[ $SPACESHIP_CONDA_SHOW == true ]] || return

  spaceship::exists conda && [[ $CONDA_DEFAULT_ENV ]] || return

  local conda_env=$CONDA_DEFAULT_ENV
  [[ $SPACESHIP_CONDA_VERBOSE == true ]] || conda_env=${conda_env:t}

  spaceship::section \
    "$SPACESHIP_CONDA_COLOR" \
    "$SPACESHIP_CONDA_DIVIDER" \
    "$SPACESHIP_CONDA_PREFIX" \
    "$conda_env" \
    "$SPACESHIP_CONDA_SUFFIX"
}
