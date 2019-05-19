#
# Background jobs
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_JOBS_SHOW="${SPACESHIP_JOBS_SHOW=true}"
SPACESHIP_JOBS_DIVIDER="${SPACESHIP_JOBS_DIVIDER="$SPACESHIP_PROMPT_DEFAULT_DIVIDER"}"
SPACESHIP_JOBS_COLOR="${SPACESHIP_JOBS_COLOR="blue"}"
SPACESHIP_JOBS_SYMBOL="${SPACESHIP_JOBS_SYMBOL="✦"}"
SPACESHIP_JOBS_PREFIX="${SPACESHIP_JOBS_PREFIX="${SPACESHIP_PROMPT_DEFAULT_PREFIX}${SPACESHIP_JOBS_SYMBOL}${SPACESHIP_PROMPT_DEFAULT_PREFIX}"}"
SPACESHIP_JOBS_AMOUNT_THRESHOLD="${SPACESHIP_JOBS_AMOUNT_THRESHOLD=1}"
SPACESHIP_JOBS_SUFFIX="${SPACESHIP_JOBS_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show icon if there's a working jobs in the background
spaceship_jobs() {
  [[ $SPACESHIP_JOBS_SHOW == false ]] && return

  local jobs_amount=$(jobs -d | awk '!/pwd/' | wc -l | tr -d " ")

  (( $jobs_amount )) || return

  (( $jobs_amount <= $SPACESHIP_JOBS_AMOUNT_THRESHOLD )) && jobs_amount=''

  spaceship::section \
    "$SPACESHIP_JOBS_COLOR" \
    "$SPACESHIP_JOBS_DIVIDER" \
    "$SPACESHIP_JOBS_PREFIX" \
    "$jobs_amount" \
    "$SPACESHIP_JOBS_SUFFIX"
}
