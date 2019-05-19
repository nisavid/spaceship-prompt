#
# Spaceship ZSH
#
# Author: Denys Dovhan, denysdovhan.com
# License: MIT
# https://github.com/denysdovhan/spaceship-prompt

zmodload zsh/param/private

# Current version of Spaceship
# Useful for issue reporting
export SPACESHIP_VERSION='3.11.0'

# Common-used variable for new line separator
NEWLINE='
'

# Determination of Spaceship working directory
# https://git.io/vdBH7
if [[ -z "$SPACESHIP_ROOT" ]]; then
  if [[ "${(%):-%N}" == '(eval)' ]]; then
    if [[ "$0" == '-antigen-load' ]] && [[ -r "${PWD}/spaceship.zsh" ]]; then
      # Antigen uses eval to load things so it can change the plugin (!!)
      # https://github.com/zsh-users/antigen/issues/581
      export SPACESHIP_ROOT=$PWD
    else
      print -P "%F{red}You must set SPACESHIP_ROOT to work from within an (eval).%f"
      return 1
    fi
  else
    # Get the path to file this code is executing in; then
    # get the absolute path and strip the filename.
    # See https://stackoverflow.com/a/28336473/108857
    export SPACESHIP_ROOT=${${(%):-%x}:A:h}
  fi
fi

# ------------------------------------------------------------------------------
# CONFIGURATION
# The default configuration that can be overridden in .zshrc
# ------------------------------------------------------------------------------

if [ -z "$SPACESHIP_PROMPT_ORDER" ]; then
  SPACESHIP_PROMPT_ORDER=(
    time          # Time stampts section
    user          # Username section
    dir           # Current directory section
    host          # Hostname section
    git           # Git section (git_branch + git_status)
    hg            # Mercurial section (hg_branch  + hg_status)
    package       # Package version
    node          # Node.js section
    ruby          # Ruby section
    elm           # Elm section
    elixir        # Elixir section
    xcode         # Xcode section
    swift         # Swift section
    golang        # Go section
    php           # PHP section
    rust          # Rust section
    haskell       # Haskell Stack section
    julia         # Julia section
    docker        # Docker section
    aws           # Amazon Web Services section
    venv          # virtualenv section
    conda         # conda virtualenv section
    pyenv         # Pyenv section
    dotnet        # .NET section
    ember         # Ember.js section
    kubecontext   # Kubectl context section
    terraform     # Terraform workspace section
    exec_time     # Execution time
    line_sep      # Line break
    battery       # Battery level and status
    vi_mode       # Vi-mode indicator
    jobs          # Background jobs indicator
    exit_code     # Exit code section
    char          # Prompt character
  )
fi

if [ -z "$SPACESHIP_RPROMPT_ORDER" ]; then
  SPACESHIP_RPROMPT_ORDER=(
    # empty by default
  )
fi

# PROMPT
SPACESHIP_PROMPT_ADD_NEWLINE="${SPACESHIP_PROMPT_ADD_NEWLINE=true}"
SPACESHIP_PROMPT_SEPARATE_LINE="${SPACESHIP_PROMPT_SEPARATE_LINE=true}"
SPACESHIP_PROMPT_FIRST_PREFIX_SHOW="${SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=false}"
SPACESHIP_PROMPT_PREFIXES_SHOW="${SPACESHIP_PROMPT_PREFIXES_SHOW=true}"
SPACESHIP_PROMPT_SUFFIXES_SHOW="${SPACESHIP_PROMPT_SUFFIXES_SHOW=true}"
SPACESHIP_PROMPT_DEFAULT_PREFIX="${SPACESHIP_PROMPT_DEFAULT_PREFIX="via "}"
SPACESHIP_PROMPT_DEFAULT_SUFFIX="${SPACESHIP_PROMPT_DEFAULT_SUFFIX=" "}"
SPACESHIP_PROMPT_DEFAULT_DIVIDER="${SPACESHIP_PROMPT_DEFAULT_DIVIDER="•"}"

