#!/bin/bash
# codemapが未インストールなら何もしない
if ! command -v codemap &>/dev/null; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
cd "$PROJECT_DIR"

# インデックスがなければ初期化
if [ ! -d ".codemap" ]; then
  codemap init . 2>/dev/null
fi

# すでにwatchプロセスが動いていなければ起動
if ! pgrep -f "codemap watch" > /dev/null; then
  codemap watch . > /tmp/codemap_watch.log 2>&1 &
  echo "codemap watch started (PID: $!)"
fi

exit 0
