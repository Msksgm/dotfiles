#!/bin/bash
set -e

# rustup の初期化（~/.cargo/env を生成）
if [[ ! -f "$HOME/.cargo/env" ]]; then
  rustup-init -y --no-modify-path
fi