if [[ ! -v SPACESHIP_DEFAULT_COLORMAP ]]; then
  readonly -gA SPACESHIP_DEFAULT_COLORMAP=(
    black 21,21,21
    red 255,82,82
    green 195,216,44
    yellow 255,193,53
    blue 66,165,254
    magenta 216,27,96
    cyan 0,172,193
    white 161,176,184
    brblack 112,130,132
    brwhite 245,245,245
  )
fi

if [[ ! -v SPACESHIP_COLORMAP ]]; then
  typeset -gA SPACESHIP_COLORMAP=("${(kv@)SPACESHIP_DEFAULT_COLORMAP}")
fi

if [[ ! -v SPACESHIP_LOGLEVELS_ALL ]]; then
  readonly -ga SPACESHIP_LOGLEVELS_ALL=( error warning info debug )
fi

if [[ ! -v SPACESHIP_DEFAULT_LOGLEVEL_HIGHLIGHTS ]]; then
  readonly -gA SPACESHIP_DEFAULT_LOGLEVEL_HIGHLIGHTS=(
    error $'%F{red}%B\0%b%f'
    warning $'%F{yellow}%B\0%b%f'
    info $'%F{cyan}\0%f'
    debug $'%F{magenta}\0%f'
  )
fi

if [[ ! -v SPACESHIP_LOGLEVEL_HIGHLIGHTS ]]; then
  typeset -gA SPACESHIP_LOGLEVEL_HIGHLIGHTS=("${(kv@)SPACESHIP_DEFAULT_LOGLEVEL_HIGHLIGHTS}")
fi

if [[ ! -v SPACESHIP_LOGLEVEL_TRACE ]]; then
  typeset -gA SPACESHIP_LOGLEVEL_TRACE=(
    error section
    warning section
    info top
    debug full
  )
fi

if [[ ! -v __spaceship_prompt_opened ]]; then
  typeset -g __spaceship_prompt_opened=$SPACESHIP_PROMPT_FIRST_PREFIX_SHOW
fi

typeset -g __spaceship_is_in_rprompt

typeset -ga __spaceship_sections_rendered

[[ ! -v SPACESHIP_LOGLEVEL ]] && typeset -g SPACESHIP_LOGLEVEL='warning'

# ------------------------------------------------------------------------------
# LIBS
# Spaceship utils/hooks/etc
# ------------------------------------------------------------------------------

# Load utils
source "$SPACESHIP_ROOT/lib/utils.zsh"

# load hooks
source "$SPACESHIP_ROOT/lib/hooks.zsh"

# load section utils
source "$SPACESHIP_ROOT/lib/section.zsh"

# ------------------------------------------------------------------------------
# SECTIONS
# Sourcing sections the prompt consists of
# ------------------------------------------------------------------------------

for section in $(spaceship::union $SPACESHIP_PROMPT_ORDER $SPACESHIP_RPROMPT_ORDER); do
  if [[ -f "$SPACESHIP_ROOT/sections/$section.zsh" ]]; then
    source "$SPACESHIP_ROOT/sections/$section.zsh"
  elif spaceship::defined "spaceship_$section"; then
    # Custom section is declared, nothing else to do
    continue
  else
    echo "Section '$section' have not been loaded."
  fi
done

# ------------------------------------------------------------------------------
# BACKWARD COMPATIBILITY WARNINGS
# Show deprecation messages for options that are set, but not supported
# ------------------------------------------------------------------------------

spaceship::deprecated SPACESHIP_PROMPT_SYMBOL "Use %BSPACESHIP_CHAR_SYMBOL%b instead."
spaceship::deprecated SPACESHIP_BATTERY_ALWAYS_SHOW "Use %BSPACESHIP_BATTERY_SHOW='always'%b instead."
spaceship::deprecated SPACESHIP_BATTERY_CHARGING_SYMBOL "Use %BSPACESHIP_BATTERY_SYMBOL_CHARGING%b instead."
spaceship::deprecated SPACESHIP_BATTERY_DISCHARGING_SYMBOL "Use %BSPACESHIP_BATTERY_SYMBOL_DISCHARGING%b instead."
spaceship::deprecated SPACESHIP_BATTERY_FULL_SYMBOL "Use %BSPACESHIP_BATTERY_SYMBOL_FULL%b instead."

