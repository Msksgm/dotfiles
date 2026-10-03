# App names come from the current org's mise.toml. Only define functions here:
# ~/.zsh/*.zsh is sourced before mise activation in ~/.zshrc.

_github_auth_require_apps() {
    emulate -L zsh
    local missing=0 variable_name
    for variable_name in GHTKN_GIT_APP_READ GHTKN_GIT_APP_WRITE; do
        if [[ -z "${(P)variable_name}" ]]; then
            printf '%s が未設定または空です。org の mise.toml に App 名を設定してください。\n' "$variable_name" >&2
            missing=1
        fi
    done
    return "$missing"
}

# Populate the caller's local git_options, git_subcommand and git_arguments.
# Keep the original argv for execution; options affecting repository/config
# discovery are also passed to the read-only metadata queries below.
_github_auth_parse_git_arguments() {
    emulate -L zsh
    git_options=()
    git_subcommand=''
    git_arguments=()
    while (( $# )); do
        case "$1" in
            -C|-c|--git-dir|--work-tree|--namespace|--super-prefix|--config-env)
                git_options+=("$1")
                shift
                if (( $# )); then
                    git_options+=("$1")
                    shift
                fi
                ;;
            -C?*|-c?*|--git-dir=*|--work-tree=*|--namespace=*|--super-prefix=*|--config-env=*|--attr-source=*|--exec-path=*)
                git_options+=("$1")
                shift
                ;;
            --bare|--no-replace-objects|--literal-pathspecs|--glob-pathspecs|--noglob-pathspecs|--icase-pathspecs|--no-optional-locks|--no-lazy-fetch|--no-advice)
                git_options+=("$1")
                shift
                ;;
            -p|-P|--paginate|--no-pager|--help|-h|--version|-v|--html-path|--man-path|--info-path|--exec-path|--list-cmds=*)
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                # Let Git report invalid/unsupported options itself.
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    if (( $# )); then
        git_subcommand="$1"
        shift
        git_arguments=("$@")
    fi
}

# Return the HTTPS equivalent in the caller's local REPLY. Host aliases and
# other services are deliberately excluded from this check.
_github_auth_https_url() {
    emulate -L zsh
    local url="$1" authority host_name repo_path
    REPLY=''
    if [[ "${url:l}" == git@github.com:* ]]; then
        REPLY="https://github.com/${url#*:}"
        return 0
    fi
    if [[ "${url:l}" == ssh://* ]]; then
        authority="${url#*://}"
        [[ "$authority" == */* ]] || return 1
        repo_path="${authority#*/}"
        authority="${authority%%/*}"
        host_name="${authority##*@}"
        host_name="${host_name%%:*}"
        if [[ "${host_name:l}" == github.com ]]; then
            REPLY="https://github.com/$repo_path"
            return 0
        fi
    fi
    return 1
}

# git remote set-url's old URL argument is an ERE, not a literal string.
_github_auth_quote_url_pattern() {
    emulate -L zsh
    local character
    REPLY='^'
    for character in "${(@s::)1}"; do
        case "$character" in
            '.'|'['|']'|'('|')'|'{'|'}'|'*'|'+'|'?'|'|'|'^'|'$'|'\')
                REPLY+="\\$character"
                ;;
            *) REPLY+="$character" ;;
        esac
    done
    REPLY+='$'
}

_github_auth_check_remotes() {
    emulate -L zsh
    local -a context=("$@") remote_names raw_urls urls fetch_urls repair
    local remote_listing remote_name url_listing raw_listing url fetch_url https_url old_url mode
    local REPLY index raw_rc implicit_push already_checked rejected=0

    # No repository is normal for clone, gh -R, or invocation outside ghq.
    command git "${context[@]}" rev-parse --git-dir >/dev/null 2>&1 || return 0
    remote_listing=$(command git "${context[@]}" remote) || return $?
    remote_names=("${(@f)remote_listing}")
    for remote_name in "${remote_names[@]}"; do
        [[ -n "$remote_name" ]] || continue
        fetch_urls=()
        for mode in url pushurl; do
            implicit_push=0
            raw_listing=$(command git "${context[@]}" config --get-all "remote.$remote_name.$mode")
            raw_rc=$?
            (( raw_rc > 1 )) && return "$raw_rc"
            if [[ -z "$raw_listing" ]]; then
                [[ "$mode" == pushurl ]] || continue
                # pushInsteadOf can change the implicit push URL independently
                # of fetch, so it still needs its own effective-URL query.
                implicit_push=1
            fi
            raw_urls=("${(@f)raw_listing}")
            if [[ "$mode" == pushurl ]]; then
                url_listing=$(command git "${context[@]}" remote get-url --push --all "$remote_name") || return $?
            else
                url_listing=$(command git "${context[@]}" remote get-url --all "$remote_name") || return $?
            fi
            urls=("${(@f)url_listing}")
            [[ "$mode" == url ]] && fetch_urls=("${urls[@]}")
            for (( index = 1; index <= ${#urls}; index++ )); do
                url="${urls[index]}"
                old_url="${raw_urls[index]:-$url}"
                # Require individual migration even when an existing rewrite
                # currently makes a stored SSH URL connect over HTTPS.
                if ! _github_auth_https_url "$old_url"; then
                    _github_auth_https_url "$url" || continue
                fi
                https_url="$REPLY"
                if (( implicit_push )); then
                    already_checked=0
                    for fetch_url in "${fetch_urls[@]}"; do
                        [[ "$fetch_url" == "$url" ]] && already_checked=1
                    done
                    (( already_checked )) && continue
                fi
                printf 'GitHub の SSH remote が残っています: %s (%s)。HTTPS に変更してください。\n' "$remote_name" "$mode" >&2
                rejected=1
                if (( ! implicit_push )) && [[ "${old_url:l}" == https://* ]]; then
                    # Replacing an already HTTPS URL cannot undo insteadOf.
                    printf '%s\n' '  HTTPS URL が SSH に読み替えられています。url.*.insteadOf の設定を修正してください。' >&2
                    continue
                fi
                if (( ! implicit_push )) && [[ "$old_url" != "$url" ]]; then
                    # remote set-url validates against effective URLs but
                    # replaces raw config values. Replace the raw value
                    # literally when a pre-existing rewrite makes them differ.
                    repair=(command git "${context[@]}" config --fixed-value --replace-all "remote.$remote_name.$mode" "$https_url" "$old_url")
                else
                    repair=(command git "${context[@]}" remote set-url)
                    [[ "$mode" == pushurl ]] && repair+=(--push)
                    repair+=("$remote_name" "$https_url")
                    if (( ! implicit_push )); then
                        _github_auth_quote_url_pattern "$old_url"
                        repair+=("$REPLY")
                    fi
                fi
                printf '  %s\n' "${(j: :)${(@q)repair}}" >&2
            done
        done
    done
    return "$rejected"
}

_github_auth_check_direct_urls() {
    emulate -L zsh
    local argument REPLY rejected=0
    for argument in "$@"; do
        if _github_auth_https_url "$argument"; then
            printf 'GitHub の SSH URL は使用できません。HTTPS URL を指定してください: %s\n' "$REPLY" >&2
            rejected=1
        fi
    done
    return "$rejected"
}

git() {
    emulate -L zsh
    _github_auth_require_apps || return 1
    local -a git_options git_arguments
    local git_subcommand app="$GHTKN_GIT_APP_READ"
    _github_auth_parse_git_arguments "$@"
    _github_auth_check_remotes "${git_options[@]}" || return $?
    case "$git_subcommand" in
        clone|fetch|pull|push|ls-remote|submodule)
            _github_auth_check_direct_urls "${git_arguments[@]}" || return 1
            ;;
    esac
    [[ "$git_subcommand" == push ]] && app="$GHTKN_GIT_APP_WRITE"
    GHTKN_GIT_APP="$app" command git "$@"
}

gh() {
    emulate -L zsh
    _github_auth_require_apps || return 1
    local app="$GHTKN_GIT_APP_READ"
    case "${1:-} ${2:-}" in
        'auth login')
            printf '%s\n' '認証には ghtkn auth を使ってください' >&2
            return 1
            ;;
        'auth token')
            printf '%s\n' 'トークンを表示せず、ghtkn exec で渡してください' >&2
            return 1
            ;;
        'pr create')
            _github_auth_check_remotes || return $?
            app="$GHTKN_GIT_APP_WRITE"
            ;;
        'repo create'|'release create'|'release delete')
            app="$GHTKN_GIT_APP_WRITE"
            ;;
    esac
    GHTKN_GIT_APP="$app" command ghtkn exec -e "GH_TOKEN:$app" -- gh "$@"
}
