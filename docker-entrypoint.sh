#!/bin/sh
set -ex
SYNDICATE_DATA=/home/syndicate/.Syndicate
#cd /home/syndicate/syndicated

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for Syndicated"

  set -- Syndicated "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "Syndicated" ]; then
  mkdir -p "$SYNDICATE_DATA"
  chmod 700 "$SYNDICATE_DATA"
  chown -R syndicate "$SYNDICATE_DATA"

  echo "$0: setting data directory to $SYNDICATE_DATA"

  set -- "$@" -datadir="$SYNDICATE_DATA"
fi

if [ "$1" = "Syndicated" ] || [ "$1" = "Syndicate-cli" ] || [ "$1" = "Syndicate-tx" ]; then
  echo
  exec gosu syndicate "$@"
fi

echo
exec "$@"
