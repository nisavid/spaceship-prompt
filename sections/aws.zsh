#
# Amazon Web Services (AWS)
#
# The AWS Command Line Interface (CLI) is a unified tool to manage AWS services.
# Link: https://aws.amazon.com/cli/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_AWS_SHOW="${SPACESHIP_AWS_SHOW=true}"
SPACESHIP_AWS_DIVIDER="${SPACESHIP_AWS_DIVIDER="$SPACESHIP_PROMPT_DEFAULT_DIVIDER"}"
SPACESHIP_AWS_COLOR="${SPACESHIP_AWS_COLOR="208"}"
SPACESHIP_AWS_SYMBOL="${SPACESHIP_AWS_SYMBOL="☁️"}"
SPACESHIP_AWS_PREFIX="${SPACESHIP_AWS_PREFIX="${SPACESHIP_PROMPT_DEFAULT_PREFIX}${SPACESHIP_AWS_SYMBOL}${SPACESHIP_PROMPT_DEFAULT_PREFIX}"}"
SPACESHIP_AWS_SUFFIX="${SPACESHIP_AWS_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show selected aws-cli profile.
spaceship_aws() {
  [[ $SPACESHIP_AWS_SHOW == true ]] || return

  spaceship::exists aws && [[ $AWS_PROFILE ]] && [[ $AWS_PROFILE != 'default' ]] || return

  spaceship::section \
    "$SPACESHIP_AWS_COLOR" \
    "$SPACESHIP_AWS_DIVIDER" \
    "$SPACESHIP_AWS_PREFIX" \
    "$AWS_PROFILE" \
    "$SPACESHIP_AWS_SUFFIX"
}
