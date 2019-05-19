#
# Current history event number
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_EVENT_NUM_SHOW="${SPACESHIP_EVENT_NUM_SHOW=true}"
SPACESHIP_EVENT_NUM_DIVIDER="${SPACESHIP_EVENT_NUM_DIVIDER="$SPACESHIP_PROMPT_DEFAULT_DIVIDER"}"
SPACESHIP_EVENT_NUM_COLOR="${SPACESHIP_EVENT_NUM_COLOR="blue"}"
SPACESHIP_EVENT_NUM_SYMBOL="${SPACESHIP_EVENT_NUM_SYMBOL="!"}"
SPACESHIP_EVENT_NUM_PREFIX="${SPACESHIP_EVENT_NUM_PREFIX="${SPACESHIP_PROMPT_DEFAULT_PREFIX}${SPACESHIP_EVENT_NUM_SYMBOL}${SPACESHIP_PROMPT_DEFAULT_PREFIX}"}"
SPACESHIP_EVENT_NUM_SUFFIX="${SPACESHIP_EVENT_NUM_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

spaceship_event_num() {
  [[ $SPACESHIP_EVENT_NUM_SHOW == false ]] && return

  spaceship::section \
    "$SPACESHIP_EVENT_NUM_COLOR" \
    "$SPACESHIP_EVENT_NUM_DIVIDER" \
    "$SPACESHIP_EVENT_NUM_PREFIX" \
    "%h" \
    "$SPACESHIP_EVENT_NUM_SUFFIX"
}
