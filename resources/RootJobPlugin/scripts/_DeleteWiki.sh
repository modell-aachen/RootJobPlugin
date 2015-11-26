test -z "$RJPCONFIGCHECKED" -o -z "$RJPVHCCONFIGCHECKED" && {
  echo "Config not verified ($BASH_SOURCE)"
  exit 1
}

importPARAM wname "$VHOSTREGEX"

test -z "$wname" && {
  echo "Could not find wiki name!"
  return;
}

test -e "$VHOST/$wname/core" && {
  echo "Wiki $wname has been marked as 'core' and will not be deleted!";
  return;
}

test -e "$VHOST/$wname/protected" && {
  echo "Wiki $wname has been marked as 'protected' and will not be deleted!";
  return;
}

echo "Deleting $wname..."
test -d "$VHOST/$wname" || {
  echo "Wiki not found: $wname"
  return;
}

SUFFIX=_disabled_`date +"%Y%m%d"`
test -d "$DISABLED/${wname}${SUFFIX}" && {
  SUFFIX=${SUFFIX}_`date +"%s"`
  test -d "$DISABLED/${wname}${SUFFIX}" && {
    echo "Could not find a spot to move the old data to... please try again."
    return
  }
}
test -d "$DISABLED" || mkdir -p "$DISABLED"

# This unfortunately is a bit evil, since I'm first going to remove the data
# directories and then reconfigure the services using them.
# The proper way of course would be the other way around.
mv "$VHOST/$wname" "$DISABLED/${wname}${SUFFIX}"
test -n "$USESOLR" -a -d "$SOLR/$wname" && {
  mv "$SOLR/$wname" "$SOLR/${wname}${SUFFIX}"
}

cd "$SCRIPTDIR" && find . -name _DeleteWiki_\* -exec bash {} "$wname" \;

export TOUCHEDCFG=1
