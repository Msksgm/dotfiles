_dotfiles_drift_check() {
  local cache="${TMPDIR:-/tmp}dotfiles-drift-check"
  local today
  today=$(date +%Y-%m-%d)
  local force=0
  [[ "$1" == "--force" || "$1" == "-f" ]] && force=1

  # 1日1回のみ実行（--force/-f で強制実行するとスキップ）
  if (( force == 0 )); then
    [[ -f "$cache" && "$(cat "$cache")" == "$today" ]] && return
  fi
  echo "$today" > "$cache"

  local repo
  repo=$(chezmoi source-path 2>/dev/null) || return

  local warnings=()

  # 未コミットの変更
  if [[ -n "$(git -C "$repo" status --porcelain 2>/dev/null)" ]]; then
    warnings+=("未コミットの変更があります → git add / git commit")
  fi

  # リモートとの比較（fetch してから確認）
  git -C "$repo" fetch --quiet 2>/dev/null
  local behind ahead
  behind=$(git -C "$repo" rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
  ahead=$(git -C "$repo" rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
  (( behind > 0 )) && warnings+=("リモートより ${behind} コミット遅れています → git pull")
  (( ahead  > 0 )) && warnings+=("${ahead} コミットが未プッシュです → git push")

  # chezmoi の差分（source と home の乖離）
  if command -v chezmoi &>/dev/null && [[ -n "$(chezmoi diff 2>/dev/null)" ]]; then
    warnings+=("chezmoi に未適用の差分があります → chezmoi apply")
  fi

  if (( ${#warnings[@]} > 0 )); then
    echo "\033[33m[dotfiles drift]\033[0m"
    for w in "${warnings[@]}"; do
      echo "  · $w"
    done
  elif (( force == 1 )); then
    # 強制実行かつ drift なしの場合は明示的に通知
    echo "\033[32m[dotfiles drift]\033[0m drift なし"
  fi
}

_dotfiles_drift_check

# 手動で強制実行する（1日1回キャッシュを無視）
dotfiles-drift() { _dotfiles_drift_check --force; }
