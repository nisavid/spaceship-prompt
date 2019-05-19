#
# Background jobs, nested inside a subsection
#

source "$SPACESHIP_ROOT/sections/jobs.zsh"

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_JOBS_NESTED_SHOW="${SPACESHIP_JOBS_NESTED_SHOW=true}"
SPACESHIP_JOBS_NESTED_DIVIDER="${SPACESHIP_JOBS_NESTED_DIVIDER="$SPACESHIP_PROMPT_DEFAULT_DIVIDER"}"
SPACESHIP_JOBS_NESTED_COLOR="${SPACESHIP_JOBS_NESTED_COLOR="blue"}"
SPACESHIP_JOBS_NESTED_PREFIX="${SPACESHIP_JOBS_NESTED_PREFIX=""}"
SPACESHIP_JOBS_NESTED_SUFFIX="${SPACESHIP_JOBS_NESTED_SUFFIX=""}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

spaceship_jobs_nested() {
  [[ $SPACESHIP_JOBS_NESTED_SHOW == true ]] || return

  local jobs_amount=$(jobs -d | awk '!/pwd/' | wc -l | tr -d " ")

  (( $jobs_amount )) || return

  spaceship::section \
    "$SPACESHIP_JOBS_NESTED_COLOR" \
    "$SPACESHIP_JOBS_NESTED_DIVIDER" \
    "$SPACESHIP_JOBS_NESTED_PREFIX" \
    "! spaceship_jobs" \
    "$SPACESHIP_JOBS_NESTED_SUFFIX"
}
