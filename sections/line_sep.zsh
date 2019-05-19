#
# Line separator
#

zmodload zsh/param/private

SPACESHIP_LINE_SEP_DIVIDER="${SPACESHIP_LINE_SEP_DIVIDER="$SPACESHIP_PROMPT_DEFAULT_DIVIDER"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

spaceship_line_sep() {
  if [[ $SPACESHIP_PROMPT_SEPARATE_LINE == true ]]; then
    spaceship::info 'rendering line_sep'

    spaceship_line_sep::render_with_divider "$SPACESHIP_LINE_SEP_DIVIDER"
  fi
}

spaceship_line_sep::render_with_divider() {
  if (( ARGC != 1 )); then
    spaceship::error "incorrect argument count $ARGC (expecting 1)"
    return 2
  fi

  private dividers=(${(0)1})

  case $#dividers in
    (2) ;;
    (1) dividers[2]=$dividers[1] ;;
    (*)
      spaceship::error \
        "invalid divider specification ${(q+)1} (expecting 1 or 2 NUL-separated strings)"
      return 2
  esac

  if (( $#__spaceship_color_stack > 0 )); then
    private divider

    private -a prev_bg_color=("$(spaceship::colors::peek bg)")
    if [[ $prev_bg_color == $'\0' ]]; then
      divider=$dividers[2]
    else
      spaceship::colors::code::unset_all
      spaceship::colors::code fg "$prev_bg_color"
      divider=$dividers[1]
    fi

    print -nP -- "$divider"

    spaceship::colors::clear
  fi

  print
}
