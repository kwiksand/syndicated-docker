#!/bin/bash

set -e
SYNDICATE_DATA=/home/syndicate/.Syndicate
CONFIG_FILE=Syndicate.conf

if [ -z "$1" ] || [ "$1" == "syndicated" ] || [ "$(echo "$0" | cut -c1)" == "-" ]; then
  cmd=syndicated
  shift

  if [ ! -d $SYNDICATE_DATA ]; then
    echo "$0: DATA DIR ($SYNDICATE_DATA) not found, please create and add config.  exiting...."
    exit 1
  fi

  if [ ! -f $SYNDICATE_DATA/$CONFIG_FILE ]; then
    echo "$0: syndicated config ($SYNDICATE_DATA/$CONFIG_FILE) not found, please create.  exiting...."
    exit 1
  fi

  chmod 700 "$SYNDICATE_DATA"
  chown -R syndicate "$SYNDICATE_DATA"

  if [ -z "$1" ] || [ "$(echo "$1" | cut -c1)" == "-" ]; then
    echo "$0: assuming arguments for syndicated"

    set -- $cmd "$@" -datadir="$SYNDICATE_DATA"
  else
    set -- $cmd -datadir="$SYNDICATE_DATA"
  fi

  exec gosu syndicate "$@"
else
  echo "This entrypoint will only execute syndicated, syndicate-cli and syndicate-tx"
fi
