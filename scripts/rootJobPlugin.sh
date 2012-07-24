#!/bin/bash
# This script will create a new virtual host and a corresponding solr config.
# Give the name of the new host als only parameter.
# If you want to reconfigure without creating a new host run with reconfigure
# Set the configuration below to your environment 

test -n "$SCRIPTDIR" && {
  cd $SCRIPTDIR || {
    echo "could not enter script dir $SCRIPTDIR"
    exit 1
  }
} 

test -z "$SCRIPTDIR" && {
  export SCRIPTDIR=`pwd`
}

### Config ###
test -e config.sh || {
  echo "wikiCreator: Please set required options in config.sh (see config-example.sh for details)"
  exit 1
}
for i in config*.sh; do
  source $i
done
for i in checkConfig*.sh; do
  source $i
done

test -z "$RJPCONFIGCHECKED" && {
  echo "Config not verified"
  exit 1
}
### /Config ###

function restartServices {
  for eachfile in _restart*.sh; do
    test -e $eachfile && sh $eachfile
  done;
}

function reconfigureServices {
  for eachfile in _reconfigure*.sh; do
    test -e $eachfile && sh $eachfile
  done;
}

### Main ###
COMMAND=$1

test "$COMMAND" = reconfigure && {
  export TOUCHEDCFG=1
  reconfigureServices
  restartServices
  echo "Finished reconfiguring."
  exit 0
}

test "$COMMAND" = cmd && {
  cd $CMDDIR || {
    echo "Could not change into $CMDDIR"
    exit 1;
  }
  test -z "`ls -A *.cmd 2> /dev/null`" && exit 0 # do nothing if empty directory, I'm open for suggestions for doing this a bit more elegantly
  for eachfile in *.cmd; do
    source $SCRIPTDIR/_processFile.sh $eachfile;
  done;
  reconfigureServices
  restartServices
  echo "Finished with requests."
  exit 0;
}

test "$COMMAND" = create && {
  NEW=$2
  test -z "$NEW" && {
    echo "Please specify wiki name."
    exit 1;
  }
  ./_createNewHost.sh $NEW
  reconfigureServices
  restartServices
  echo "Finished creating $NEW"
  exit 0;
}

echo "Usage:"
echo "create a new host: cd <ScriptDir>; ./rootJobPlugin.sh create <NewHostName>"
echo "reconfigure: cd <ScriptDir>; ./rootJobPlugin.sh reconfigure"
echo "run jobs in $CMDDIR: cd <ScriptDir>; ./rootJobPlugin.sh cmd"
exit 3
