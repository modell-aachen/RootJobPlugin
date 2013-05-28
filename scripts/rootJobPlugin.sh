#!/bin/bash
# This script will create a new virtual host and a corresponding solr config.
# Give the name of the new host als only parameter.
# If you want to reconfigure without creating a new host run with reconfigure
# Set the configuration below to your environment 

test -n "$SCRIPTDIR" && {
  cd "$SCRIPTDIR" || {
    echo "could not enter script dir $SCRIPTDIR"
    exit 1
  }
} 

test -z "$SCRIPTDIR" && {
  export SCRIPTDIR=`pwd`
}

### Config ###
test -e config.sh || {
  echo "Please set required options in config.sh (see config-example.sh for details)"
  exit 1
}
source $SCRIPTDIR/config.sh
for i in config_*.sh; do
  source "$SCRIPTDIR/$i"
done
for i in checkConfig*.sh; do
  source "$SCRIPTDIR/$i"
done

test -z "$RJPCONFIGCHECKED" && {
  echo "Config not verified ($BASH_SOURCE)"
  exit 1
}
### /Config ###

function restartServices {
  for eachfile in _restart*.sh; do
    test -e "$eachfile" && bash "$eachfile"
  done;
}

function reconfigureServices {
  for eachfile in _reconfigure*.sh; do
    test -e "$eachfile" && bash "$eachfile"
  done;
}

function importPARAM {
  local toimport=$1;
  local allowed=$2;

  test -z "$toimport" && {
    echo "importPARAM called without parameter!";
    return;
  }
  test -z "$allowed" && {
    echo "importPARAM called without whitelist!";
    return;
  }
  test -z $FILE && {
    echo "no file defined for importPARAM!";
    export $toimport="";
    return;
  }
  export $toimport="`sed -n \"s/^   \* $toimport=\($allowed\).*/\1/p\" <$CMDDIR/$FILE`"
}

### Main ###
COMMAND=$1

test "$COMMAND" = createApacheCoreConfig && {
  CORENAME=$2
  test "$USEAPACHEVHC" = "1" || { echo "You are not configured to use apache?!? (USEAPACHEVHC in config.sh)"; exit 1; }
  test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" -o -z "$APACHEVHCCONFIGCHECKED" && {
    echo "Config not checked ($BASH_SOURCE)!"
    exit 1
  }
  test -z "$CORENAME" && { echo "Please specify core-name as second parameter!"; exit 1; }
  test -d "$VHOST/$CORENAME" || { echo "Core does not exist in $VHOST/$CORENAME!"; exit 1; }
  bash "$SCRIPTDIR/_CreateWiki_apacheVHC.sh" $CORENAME
  exit 0
}

test "$COMMAND" = reconfigure && {
  export TOUCHEDCFG=1
  reconfigureServices
  restartServices
  echo "Finished reconfiguring."
  exit 0
}

test "$COMMAND" = cmd && {
  cd "$CMDDIR" || {
    echo "Could not change into $CMDDIR"
    exit 1;
  }
  test -z "`ls -A *.cmd 2> /dev/null`" && exit 0 # do nothing if empty directory, I'm open for suggestions for doing this a bit more elegantly
  for eachfile in *.cmd; do
    source "$SCRIPTDIR/_processFile.sh" "$eachfile"
  done
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
  test -n "`echo $NEW | sed -e "s/^$VHOSTREGEX\$//g"`" && {
    echo "Wiki name does not match VHOSTREGEX: $VHOSTREGEX"
    exit 1;
  }
  bash ./_createNewHost.sh $NEW
  reconfigureServices
  restartServices
  echo "Finished creating $NEW"
  exit 0;
}

test "$COMMAND" = ping && {
  source "$SCRIPTDIR/_Ping.sh"
  exit 0;
}

echo "Usage:"
echo "create a new host: rootJobPlugin.sh create <NewHostName>"
echo "reconfigure: rootJobPlugin.sh reconfigure"
echo "test configuration: rootJobPlugin.sh ping"
echo "run jobs in $CMDDIR: rootJobPlugin.sh cmd"
exit 3