# ------------------------------------------------------------------------------
# PROMPTS
# An entry point of prompt
# ------------------------------------------------------------------------------

# PROMPT
# Primary (left) prompt
spaceship::prompt() {
  # Retrieve exit code of last command to use in exit_code
  # Must be captured before any other command in prompt is executed
  # Must be the very first line in all entry prompt functions, or the value
  # will be overridden by a different command execution - do not move this line!
  local -i RETVAL=$?

  [[ $SPACESHIP_PROMPT_ADD_NEWLINE == true ]] && print
  spaceship::compose_prompt $SPACESHIP_PROMPT_ORDER
}

# $RPROMPT
# Optional (right) prompt
spaceship::rprompt() {
  # Retrieve exit code of last command to use in exit_code
  local -i RETVAL=$?

  typeset -g __spaceship_is_in_rprompt=true
  spaceship::compose_prompt $SPACESHIP_RPROMPT_ORDER
  unset __spaceship_is_in_rprompt
}

# PS2
# Continuation interactive prompt
spaceship::prompt2() {
  # Retrieve exit code of last command to use in exit_code
  local -i RETVAL=$?

  spaceship::section \
    "$SPACESHIP_CHAR_COLOR_SECONDARY" \
    '' \
    '' \
    '! spaceship::prompt2::content' \
    "$SPACESHIP_CHAR_SUFFIX"

  spaceship::colors::clear
}

spaceship::prompt2::content() {
  case $SPACESHIP_CHAR_PREFIX_COLOR_SECONDARY in
    (*,*) spaceship::colors::push : ${(s<,>)SPACESHIP_CHAR_PREFIX_COLOR_SECONDARY} || return ;;
    (*) spaceship::colors::push bg $SPACESHIP_CHAR_PREFIX_COLOR_SECONDARY || return
  esac

  print -nP -- "$SPACESHIP_CHAR_PREFIX_SECONDARY"

  spaceship::colors::pop

  print -nP -- "$SPACESHIP_CHAR_SYMBOL_SECONDARY"
}

# ------------------------------------------------------------------------------
# SETUP
# Setup requirements for prompt
# ------------------------------------------------------------------------------

# Runs once when user opens a terminal
# All preparation before drawing prompt should be done here
spaceship::setup() {
  autoload -Uz vcs_info
  autoload -Uz add-zsh-hook

  # This variable is a magic variable used when loading themes with zsh's prompt
  # function. It will ensure the proper prompt options are set.
  prompt_opts=(cr percent sp subst)

  # Borrowed from promptinit, sets the prompt options in case the prompt was not
  # initialized via promptinit.
  setopt noprompt{bang,cr,percent,subst} "prompt${^prompt_opts[@]}"

  # Add exec_time hooks
  add-zsh-hook preexec spaceship_exec_time_preexec_hook
  add-zsh-hook precmd spaceship_exec_time_precmd_hook

  # Disable python virtualenv environment prompt prefix
  VIRTUAL_ENV_DISABLE_PROMPT=true

  # Configure vcs_info helper for potential use in the future
  add-zsh-hook precmd spaceship_exec_vcs_info_precmd_hook
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:git*' formats '%b'

  # Expose Spaceship to environment variables
  PROMPT='$(spaceship::prompt)'
  PROMPT2='$(spaceship::prompt2)'
  RPROMPT='$(spaceship::rprompt)'
}

# ------------------------------------------------------------------------------
# ENTRY POINT
# An entry point of prompt
# ------------------------------------------------------------------------------

# Pass all arguments to the spaceship_setup function
spaceship::setup "$@"
