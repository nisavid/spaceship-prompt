#
# Line separator with alternative divider
#

source "$SPACESHIP_ROOT/sections/line_sep.zsh"

SPACESHIP_LINE_SEP_ALT_DIVIDER="${SPACESHIP_LINE_SEP_ALT_DIVIDER="$SPACESHIP_PROMPT_DEFAULT_DIVIDER"}"

spaceship_line_sep_alt() {
  if [[ $SPACESHIP_PROMPT_SEPARATE_LINE == true ]] \
      && (( $#__spaceship_sections_rendered )); then
    spaceship::info 'rendering line_sep_alt'

    spaceship_line_sep::render_with_divider "$SPACESHIP_LINE_SEP_ALT_DIVIDER"

    typeset -ga __spaceship_sections_rendered=($__spaceship_sections_rendered line_sep_alt)
  fi
}
