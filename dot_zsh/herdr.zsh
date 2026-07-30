# herdr の左サイドバー（agent パネル）に自分の pane ID を出すためのメタデータ報告。
#
# サイドバーの組み込みトークンは workspace/tab の「ラベル」しか描画できず pane ID を出せない。
# herdr が用意しているカスタムトークンの仕組みを使い、$pane_id という名前で報告して
# ~/.config/herdr/config.toml の [ui.sidebar.agents].rows から参照する。
#
# この関数はここでは呼ばない。~/.zsh/*.zsh は .zshrc の前半で source されるが、
# その時点では herdr がまだ PATH に無いため（理由は .zshrc の呼び出し箇所のコメント参照）、
# 呼び出しは .zshrc 側の mise activate 直後に置く。
_herdr_report_pane_id() {
  [[ -n "${HERDR_PANE_ID:-}" ]] || return 0
  (( $+commands[herdr] )) || return 0

  # 失敗は握りつぶす: サイドバーの表示だけのための処理で、シェル起動を壊してはならない。
  # &! で disown し、herdr サーバーへの往復でプロンプト表示を遅らせない。
  herdr pane report-metadata "$HERDR_PANE_ID" \
    --source dotfiles:paneid \
    --token pane_id="$HERDR_PANE_ID" >/dev/null 2>&1 &!
}
