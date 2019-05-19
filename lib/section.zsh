zmodload zsh/param/private
zmodload zsh/parameter

# Render a prompt section
#
# Usage:
#   spaceship::section fg_color[,bg_color] \
#       thick_divider[$'\0'thin_divider] prefix content suffix
#
#   fg_color, bg_color
#     The foreground and background colors
#
#     Each color may be specified using one of the color names defined
#     in (i.e. keys of) SPACESHIP_COLORMAP or one of the following
#     tokens (listed with corresponding semantics):
#
#       $'\0'
#         Do not change the color (i.e. use the corresponding color of
#         the preceding section)
#
#       &+
#         Use the preceding section's foreground color
#
#       &-
#         Use the preceding section's background color
#
#     To specify both a foreground color and a background color, join
#     them with a comma (`','`).  If only one color is specified, then
#     it is used as the foreground color, and the background color is
#     unchanged---equivalent to specifying `fg_color,$'\0'`.
#
#   thick_divider, thin_divider
#     Strings to be rendered as a divider between the preceding section
#     and this one
#
#     If this section's background color is different from that of the
#     preceding section, then thick_divider is used.  If the background
#     color is effectively unchanged (due to being assigned the same
#     color name, the color reference `&-`, or the null color `$'\0'`),
#     then thin_divider is used.  To specify both divider strings, join
#     them with a NUL character ($'\0').  If only one string is
#     specified, it is used regardless of the sections' background
#     colors---equivalent to specifying the same string for both types
#     of dividers.
#
#     Prompt expansion is applied to the rendered string.
#
#     If specified, the divider is rendered at the very beginning of
#     this section, before the prefix.  In other words, the divider
#     between any two adjacent sections is rendered according to the
#     divider specification of the _second_ section.  The divider is
#     colored according to a method designed to work with
#     Powerline-style divider symbols:
#
#       * In the case of a background color change, within the left
#         prompt string, the thick_divider is rendered using the
#         preceding section's background color as its foreground color
#         and this section's background color as its background color.
#         Within the right prompt string, the same pattern holds, but
#         the roles of this section and the preceding section are
#         reversed.
#
#       * Otherwise, within the left prompt string, the thin_divider is
#         rendered using the preceding section's foreground color as its
#         foreground color and both sections' background color as its
#         background color.  Within the right prompt string, this
#         section's foreground color is used as the divider's foreground
#         color.
#
#     As such, it is recommended to use "thick"-type dividers (glyphs
#     that span the entire left/right edge of their cell, respectively
#     for the left/right prompt strings) for the thick_divider and
#     "thin"-style dividers (or an empty string) for the thin_divider.
#
#   prefix
#     Prefix content
#
#     If SPACESHIP_PROMPT_PREFIXES_SHOW is set to `true`, then this is
#     rendered after the divider (if any) and before the (main) content.
#     Prompt expansion is applied.
#
#   content
#     Main content
#
#     If this begins with a `!`, then shell expansion is applied to the
#     rest of the string, and the resulting words are interpreted as a
#     sequence of function names which are called at rendering time
#     (after the prefix has been rendered) to generate the content.
#     Otherwise (in the absence of `!`), the given string is used as the
#     literal content.  Prompt expansion is applied to the rendered
#     string in either case.
#
#   prefix
#     Suffix content
#
#     If SPACESHIP_PROMPT_SUFFIXES_SHOW is set to `true`, then this is
#     rendered after the (main) content.  Prompt expansion is applied.
#
spaceship::section() {
  private section_name=${(q+)${funcstack[2]}#spaceship_}

  if spaceship::log::level::includes 'info'; then
    spaceship::info "rendering $section_name section"
  fi
  spaceship::debug spaceship::section ${(q+)argv}

  private -a prev_colors
  (( $#__spaceship_color_stack > 0 )) && prev_colors=(${(s<,>)$(spaceship::colors::peek)})

  # Process color(s) arg
  private -a colors=($'\0' $'\0')
  case $1 in
    ('') ;;
    (*,*)
      private -a arg_colors=("${(s<,>@)1}")

      if [[ $arg_colors[1] ]]; then
        if spaceship::colors::map "$arg_colors[1]" &>/dev/null; then
          colors[1]="$arg_colors[1]"
        else
          spaceship::error "ignoring unknown color ${(q+)arg_colors[1]}"
        fi
      fi

      if [[ $arg_colors[2] ]]; then
        if spaceship::colors::map "$arg_colors[2]" &>/dev/null; then
          colors[2]="$arg_colors[2]"
        else
          spaceship::error "ignoring unknown color ${(q+)arg_colors[2]}"
        fi
      fi
      ;;
    (*)
      if spaceship::colors::map "$1" &>/dev/null; then
        colors[1]="$1"
      else
        spaceship::error "ignoring unknown color ${(q+)1}"
      fi
  esac

  # Process divider(s) arg
  private -a dividers
  [[ $2 ]] && dividers=(${(0)2})
  case $#dividers in
    (0|2) ;;
    (1) dividers+=("$dividers[1]") ;;
    (*)
      spaceship::error \
        "ignoring invalid dividers ${(q+)2} (expecting 0 or 1 or 2 NUL-separated strings)"
      dividers=()
  esac

  # Render divider and set colors
  if (( $#dividers )) && { (( $#prev_colors )) || [[ $__spaceship_is_in_rprompt ]]; }; then
    if [[ $colors[2] == $prev_colors[2] ]]; then
      if spaceship::log::level::includes 'debug'; then
        spaceship::debug \
          "rendering continuation divider ${(q+)dividers[2]}" \
          "(colors: ${(j<,>)${(@q+)prev_colors}} → ${(j<,>)${(@q+)colors}})"
      fi

      [[ $__spaceship_is_in_rprompt ]] && spaceship::colors::push : $colors

      print -nrP -- "$dividers[2]"

      [[ ! $__spaceship_is_in_rprompt ]] && spaceship::colors::push : $colors
    else
      if spaceship::log::level::includes 'debug'; then
        spaceship::debug \
          "rendering transition divider ${(q+)dividers[2]}" \
          "(colors: ${(j<,>)${(@q+)prev_colors}} → ${(j<,>)${(@q+)colors}})"
      fi

      if [[ $__spaceship_is_in_rprompt ]]; then
        spaceship::colors::code fg "$colors[2]"
      else
        spaceship::colors::code : "$prev_colors[2]" "$colors[2]"
      fi

      print -nrP -- "$dividers[1]"

      spaceship::colors::push : $colors
    fi
  else
    spaceship::colors::push : $colors
  fi

  if [[ $SPACESHIP_PROMPT_PREFIXES_SHOW == true ]]; then
    [[ $3 ]] && spaceship::content "$3"
  fi
  typeset -g __spaceship_prompt_opened=true

  [[ $4 ]] && spaceship::content "$4"

  if [[ $SPACESHIP_PROMPT_SUFFIXES_SHOW == true ]]; then
    [[ $5 ]] && spaceship::content "$5"
  fi

  typeset -ga __spaceship_sections_rendered=($__spaceship_sections_rendered $section_name)
}

# Compose and render the current prompt string.
#
# Usage: spaceship::compose_prompt [section ...]
#
# Any errors that occur during composition are printed to stderr as they
# occur, on separate lines preceding the rendered prompt.
#
spaceship::compose_prompt() {
  spaceship::debug spaceship::compose_prompt ${(q+)argv}

  # Option EXTENDED_GLOB is set locally to force filename generation on
  # argument to conditions, i.e. allow usage of explicit glob qualifier (#q).
  # See the description of filename generation in
  # http://zsh.sourceforge.net/Doc/Release/Conditional-Expressions.html
  setopt EXTENDED_GLOB LOCAL_OPTIONS

  # Treat the first argument as list of prompt sections
  # Compose whole prompt from diferent parts
  # If section is a defined function then invoke it
  # Otherwise render the 'not found' section
  private section
  for section in "$@"; do
    if spaceship::defined spaceship_"$section"; then
      spaceship_"$section"
    else
      spaceship::error "skipping undefined prompt section ${(q+)section}"
    fi
  done

  spaceship::colors::clear
}

spaceship::content() {
  spaceship::debug spaceship::content ${(q+)argv}

  if [[ $ARGC -ne 1 ]]; then
    spaceship::error "incorrect argument count $ARGC (expecting 2)"
    return 2
  fi

  private content="$1"
  private -a match mbegin mend; private MATCH; private -i MBEGIN MEND
  if [[ $content =~ !(.*) ]]; then
    spaceship::content::callback ${(Q)${(Z+Cn+)match[1]}}
  else
    #spaceship::debug content-rendered "$content"
    print -nrP -- "$content"
  fi
}

spaceship::content::callback() {
  spaceship::debug spaceship::content::callback ${(q+)argv}

  private -i colors_count_orig=$#__spaceship_color_stack

  private name saved_alias exe_type
  for name in "$@"; do
    saved_alias=$(alias -L "$name" 2>/dev/null) && unalias "$name"
    exe_type=${${(w)$(whence -w "$name")}[-1]}
    if [[ $exe_type == function ]]; then
      #spaceship::debug content-callback "$name"
      "$name" || spaceship::error "callback ${(q+)name} returned status $? (expecting 0)"
    else
      spaceship::error \
        "skipping callback ${(q+)name} due to invalid type ${(qq)exe_type} (expecting function)"
    fi
    [[ $saved_alias ]] && { eval $saved_alias; saved_alias=''; }
  done

  while (( $#__spaceship_color_stack > colors_count_orig )); do
    spaceship::colors::pop
  done
}

spaceship::colors::peek() {
  spaceship::debug spaceship::colors::peek ${(q+)argv}

  if (( $#__spaceship_color_stack == 0 )); then
    spaceship::error 'cannot peek into an empty stack'
    return 3
  fi

  private -i i=1
  private layer=:
  case $ARGC in
    (2)
      setopt local_options extended_glob
      if [[ $2 != <0-9>## ]]; then
        spaceship::error "invalid stack index ${(q+)2} (expecting a positive integer)"
        return 2
      fi
      private -i count=$#__spaceship_color_stack
      if [[ $2 -lt 1 ]] || [[ $2 -gt $count ]]; then
        spaceship::error "stack index ${(q+)2} is out of range (expecting in range [1, $count])"
        return 2
      fi

      i=$2
      ;&
    (1)
      if [[ $1 != (:|fg|bg) ]]; then
        spaceship::error "invalid layer selection ${(q+)1} (expecting : or fg or bg)"
        return 2
      fi

      layer=$1
      ;;
    (0) ;;
    (*) spaceship::error "incorrect argument count $ARGC (expecting 0 or 1 or 2)"; return 2
  esac

  if [[ $layer == : ]]; then
    print -n $__spaceship_color_stack[-$i]
  else
    private -a colors=(${(s<,>)__spaceship_color_stack[-$i]})
    case $layer in
      (fg) print -n -- $colors[1] ;;
      (bg) print -n -- $colors[2] ;;
      (*) spaceship::error "internal error"
    esac
  fi
}

spaceship::colors::push() {
  spaceship::debug spaceship::colors::push ${(q+)argv}

  if (( ARGC < 2 || ARGC > 3 )); then
    spaceship::error "incorrect argument count $ARGC (expecting 2 or 3)"
    return 2
  fi

  private -a colors=(\& \&)
  case $1 in
    (:)
      if (( ARGC != 3 )); then
        spaceship::error "incorrect argument count $ARGC (expecting 3 when first argument is :)"
        return 2
      fi

      colors=("$2" "$3")
      ;|
    (fg|bg)
      if (( ARGC != 2 )); then
        spaceship::error \
          "incorrect argument count $ARGC (expecting 3 when first argument is fg or bg)"
        return 2
      fi
      ;|
    (fg)
      colors[1]=$2
      ;|
    (bg)
      colors[2]=$2
      ;|
    (:|fg|bg)
      # case <'&' count among colors>
      case ${(M)#colors:#&} in
        (2) spaceship::warning 'colors: pushing no-op `: & &`' ;;
        (1)
          if [[ $colors[1] != \& ]]; then
            spaceship::colors::code fg "$colors[1]" || return
          elif [[ $colors[2] != \& ]]; then
            spaceship::colors::code bg "$colors[2]" || return
          fi
          ;;
        (0) spaceship::colors::code : "${(@)colors}" || return ;;
        (*) spaceship::error 'internal error'; return -1
      esac

      typeset -ga __spaceship_color_stack=($__spaceship_color_stack "${(j<,>)colors}")
      return
      ;;
    (*) spaceship::error "invalid argument ${(q+)1} (expecting fg or bg)"; return 2
  esac
}

spaceship::colors::pop() {
  spaceship::debug spaceship::colors::pop ${(q+)argv}

  (( ARGC )) && { spaceship::error "incorrect argument count $ARGC (expecting 0)"; return 2; }

  if (( $#__spaceship_color_stack == 0 )); then
    spaceship::error 'cannot pop from an empty stack'
    return 3
  fi

  __spaceship_color_stack[-1]=()
  spaceship::colors::code : "${(s<,>@)__spaceship_color_stack[-1]}"
}

spaceship::colors::clear() {
  spaceship::debug spaceship::colors::clear ${(q+)argv}

  (( ARGC )) && { spaceship::error "incorrect argument count $ARGC (expecting 0)"; return 2; }

  spaceship::colors::code::unset_all
  typeset -ga __spaceship_color_stack=()
}

spaceship::colors::code() {
  spaceship::debug spaceship::colors::code ${(q+)argv}

  if (( ARGC < 2 || ARGC > 3 )); then
    spaceship::error "incorrect argument count $ARGC (expecting 2 or 3)"
    return 2
  fi

  private color
  private -a codes
  case $1 in
    (:)
      if (( ARGC != 3 )); then
        spaceship::error \
          "incorrect argument count $ARGC (expecting 3 when first argument is :)"
        return 2
      fi

      # case <NUL count among $2 and $3>
      case ${(M)#argv[2,3]:#$'\0'} in
        (1|2) spaceship::colors::code::unset_all ;|
        (2) return ;;
        (1)
          if [[ $2 != $'\0' ]]; then
            spaceship::colors::code fg "$2" || return
          elif [[ $3 != $'\0' ]]; then
            spaceship::colors::code bg "$3" || return
          fi
          return
          ;;
        (0)
          spaceship::colors::code fg "$2" || return
          spaceship::colors::code bg "$3" || return
          return
          ;;
        (*) spaceship::error 'internal error'; return -1
      esac
      ;;
    (fg) codes+=(38) ;|
    (bg) codes+=(48) ;|
    (fg|bg)
      if (( ARGC != 2 )); then
        spaceship::error \
          "incorrect argument count $ARGC (expecting 2 when first argument is $1)"
        return 2
      fi

      codes+=(2)

      case $2 in
        ($'\0') spaceship::colors::code::unset "$1"; return ;;
        (*) codes+=("${(s<,>@)$(spaceship::colors::map "$1" "$2")}") || return
      esac

      print -n "%{\\x1b[${(j<;>)codes}m%}"
      return
      ;;
    (*)
      spaceship::error "invalid argument ${(q+)2} (expecting : or fg or bg)"
      return 2
  esac
}

spaceship::colors::code::unset() {
  spaceship::debug spaceship::colors::code::unset ${(q+)argv}

  if (( ARGC != 1 )); then
    spaceship::error "incorrect argument count $ARGC (expecting 1)"
    return 2
  fi

  private fg_color=$'\0' bg_color=$'\0'

  if (( $#__spaceship_color_stack > 0 )); then
    case $1 in
      (:) ;;
      (fg) bg_color=$(spaceship::colors::peek bg) ;;
      (bg) fg_color=$(spaceship::colors::peek fg) ;;
      (*) spaceship::error "invalid argument ${(q+)1} (expecting : or fg or bg)"; return 2
    esac
  fi

  spaceship::colors::code::unset_all

  if [[ $fg_color != $'\0' ]]; then
    spaceship::colors::code fg "$fg_color" || return
  elif [[ $bg_color != $'\0' ]]; then
    spaceship::colors::code bg "$bg_color" || return
  fi
}

spaceship::colors::code::unset_all() {
  spaceship::debug spaceship::colors::code::unset_all ${(q+)argv}

  print -n '%{\x1b[0m%}'
}

spaceship::colors::map() {
  spaceship::debug spaceship::colors::map ${(q+)argv}

  private name
  case $ARGC in
    (2)
      if [[ $2 == \& ]]; then
        name=$(spaceship::colors::map::resolve_ref "$1") || {
          spaceship::error "prior ${(q+)1} color cannot be resolved to a name"
          return 3
        }
        spaceship::colors::map::name_to_rgb "$name"
      else
        spaceship::colors::map "$2"
      fi
      ;;
    (1)
      case $1 in
        ($'\0') return ;;
        (\&+) name=$(spaceship::colors::map::resolve_ref fg) ;|
        (\&-) name=$(spaceship::colors::map::resolve_ref bg) ;|
        (\&?)
          if [[ ! $name ]]; then
            spaceship::error "color reference ${(q+)1} cannot be resolved to a name"
            return 3
          fi

          spaceship::colors::map::name_to_rgb "$name"
          return
          ;;
        (\&)
          spaceship::error \
            'layer selection not specified for same-layer color reference' \
            '(expecting fg or bg)'
          return 2
          ;;
        (*) spaceship::colors::map::name_to_rgb "$1"
      esac
      ;;
    (*)
      spaceship::error "incorrect argument count $ARGC (expecting 1 or 2)"
      return 2
  esac
}

spaceship::colors::map::name_to_rgb() {
  spaceship::debug spaceship::colors::map::name_to_rgb ${(q+)argv}

  if ! (( ${+SPACESHIP_COLORMAP[$1]} )); then
    spaceship::error "ignoring unknown color ${(q+)1}"
    return 1
  fi

  print -n -- ${SPACESHIP_COLORMAP[$1]}
}

spaceship::colors::map::resolve_ref() {
  spaceship::debug spaceship::colors::map::resolve_ref ${(q+)argv}

  if (( ARGC < 1 || ARGC > 2 )); then
    spaceship::error "incorrect argument count $ARGC (expecting 1 or 2)"
    return 2
  fi

  private -i depth=${2-1}
  private color
  color=$(spaceship::colors::peek "$1" $depth) || return
  case $color in
    (\&) spaceship::colors::map::resolve_ref "$1" $((depth + 1)) || return ;;
    (\&+) spaceship::colors::map::resolve_ref fg $((depth + 1)) || return ;;
    (\&-) spaceship::colors::map::resolve_ref bg $((depth + 1)) || return ;;
    (*)
      spaceship::debug "resolved color reference to ${(q+)color}"
      print -n -- "$color"
  esac
}

spaceship::error() {
  spaceship::log error "$@"
}

spaceship::warning() {
  spaceship::log warning "$@"
}

spaceship::info() {
  spaceship::log info "$@"
}

spaceship::debug() {
  spaceship::log debug "$@"
}

spaceship::log() {
  if (( ARGC < 2 )); then
    spaceship::log::_error "incorrect argument count $ARGC (expecting at least 2)"
    return 2
  fi

  if [[ ! ${SPACESHIP_LOGLEVELS_ALL[(re)${~1}]} ]]; then
    spaceship::log::_error \
      "invalid logging level ${(q+)1} (expecting one of: ${(q+)SPACESHIP_LOGLEVELS_ALL})"
    return 2
  fi

  spaceship::log::level::includes "$1" || return 0

  private -a highlight=("${(0@)SPACESHIP_LOGLEVEL_HIGHLIGHTS[$1]}")
  private trace=$(spaceship::log::_trace "${SPACESHIP_LOGLEVEL_TRACE[$1]-'section'}")
  print -nrP "%F{blue}${trace}:%f ${highlight[1]}" >&2
  print -nr "$1: ${argv[2,-1]}" >&2
  print -rP $highlight[2] >&2
}

spaceship::log::level::includes() {
  if (( ARGC != 1 )); then
    spaceship::log::_error "incorrect argument count $ARGC (expecting 1)"
    return 2
  fi

  private query_i=${SPACESHIP_LOGLEVELS_ALL[(ie)$1]}
  if (( query_i > $#SPACESHIP_LOGLEVELS_ALL )); then
    spaceship::log::_error \
      "invalid log level ${(q+)1} (expecting one of: ${(@q+)SPACESHIP_LOGLEVELS_ALL})"
    return 2
  fi

  private current_i=${SPACESHIP_LOGLEVELS_ALL[(ie)$SPACESHIP_LOGLEVEL]}
  if (( current_i > $#SPACESHIP_LOGLEVELS_ALL )); then
    spaceship::log::_error "[internal] current log level ${(q+)SPACESHIP_LOGLEVEL} is invalid"
    return -1
  fi

  (( query_i <= current_i ))
}

spaceship::log::_error() {
  print -nrP "%F{blue}$(spaceship::log::_trace top top-log):%f %F{red}%Berror: " >&2
  print -nr $* >&2
  print -rP '%b%f' >&2
}

spaceship::log::_trace() {
  setopt local_options extended_glob

  private -i i_top=0 i_bottom=0
  case $ARGC in
    (2)
      case $2 in
        ('no-log') ;;
        ('lowest-log') argv[2]=() ;;
        ('top-log') i_top=2 ;;
        (*)
          spaceship::log::_trace::_error \
            "invalid trace top designator ${(q+)2} (expecting one of: no-log lowest-log top-log)"
          return 2
      esac
      ;|
    (1)
      i_top=${functrace[(I)(#s)spaceship::(error|warning|info|debug|log):<0-9>##(#e)]}

      if ! (( i_top )); then
        spaceship::log::_trace::_error \
          'spaceship::log::_trace was called from outside spaceship::log (incompatible usage)'
        return 2
      fi

      i_top+=1
      ;|
    (1|2)
      (( i_top )) || { spaceship::log::_trace::_error 'internal error'; return -1; }

      private -a patterns_x_offsets

      case $1 in
        (section)
          patterns_x_offsets=(
            'spaceship::section:<0-9>##' 1
            'spaceship::compose_prompt:<0-9>##' -1
            'spaceship::compose_prompt:<0-9>##' 0
            'spaceship::*prompt*:<0-9>##' 0
            'spaceship*:<0-9>##' 0
          )
          ;;
        (top) i_bottom=$((i_top + 1)) ;;
        (full) i_bottom=-2 ;;
        (*)
          spaceship::log::_trace::_error \
            "invalid trace depth designator ${(q+)1} (expecting one of: top section full)"
          return 2
      esac

      if ! (( i_bottom )); then
        private pattern offset
        for pattern offset in $patterns_x_offsets; do
          i_bottom=${functrace[(I)(#s)${~pattern}(#e)]}
          (( i_bottom )) && { i_bottom+=$offset; break; }
        done

        if ! (( i_bottom )); then
          spaceship::log::_trace::_error \
            "[internal] unable to resolve ${(q+)1} tracing to a stack depth;" \
            'falling back to a full trace'
          i_bottom=-2
        fi
      fi

      print -r -- "${(j<: >)${(q+@Oa)functrace[$i_top,$i_bottom]}}"
      return
      ;;
    (*)
      spaceship::log::_trace::_error "incorrect argument count $ARGC (expecting 1 or 2)"
      return 2
  esac

}

spaceship::log::_trace::_error() {
  print -rP "%F{blue}${(q+@Oa)functrace[1,-2]}:%f %F{red}%Berror: $*%b%f" >&2
}

if [[ ! -v __spaceship_color_stack ]]; then
  typeset -ga __spaceship_color_stack
fi
