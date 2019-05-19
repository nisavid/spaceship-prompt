#
# vi-mode
#

zmodload zsh/param/private

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

SPACESHIP_VI_MODE_SHOW="${SPACESHIP_VI_MODE_SHOW=true}"
SPACESHIP_VI_MODE_DIVIDER="${SPACESHIP_VI_MODE_DIVIDER="$SPACESHIP_PROMPT_DEFAULT_DIVIDER"}"
SPACESHIP_VI_MODE_INSERT_COLOR="${SPACESHIP_VI_MODE_INSERT_COLOR="white"}"
SPACESHIP_VI_MODE_NORMAL_COLOR="${SPACESHIP_VI_MODE_NORMAL_COLOR="blue"}"
SPACESHIP_VI_MODE_PREFIX="${SPACESHIP_VI_MODE_PREFIX="$SPACESHIP_PROMPT_DEFAULT_PREFIX"}"
SPACESHIP_VI_MODE_INSERT_SYMBOL="${SPACESHIP_VI_MODE_INSERT_SYMBOL="[I]"}"
SPACESHIP_VI_MODE_NORMAL_SYMBOL="${SPACESHIP_VI_MODE_NORMAL_SYMBOL="[N]"}"
SPACESHIP_VI_MODE_SUFFIX="${SPACESHIP_VI_MODE_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current vi-mode mode
spaceship_vi_mode() {
  [[ $SPACESHIP_VI_MODE_SHOW == true ]] || return

  if bindkey | grep --silent 'vi-quoted-insert'; then
    private color symbol

    if [[ $KEYMAP == 'vicmd' ]]; then
      color=$SPACESHIP_VI_MODE_NORMAL_COLOR
      symbol=$SPACESHIP_VI_MODE_NORMAL_SYMBOL
    else
      color=$SPACESHIP_VI_MODE_INSERT_COLOR
      symbol=$SPACESHIP_VI_MODE_INSERT_SYMBOL
    fi

    spaceship::section \
      "$color" \
      "$SPACESHIP_VI_MODE_DIVIDER" \
      "$SPACESHIP_VI_MODE_PREFIX" \
      "$symbol" \
      "$SPACESHIP_VI_MODE_SUFFIX"
  fi
}

# ------------------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------------------

# Temporarily switch to vi-mode
spaceship_vi_mode_enable() {
  function zle-keymap-select() { zle reset-prompt ; zle -R }
  zle -N zle-keymap-select
  bindkey -v
}

# Temporarily switch to emacs-mode
spaceship_vi_mode_disable() {
  bindkey -e
}
