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
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
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
ZSH_THEME=""                              # prompt comes from oh-my-posh below
zstyle ':omz:update' mode reminder        # never block startup on an update prompt
zstyle ':omz:update' frequency 30
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# ─── Source plugins directly (skips OMZ plugin-loader overhead) ────────
_omz_custom="${ZSH_CUSTOM:-$ZSH/custom}/plugins"

# zsh-autosuggestions: prefer OMZ custom install, fall back to Homebrew or apt
if [[ -f "$_omz_custom/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$_omz_custom/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "/home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# fast-syntax-highlighting must load AFTER anything else that touches ZLE
[[ -f "$_omz_custom/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]] \
    && source "$_omz_custom/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
unset _omz_custom

# ─── Cache slow `eval "$(tool init zsh)"` invocations ──────────────────
_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$_cache_dir" ]] || mkdir -p "$_cache_dir"

# Usage: _load_cached <name> [--dep <file>]... <command...>
# The cache is rebuilt when missing, older than 7 days, or older than any --dep file.
_load_cached() {
    emulate -L zsh
    local name="$1"; shift
    local -a deps
    while [[ "$1" == "--dep" ]]; do deps+=("$2"); shift 2; done
    local cache="$_cache_dir/$name.zsh"
    local errlog="$cache.err"
    local stale=0 d
    [[ ! -s "$cache" ]] && stale=1
    for d in $deps; do
        [[ -n "$d" && -e "$d" && "$d" -nt "$cache" ]] && stale=1
    done
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

# Depending on the binary itself means an upgrade regenerates the cache immediately.
(( $+commands[atuin] )) && _load_cached atuin --dep "$commands[atuin]" atuin init zsh

if [[ -f ~/.quick-term.omp.json ]] && (( $+commands[oh-my-posh] )); then
    _load_cached omp --dep ~/.quick-term.omp.json --dep "$commands[oh-my-posh]" \
        oh-my-posh init zsh --config ~/.quick-term.omp.json
else
    PS1='%n@%m:%~$ '
fi

# ─── Compile zcompdump in background ───────────────────────────────────
{
    if [[ -s "$ZSH_COMPDUMP" && \
          ( ! -s "$ZSH_COMPDUMP.zwc" || "$ZSH_COMPDUMP" -nt "$ZSH_COMPDUMP.zwc" ) ]]; then
        zcompile "$ZSH_COMPDUMP"
    fi
} &!

# ─── iTerm2 integration ────────────────────────────────────────────────
[[ -e "${HOME}/.iterm2_shell_integration.zsh" ]] \
    && source "${HOME}/.iterm2_shell_integration.zsh"
