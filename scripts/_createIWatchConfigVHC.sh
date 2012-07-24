#!/bin/bash

test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
  echo "Config not verified"
  exit 1
}

export CORE
export VHOST
export INDEXCMD
export IWATCHDTD
export CMDDIR
export SCRIPTDIR

echo "Creating VirtualHosting config for iWatch..."
cd $VHOST
perl -wT $SCRIPTDIR/_createIWatchConfigVHC.pl >> $WRPTMPDIR/iwatchtmp.txt || {
  echo "Could not create new iWatch config"
  exit 1
}
