#!/bin/bash
set -e

if [ "$(stat -c %u /app)" != "$(id -u claude)" ]; then
    chown -R claude:claude /app
fi

exec gosu claude "$@"
