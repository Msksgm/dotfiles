_dotfiles_drift_check() {
  local cache="${TMPDIR:-/tmp}dotfiles-drift-check"
  local today
  today=$(date +%Y-%m-%d)

  # 1日1回のみ実行
  [[ -f "$cache" && "$(cat "$cache")" == "$today" ]] && return
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
  fi
}

_dotfiles_drift_check
