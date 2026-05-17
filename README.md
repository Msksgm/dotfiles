# dotfiles

Personal dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Managed files

| Source | Target |
|---|---|
| `dot_zshrc` | `~/.zshrc` |
| `dot_zshenv` | `~/.zshenv` |
| `dot_zprofile` | `~/.zprofile` |
| `dot_p10k.zsh` | `~/.p10k.zsh` |
| `dot_zsh/alias.zsh` | `~/.zsh/alias.zsh` |
| `dot_tmux.conf` | `~/.tmux.conf` |
| `executable_dot_tmux-rename-session` | `~/.tmux-rename-session` |
| `dot_gitconfig` | `~/.gitconfig` |
| `dot_ideavimrc` | `~/.ideavimrc` |
| `dot_config/nvim/` | `~/.config/nvim/` |

## New machine setup

```sh
# 1. Install Homebrew (https://brew.sh)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install chezmoi and ghq
brew install chezmoi ghq

# 3. Clone dotfiles via ghq
ghq get git@github.com:Msksgm/dotfiles.git    # → ~/workspace/github.com/Msksgm/dotfiles

# 4. Configure chezmoi source
mkdir -p ~/.config/chezmoi
printf 'sourceDir = "~/workspace/github.com/Msksgm/dotfiles"\n' \
  > ~/.config/chezmoi/chezmoi.toml

# 5. Apply dotfiles
chezmoi apply

# 6. Install packages
brew bundle --file=~/workspace/github.com/Msksgm/dotfiles/Brewfile
```

## chezmoi cheatsheet

```sh
# Preview what would change
chezmoi diff

# Apply all managed files
chezmoi apply

# List managed files
chezmoi managed

# Re-apply after editing source
chezmoi apply -v

# Pull remote changes and apply
chezmoi update
```
