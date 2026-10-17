# Add this repository's git-wt destination when starting a local Codex TUI.
# Only define functions here: ~/.zsh/*.zsh loads before mise activation.
_codex_worktree_paths() {
    emulate -L zsh
    local codex_cwd="$1" probe="$1" metadata common_dir main_root base_dir repo_name
    local -a fields

    # Outside a checkout, Codex needs neither Git nor org authentication.
    while [[ ! -e "$probe/.git" ]]; do
        [[ "$probe" != / ]] || return 0
        probe="${probe:h}"
    done

    metadata=$(
        cd -- "$codex_cwd" || exit $?
        MISE_AUTO_INSTALL=0 mise exec -- /bin/zsh -f -c '
            source "$HOME/.zsh/github-auth.zsh" || exit $?
            common_dir=$(git rev-parse --path-format=absolute --git-common-dir) || exit $?
            base_dir=$(git config --default .wt --get wt.basedir) || exit $?
            printf "%s\n%s\n" "$common_dir" "${base_dir:-.wt}"
        ' codex-worktree-paths
    ) || return $?
    fields=("${(@f)metadata}")
    if (( ${#fields} != 2 )) || [[ "${fields[1]}" != /* ]]; then
        print -u2 -- 'codex: git-wt の作成先を解決できませんでした。'
        return 1
    fi
    common_dir="${fields[1]}"
    base_dir="${fields[2]}"

    # Match git-wt: linked worktrees use the main repository, not their own cwd.
    main_root="$common_dir"
    [[ "${common_dir:t}" != .git ]] || main_root="${common_dir:h}"
    repo_name="${main_root:t}"
    base_dir="${base_dir//\{gitroot\}/$repo_name}"
    case "$base_dir" in
        '~') base_dir="$HOME" ;;
        '~/'*) base_dir="$HOME/${base_dir#\~/}" ;;
        /*) ;;
        *) base_dir="$main_root/$base_dir" ;;
    esac

    # The destination may not exist yet. Do not create it or change wt.basedir.
    # Shared Git metadata must remain writable when starting from a linked tree.
    printf '%s\n%s\n' "${base_dir:a}" "$common_dir"
}

codex() {
    emulate -L zsh
    local codex_cwd="$PWD" argument paths_output positional_seen=0
    local -a original_arguments=("$@") worktree_paths

    # Only TUI startup (including resume/fork) accepts our automatic additions.
    # Keep option values and literal prompts out of subcommand/cwd detection.
    while (( $# )); do
        argument="$1"
        shift
        case "$argument" in
            --) break ;;
            --remote|--remote=*|-h|--help|-V|--version)
                command codex "${original_arguments[@]}"
                return $?
                ;;
            -C|--cd)
                (( $# )) || { command codex "${original_arguments[@]}"; return $?; }
                codex_cwd="${1:a}"
                shift
                ;;
            -C?*|--cd=*)
                if [[ "$argument" == --cd=* ]]; then
                    codex_cwd="${argument#*=}"
                else
                    codex_cwd="${argument#-C}"
                fi
                codex_cwd="${codex_cwd:a}"
                ;;
            -c|--config|-m|--model|-p|--profile|-i|--image|-s|--sandbox|-a|--ask-for-approval|--add-dir|--enable|--disable|--local-provider|--remote-auth-token-env)
                (( $# )) || { command codex "${original_arguments[@]}"; return $?; }
                shift
                ;;
            -*) ;;
            *)
                if (( ! positional_seen )); then
                    positional_seen=1
                    case "$argument" in
                        resume|fork) ;;
                        agents|exec|e|review|login|logout|mcp|plugin|app-server|remote-control|app|completion|update|doctor|sandbox|debug|apply|a|queue|archive|delete|migrate-rollouts|unarchive|cloud|exec-server|features|help)
                            command codex "${original_arguments[@]}"
                            return $?
                            ;;
                    esac
                fi
                ;;
        esac
    done

    paths_output=$(_codex_worktree_paths "$codex_cwd") || return $?
    if [[ -z "$paths_output" ]]; then
        command codex "${original_arguments[@]}"
        return $?
    fi
    worktree_paths=("${(@f)paths_output}")
    command codex --add-dir "${worktree_paths[1]}" --add-dir "${worktree_paths[2]}" "${original_arguments[@]}"
}
