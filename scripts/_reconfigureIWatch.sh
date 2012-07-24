#!/bin/bash
# This script will create the configuration for solr and iwatch.
# It expects the following environment variables
#    SOLR: path to solr home
#    SCRIPTDIR: directory where scripts reside

test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
  echo "Config not verified"
  exit 1
}

# iWatch
test -n "$USEIWATCH" && test -n "$TOUCHEDIWATCHCFG" -o -n "$TOUCHEDCFG" && {
  echo "Creating new config for iWatch..."

  # Create header
  test -z "$WRPTMPDIR" && WRPTMPDIR="$SCRIPTDIR"
  cd $SCRIPTDIR
  test -e iwatchheader.txt || {
    echo "iwatchheader.txt not found, could not create iwatch configuration."
    exit 1
  }
  # I copy the header so I don't have to put up with ACLs and ownership etc.
  cp -p iwatchheader.txt $WRPTMPDIR/iwatchtmp.txt || {
    echo "Could not create temporary file $WRPTMPDIR/iwatchtmp.txt."
    exit 1
  }
  echo "<!DOCTYPE config SYSTEM \"$IWATCHDTD\" >
  
<config>
  <guard email=\"$WRPEMAIL\" name=\"IWatch\" />" >> $WRPTMPDIR/iwatchtmp.txt

  # Create contents
  for i in _createIWatchConfig*.sh; do
    test -e $i && sh $i
  done
  # config for this script
  echo "  <watchlist>
  <title>WikiRootPlugin</title>
  <contactpoint email=\"$WRPEMAIL\" name=\"Administrator\" />
  <path type=\"single\" events=\"create\" alert=\"off\" syslog=\"off\" exec=\"cd $SCRIPTDIR; ./rootJobPlugin.sh cmd >> $ROOTJOBLOG/cmd.log\">$CMDDIR</path>
  </watchlist>" >> $WRPTMPDIR/iwatchtmp.txt

#    test -e $IWATCHCFG.bck && {
#      echo " restoring from $IWATCH.bck"
#      mv $IWATCHCFG.bck $IWATCHCFG
#    }

  # Create footer
  echo "</config>" >> $WRPTMPDIR/iwatchtmp.txt

  # Install new config
  test -e $IWATCHCFG && {
    mv $IWATCHCFG $IWATCHCFG.bck
  }
  mv $WRPTMPDIR/iwatchtmp.txt $IWATCHCFG
}
