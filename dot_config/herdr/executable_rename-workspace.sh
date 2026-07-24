#!/bin/zsh

# herdr の focused workspace を、pane の作業ディレクトリの git リポジトリ名
# （リポジトリ外なら cwd の basename）にリネームする。
# tmux の ~/.tmux-rename-session（prefix+R）の herdr 版。
# config.toml の [[keys.command]] から prefix+shift+r で呼び出す。
#
# step:
#   1. focused pane から workspace_id と作業ディレクトリを取得する
#   2. git リポジトリ名（無ければ cwd の basename）から名前を決める
#   3. herdr workspace rename でリネームする
#
# 引数:
#   $1 (任意): 明示的な workspace 名。省略時は cwd から自動導出する。

set -euo pipefail

# herdr を detached で起動した場合に mise shim / homebrew が PATH に無いことがあるため保険を張る
if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
fi
export PATH="$HOME/.local/share/mise/shims:$PATH"

for cmd in herdr jq git; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        print -u2 "rename-workspace: '$cmd' が見つかりません"
        exit 1
    fi
done

# 1. focused pane の情報を取得する
pane_json="$(herdr pane current)"
workspace_id="$(print -r -- "$pane_json" | jq -r '.result.pane.workspace_id')"
cwd="$(print -r -- "$pane_json" | jq -r '.result.pane.foreground_cwd')"

if [[ -z "$workspace_id" || "$workspace_id" == "null" ]]; then
    print -u2 "rename-workspace: focused workspace を特定できませんでした"
    exit 1
fi

# 2. workspace 名を決める（tmux 版と同じく git toplevel > cwd の basename）
if [[ $# -ge 1 ]]; then
    directory="$1"
elif git -C "$cwd" rev-parse --show-toplevel >/dev/null 2>&1; then
    directory="$(basename "$(git -C "$cwd" rev-parse --show-toplevel)")"
else
    directory="$(basename "$cwd")"
fi

# 3. リネームする（tmux 版同様 "." を "_" に置換）
herdr workspace rename "$workspace_id" "${directory//./_}"
