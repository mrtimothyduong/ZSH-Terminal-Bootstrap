# ~/.zshrc — optimised for fast startup
# Measure:  time (zsh -i -c exit)
# Profile:  uncomment zmodload/zprof lines, then run `zprof` in a new shell
# Bust caches: zsh-cache-clear

# zmodload zsh/zprof

# ─── Homebrew ──────────────────────────────────────────────────────────
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# ─── PATH (set once, deduped) ──────────────────────────────────────────
typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "$HOME/.atuin/bin"
    "$HOME/.cargo/bin"
    "$HOME/.lmstudio/bin"
    $path
)
export PATH

# ─── OH-MY-ZSH ─────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
export UPDATE_ZSH_DAYS=30
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# ─── Source plugins directly (skips OMZ plugin-loader overhead) ────────
_omz_custom="${ZSH_CUSTOM:-$ZSH/custom}/plugins"
[[ -f "$_omz_custom/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] \
    && source "$_omz_custom/zsh-autosuggestions/zsh-autosuggestions.zsh"
# fast-syntax-highlighting must load AFTER anything else that touches ZLE
[[ -f "$_omz_custom/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]] \
    && source "$_omz_custom/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
unset _omz_custom

# ─── Cache slow `eval "$(tool init zsh)"` invocations ──────────────────
_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$_cache_dir" ]] || mkdir -p "$_cache_dir"

_load_cached() {
    emulate -L zsh
    local name="$1"; shift
    local dep=""
    if [[ "$1" == "--dep" ]]; then dep="$2"; shift 2; fi
    local cache="$_cache_dir/$name.zsh"
    local errlog="$cache.err"
    local stale=0
    [[ ! -s "$cache" ]] && stale=1
    [[ -n "$dep" && -f "$dep" && "$dep" -nt "$cache" ]] && stale=1
    [[ -n "$(find "$cache" -mtime +7 2>/dev/null)" ]] && stale=1
    if (( stale )); then
        if ! "$@" >"$cache" 2>"$errlog" || [[ ! -s "$cache" ]]; then
            print -u2 "zshrc: failed to regenerate cache '$name' — see $errlog"
            rm -f "$cache"; return 1
        fi
        [[ -s "$errlog" ]] || rm -f "$errlog"
    fi
    source "$cache"
}

zsh-cache-clear() {
    rm -f "$_cache_dir"/*.zsh "$_cache_dir"/*.err
    print "Cleared zsh cache in $_cache_dir. Run 'exec zsh' to reload."
}

command -v atuin &>/dev/null && _load_cached atuin atuin init zsh

if [[ -f ~/.quick-term.omp.json ]] && command -v oh-my-posh &>/dev/null; then
    _load_cached omp --dep ~/.quick-term.omp.json \
        oh-my-posh init zsh --config ~/.quick-term.omp.json
else
    PS1='%n@%m:%~$ '
fi

# ─── Compile zcompdump in background ───────────────────────────────────
{
    if [[ -s "$HOME/.zcompdump" && \
          ( ! -s "$HOME/.zcompdump.zwc" || "$HOME/.zcompdump" -nt "$HOME/.zcompdump.zwc" ) ]]; then
        zcompile "$HOME/.zcompdump"
    fi
} &!

# ─── iTerm2 integration ────────────────────────────────────────────────
[[ -e "${HOME}/.iterm2_shell_integration.zsh" ]] \
    && source "${HOME}/.iterm2_shell_integration.zsh"

# ─── iTerm profile switching for agent CLIs ────────────────────────────
_iterm_profile() { printf '\033]1337;SetProfile=%s\007' "$1"; }
_iterm_active=""

_iterm_precmd_restore() {
    [[ -n $_iterm_active ]] || return
    _iterm_profile Default
    _iterm_active=""
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _iterm_precmd_restore

_iterm_run() {
    local p=$1 c=$2; shift 2
    _iterm_active=$p
    _iterm_profile "$p"
    command "$c" "$@"
    local rc=$?
    _iterm_precmd_restore
    return $rc
}

claude()  { _iterm_run agent-claude  claude  "$@"; }
codex()   { _iterm_run agent-codex   codex   "$@"; }
gemini()  { _iterm_run agent-gemini  gemini  "$@"; }
copilot() { _iterm_run agent-copilot copilot "$@"; }

# zprof