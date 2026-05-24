_brew_drift_check() {
  local cache="${TMPDIR:-/tmp/}dotfiles-brew-drift-check"
  local today
  today=$(date +%Y-%m-%d)

  # 1日1回のみ実行
  [[ -f "$cache" && "$(cat "$cache")" == "$today" ]] && return
  echo "$today" > "$cache"

  command -v brew &>/dev/null || return

  local repo
  repo=$(chezmoi source-path 2>/dev/null) || return
  local brewfile="${repo}/Brewfile"
  [[ -f "$brewfile" ]] || return

  local found_drift=0

  # Brewfile にあるが未 install のもの（exit code 1 = 未 install あり）
  local check_out
  check_out=$(brew bundle check --file="$brewfile" --verbose 2>/dev/null)
  if [[ $? -ne 0 ]]; then
    local missing_lines=()
    while IFS= read -r line; do
      [[ "$line" == "→ "* ]] && missing_lines+=("${line#→ }")
    done <<< "$check_out"
    (( found_drift == 0 )) && { echo "\033[33m[brew drift]\033[0m"; found_drift=1; }
    echo "  · Brewfile に未 install (${#missing_lines[@]} 件) → brew bundle install で確認してからインストール"
    for l in "${missing_lines[@]}"; do
      echo "      ${l% needs to be installed.}"
    done
  fi

  # install 済みだが Brewfile に無いもの
  local cleanup_out
  cleanup_out=$(brew bundle cleanup --file="$brewfile" 2>/dev/null)
  if [[ -n "$cleanup_out" ]]; then
    local extra_lines=()
    local current_type=""
    while IFS= read -r line; do
      case "$line" in
        "Would uninstall casks:"*)       current_type="cask" ;;
        "Would uninstall formulae:"*)    current_type="formula" ;;
        "Would uninstall Go packages:"*) current_type="go" ;;
        "Run \`"*|"") ;;
        *) extra_lines+=("[${current_type}] ${line}") ;;
      esac
    done <<< "$cleanup_out"
    (( found_drift == 0 )) && { echo "\033[33m[brew drift]\033[0m"; found_drift=1; }
    echo "  · Brewfile 外の install 済み (${#extra_lines[@]} 件)"
    echo "      → Brewfile に残す場合: brewfile-add <formula>"
    echo "      → 削除する場合: brew bundle cleanup --force"
    for l in "${extra_lines[@]}"; do
      echo "      $l"
    done
  fi
}

_brew_drift_check

# Brewfile に formula / cask を1行追加するヘルパー
# 使い方: brewfile-add <formula>  or  brewfile-add --cask <cask>
brewfile-add() {
  local type="brew"
  local name=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --cask) type="cask"; shift ;;
      *)      name="$1";   shift ;;
    esac
  done
  if [[ -z "$name" ]]; then
    echo "usage: brewfile-add [--cask] <name>" >&2
    return 1
  fi

  local repo
  repo=$(chezmoi source-path 2>/dev/null) || { echo "chezmoi source-path failed" >&2; return 1; }
  local brewfile="${repo}/Brewfile"
  [[ -f "$brewfile" ]] || { echo "Brewfile not found: $brewfile" >&2; return 1; }

  local entry="${type} \"${name}\""
  if grep -qF "$entry" "$brewfile"; then
    echo "already in Brewfile: $entry"
    return 0
  fi
  echo "$entry" >> "$brewfile"
  echo "added to Brewfile: $entry"
}
