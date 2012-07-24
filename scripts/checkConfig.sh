test -z "$SCRIPTDIR" && {
  echo "SCRIPTDIR not set"
  exit 1
}
test -d $CORE || {
  echo "Core not found in $CORE"
  exit 1
}
test -d $VHOST || {
  echo "Virtual hosts directory not found in $VHOST"
  exit 1
}
test -e "$SCRIPTDIR/config.sh" || {
  echo "Could'nt find config.sh in script directory $SCRIPTDIR."
  exit 1
}
test -z "$WEBCMD" && {
  echo "Please specify command to start your webserver in config.sh (WEBCMD)"
  exit 1
}
test -d "$CMDDIR" || {
  echo "Command directory not found in $CMDDIR (CMDDIR)"
  exit 1
}
test -d "$ROOTJOBLOG" || {
  echo "Directory for logs not found in $ROOTJOBLOG (ROOTJOBLOG)"
  exit 1
}
test -z "$WRPEMAIL" && {
  echo "Please give a mail-address for iwatch-stuff in config.sh (WRPEMAIL)"
  exit 1
}
test -z "$WRPTMPDIR" && {
  WRPTMPDIR="$SCRIPTDIR"
}

test -z "$USESOLR" && {
  test -z "$SOLRCMD" && {
    echo "Please specify command to start solr in config.sh (SOLRCMD)"
    exit 1
  }
  test -z "$SOLR" && {
    echo "Please specify Solr directory in config.sh (SOLR)"
    exit 1
  }
  test -z "$INDEXCMD" && {
    echo "Please specify command to index a host in config.sh (INDEXCMD)"
    exit 1
  }
}

test -z "$USEIWATCH" && {
  test -z "$IWATCHCMD" && {
    echo "Please specify command to start iwatch in config.sh (IWATCHCMD)"
    exit 1
  }
  test -z "$IWATCHCFG" && {
    echo "Please specify in config.sh where iwatch.xml will reside (IWATCHCFG)"
    exit 1
  }
  test -z "$IWATCHDTD" && {
    echo "Please specify in config.sh where iwatch.dtd will reside (IWATCHDTD)"
    exit 1
  }
}

export RJPCONFIGCHECKED=1
